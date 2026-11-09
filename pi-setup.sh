#!/bin/bash
# Installs the alarm radio. Runs ON THE PI as root (called by install.sh), or inside the OS image
# build with IMAGE_BUILD=1 (a chroot: no running services, no Bluetooth/WiFi hardware). Safe to re-run.
set -eu
SRC=$(cd "$(dirname "$0")" && pwd)
LIVE=1; [ "${IMAGE_BUILD:-0}" = 1 ] && LIVE=0
live() { [ $LIVE = 1 ]; }
export DEBIAN_FRONTEND=noninteractive
[ "$(id -u)" -eq 0 ] || { echo "run as root: sudo $0"; exit 1; }

# --- checks before changing anything (skipped inside the image build) ---
if live && [ "${SKIP_CHECKS:-0}" != 1 ]; then
    fail() { echo "!! $*"; echo "   (SKIP_CHECKS=1 sudo $0 installs anyway, at your own risk)"; exit 1; }
    . /etc/os-release
    command -v apt-get >/dev/null && [ -d /run/systemd/system ] || fail "needs a Debian-based OS with apt and systemd (Raspberry Pi OS)"
    case "${VERSION_CODENAME:-}" in
        bookworm|trixie|forky) ;;
        *) fail "needs Raspberry Pi OS / Debian 12 (bookworm) or newer, this is ${PRETTY_NAME:-unknown}" ;;
    esac
    ls /sys/class/bluetooth 2>/dev/null | grep -q hci || fail "no Bluetooth adapter found"
    [ -d /sys/class/net/wlan0/wireless ] || fail "no WiFi (wlan0) found"
    if systemctl is-active -q systemd-networkd || ls /etc/netplan/*.yaml >/dev/null 2>&1; then
        fail "the network is managed by systemd-networkd/netplan; the radio needs NetworkManager (as on Raspberry Pi OS)"
    fi
    if ! systemctl is-enabled -q NetworkManager 2>/dev/null && ! systemctl is-active -q NetworkManager 2>/dev/null; then
        fail "NetworkManager is not in use here; installing it could take over your network settings"
    fi
    # a desktop's sound server (PipeWire/PulseAudio) also claims Bluetooth speakers and fights bluez-alsa
    for pkg in libspa-0.2-bluetooth pulseaudio-module-bluetooth; do
        dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed" &&
            fail "this looks like a desktop system ($pkg is installed): use Raspberry Pi OS Lite"
    done
    if ss -ltnH 'sport = :80' 2>/dev/null | grep -q . && ! systemctl is-active -q radio-web; then
        fail "port 80 is already used by another web server (the radio's web page needs it)"
    fi
    grep -q "Raspberry Pi" /proc/device-tree/model 2>/dev/null ||
        echo "note: this is not a Raspberry Pi ($(tr -d '\0' < /proc/device-tree/model 2>/dev/null || echo unknown)); untested"
fi

echo "== packages"
apt-get update -q >/dev/null
apt-get install -y -q --no-install-recommends \
    bluez bluez-alsa-utils libasound2-plugin-bluez mpv sox libsox-fmt-alsa socat iw alsa-utils \
    network-manager dnsmasq-base rfkill python3 avahi-daemon >/dev/null

echo "== scripts and units"
install -m 755 "$SRC"/bin/* /usr/local/bin/
install -m 644 "$SRC"/systemd/*.service /etc/systemd/system/
if [ ! -f /etc/alarm-radio.conf ] || [ "${FORCE_CONF:-0}" = 1 ]; then
    install -m 644 "$SRC"/etc/alarm-radio.conf /etc/alarm-radio.conf
fi
if [ ! -f /etc/alarm-radio-stations.txt ] || [ "${FORCE_CONF:-0}" = 1 ]; then
    install -m 644 "$SRC"/etc/alarm-radio-stations.txt /etc/alarm-radio-stations.txt
fi
mkdir -p /usr/local/share/alarm-radio
install -m 644 "$SRC"/VERSION /usr/local/share/alarm-radio/VERSION
[ -f "$SRC"/LICENSE ] && install -m 644 "$SRC"/LICENSE /usr/local/share/alarm-radio/LICENSE
install -m 644 "$SRC"/assets/northup-logo.png /usr/local/share/alarm-radio/logo.png
. /etc/alarm-radio.conf
sed "s/SPEAKER_MAC/${SPEAKER_MAC:-00:00:00:00:00:00}/" "$SRC"/etc/asound.conf > /etc/asound.conf

echo "== fallback alarm sound"
mkdir -p /usr/local/share/alarm-radio /var/lib/alarm-radio
if [ ! -f "$FALLBACK_SOUND" ]; then
    # three rising chimes + pause, 6 s pattern, repeated to 30 s
    sox -n -r 44100 -c 2 -b 16 /tmp/chime.wav synth 0.35 sine 880 fade q 0.01 0.35 0.25 gain -6 pad 0 0.1
    sox -n -r 44100 -c 2 -b 16 /tmp/c2.wav synth 0.35 sine 1108.7 fade q 0.01 0.35 0.25 gain -6 pad 0 0.1
    sox -n -r 44100 -c 2 -b 16 /tmp/c3.wav synth 0.6 sine 1318.5 fade q 0.01 0.6 0.45 gain -6 pad 0 4.2
    sox /tmp/chime.wav /tmp/c2.wav /tmp/c3.wav /tmp/pattern.wav
    sox /tmp/pattern.wav "$FALLBACK_SOUND" repeat 4
    rm -f /tmp/chime.wav /tmp/c2.wav /tmp/c3.wav /tmp/pattern.wav
fi

echo "== bluetooth"
live && rfkill unblock bluetooth
sed -i 's/^#\?AutoEnable=.*/AutoEnable=true/' /etc/bluetooth/main.conf
grep -q '^AutoEnable=true' /etc/bluetooth/main.conf || sed -i '/^\[Policy\]/a AutoEnable=true' /etc/bluetooth/main.conf
# bond (store link keys) when pairing; allow the speaker to re-pair by itself
sed -i 's/^#\?AlwaysPairable *=.*/AlwaysPairable = true/' /etc/bluetooth/main.conf
sed -i 's/^#\?JustWorksRepairing *=.*/JustWorksRepairing = always/' /etc/bluetooth/main.conf
systemctl enable bluetooth bluealsa >/dev/null 2>&1
if live; then
    systemctl restart bluetooth; sleep 3; systemctl restart bluealsa
    bluetoothctl power on >/dev/null || true
fi

echo "== wifi: power save off, setup hotspot captive portal"
mkdir -p /etc/NetworkManager/conf.d /etc/NetworkManager/dnsmasq-shared.d
install -m 644 "$SRC"/etc/nm-wifi-powersave-off.conf /etc/NetworkManager/conf.d/wifi-powersave-off.conf
install -m 644 "$SRC"/etc/nm-captive-portal.conf /etc/NetworkManager/dnsmasq-shared.d/alarm-radio-captive.conf
live && { iw dev wlan0 set power_save off || true; }

echo "== logs (persistent, small)"
mkdir -p /etc/systemd/journald.conf.d /var/log/journal
rm -f /etc/systemd/journald.conf.d/volatile.conf
install -m 644 "$SRC"/etc/journald-persistent.conf /etc/systemd/journald.conf.d/persistent.conf
if live; then
    systemd-tmpfiles --create --prefix /var/log/journal
    systemctl restart systemd-journald
fi

echo "== services"
# the alarm timer used to be a unit file; it is now transient (see radio-apply)
live && { systemctl disable --now radio-alarm.timer >/dev/null 2>&1 || true; }
rm -f /etc/systemd/system/radio-alarm.timer
systemctl enable radio-schedule.service radio-mpv.service radio-keepalive.service bt-watchdog.service radio-web.service \
    radio-net.service avahi-daemon.service NetworkManager.service >/dev/null 2>&1
if live; then
    systemctl daemon-reload
    systemctl restart radio-mpv.service radio-web.service
    systemctl restart radio-net.service
    radio-apply
fi
[ -n "$SPEAKER_MAC" ] || echo "No speaker yet: open http://$(hostname).local/ and pick one under Speaker."
echo "Without a known WiFi network the Pi opens the open network \"PiAlarmRadio-Setup\" with the setup page."
echo "alarm radio $(cat "$SRC"/VERSION) installed."
