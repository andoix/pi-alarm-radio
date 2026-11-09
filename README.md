<img src="assets/northup-logo.png" width="96" alt="North UP krafts" align="right">

# Pi Alarm Radio

*by [North UP krafts](https://northup.ee), Haapsalu*

An alarm-clock web radio for a **Raspberry Pi with built-in WiFi and Bluetooth** (made on a Pi Zero W) that plays
through a **Bluetooth speaker**. Everything is set up in a phone-friendly web page. No app and no cloud are needed.

- **Alarm:** time, weekdays, station, volume, fade-in, how long it plays. If the internet is down, it plays a local chime instead.
- **Radio:** a station picker (Estonian stations included, editable) or any http(s) MP3/AAC stream URL. Play, Stop and live volume.
- **Any Bluetooth speaker:** find, pair and switch speakers from the web UI.
- **Reliable:** starts at boot, reconnects the speaker on its own, keeps speakers from auto-powering-off,
  and keeps a persistent log so you can see what happened after an unexpected reboot.

## Which Raspberry Pi?

It needs WiFi and Bluetooth **built into the board**. The OS image is Raspberry Pi OS Lite 32-bit, which runs on every model.

| Model | Built-in WiFi + Bluetooth | Status |
|---|---|---|
| Pi Zero W | yes | **Tested, works** |
| Pi Zero 2 W | yes | Should work, not tested yet |
| Pi 3 B / B+ / A+ | yes | Should work, not tested yet |
| Pi 4, Pi 400 | yes | Should work, not tested yet |
| Pi 5, Pi 500 | yes | Should work (32-bit OS), not tested yet |
| Pi 1, Pi 2, Pi Zero (without W) | no | Not supported (would need USB WiFi and Bluetooth adapters) |

Setup is over WiFi only. A network cable is not used for setup. If you try it on another model, please report how it went in a GitHub issue.

## Install

### Option A: flash the ready-made image (easiest)

1. Download `pialarmradio-<version>.img.xz` from the GitHub **Releases** page.
2. In **Raspberry Pi Imager**, choose *Use custom*, pick the file, and write it to the SD card. No settings are needed. (Imager usually
   doesn't offer its customisation settings for custom images, and the radio doesn't need them.)
3. Boot the Pi. After 3–5 minutes (the first boot is slow) it opens the WiFi network **PiAlarmRadio-Setup**: continue with *First setup* below.

*Advanced, optional:* for SSH access, put an empty file `ssh` on the SD card's `bootfs` drive, and a cloud-init
`user-data` with a user and your SSH key (see the commented examples in the `user-data` file that's already there).

### Option B: installer for a Raspberry Pi that already runs Raspberry Pi OS

For a Pi you already use, or one of the models in the table above. It needs **Raspberry Pi OS (Lite or Desktop,
32- or 64-bit), Bookworm or newer**, with WiFi set up. The installer checks this first and stops without changing
anything if something doesn't fit (old OS, no Bluetooth or WiFi, a network not managed by NetworkManager, or another
web server on port 80).

1. Download `pialarmradio-<version>-installer.tar.gz` from the GitHub **Releases** page onto the Pi, then:

   ```sh
   tar xzf pialarmradio-*-installer.tar.gz
   cd pialarmradio-*-installer
   sudo ./pi-setup.sh
   ```

2. Open `http://<the Pi's hostname>.local/` (the installer prints it). The installer doesn't change the hostname. To
   use `pialarmradio.local`: `sudo raspi-config nonint do_hostname pialarmradio && sudo reboot`.

From a computer, with this repository and SSH access to the Pi, `./install.sh <user>@<pi>.local` does the same.

The installer is safe to re-run (that's also how you update). Your settings in `/etc/alarm-radio.conf` are kept,
unless you pass `FORCE_CONF=1`.

**What it changes on the system:** it installs packages (BlueZ, bluez-alsa, mpv, NetworkManager, avahi), its services and
`/etc/asound.conf`, turns WiFi power saving off, makes the system log persistent (16 MB at most), and runs a web page on
port 80. If the Pi loses its WiFi for good, it opens the **PiAlarmRadio-Setup** hotspot. Uninstalling isn't automated yet.

## First setup

1. **WiFi:** if the Pi doesn't know a WiFi network, after about 2 minutes it opens the open network **PiAlarmRadio-Setup**.
   Join it with your phone and the setup page opens by itself (or open any web address). Choose your network, enter the password, and press
   Connect. The setup network then disappears: reconnect the phone to your WiFi. If the Pi loses its WiFi for good later, the setup network
   comes back by itself, and Settings → *Change WiFi network* does the same while it's connected.
2. Open **http://pialarmradio.local/** (see *Finding the radio's address* below). A welcome step suggests your phone's **time zone**.
3. **Speaker:** put the Bluetooth speaker in pairing mode (usually by holding its Bluetooth button until the light blinks fast), press
   **Find Bluetooth speakers**, then press **Use** next to it. Speakers that are already paired switch over without pairing mode.
4. Set the **alarm**, pick a **station**, and press **Save**. **Test alarm** plays a short version right away.

The speaker can only play from one source at a time, so disconnect phones from it.

### Finding the radio's address

The radio announces itself on your network as **`pialarmradio.local`** (mDNS/Bonjour).

- **More than one radio:** the name is first come, first served. The radio that starts second becomes
  **`pialarmradio-2.local`** (then `-3`, and so on). Which one gets the plain name can change after a power cut, so with several radios
  give each its own name (over SSH: `sudo raspi-config nonint do_hostname bedroom-radio && sudo reboot`). The real name is shown in **Settings → WiFi**.
- **The setup page can't know it yet:** while your phone is on the setup hotspot, the radio is alone on that network,
  so the page says `pialarmradio.local`. Only once it's on your WiFi does it find out whether the name is taken.
- **If a `.local` name doesn't open** (some Android phones and Windows PCs don't support it, and phones sometimes
  remember an old answer for a while), use the radio's **IP address**. You can find it in your router's list of devices
  (as `pialarmradio`), and it's also shown in Settings → WiFi. A fixed (reserved) IP address in the router makes it
  easy to bookmark.

## Command line (on the Pi)

```sh
radio play [URL] | stop | status | vol N | test-alarm | log [N]
sudo radio-pair AA:BB:CC:DD:EE:FF        # switch speaker (same as Use in the web UI)
```

## Settings

Change settings in the web UI, or edit `/etc/alarm-radio.conf` and run `sudo radio-apply`.

- `ALARM_DAYS`: `Mon..Fri`, `Sat,Sun`, `Mon,Wed,Fri`, or `"*"` for every day. `TIMEZONE` defaults to `Europe/Tallinn`.
- `VOLUME` is mpv's volume, which is perceptual (cubic): 50 ≈ 12 % amplitude. `radio vol N` changes the live volume.
- `FADE_SEC` is the volume fade-in.
- `KEEPALIVE_*`: an inaudible 20 Hz tone while idle, so speakers don't power off after ~20 min of silence.
  Also in the web UI: Speaker → *Keep speaker awake* (on/off, level Low −55 / Normal −49 / Strong −40 dBFS).
- **Stations:** `/etc/alarm-radio-stations.txt` holds one `Name|URL` per line. Avoid URLs that contain expiring tokens.

## How it works

| Piece | What it does |
|---|---|
| `/etc/alarm-radio.conf` | All settings. |
| `radio-apply` | Creates the alarm timer as a **transient** systemd timer (`systemd-run`) in about 1 s. Rewriting a unit file needs a daemon-reload, which takes 20–40 s on a Pi Zero. `radio-schedule.service` recreates the timer at boot. |
| `radio-mpv.service` | **One permanent mpv** that holds the speaker. The output is fixed at 44.1 kHz/16-bit, so the Bluetooth device is never reopened. It's controlled over `/run/alarm-radio/mpv.sock` and switches sources in about 1.5 s. |
| `radio-player` | Loads the stream with volume and fade-in, and watches it. If the stream doesn't start, it loops the fallback chime for 2 min, then tries the stream again. |
| `radio-keepalive.service` | While idle, loops the keep-alive tone in mpv. |
| `bt-watchdog.service` | Keeps the adapter powered and the speaker connected. After repeated failures it restarts bluetooth and bluealsa. |
| `radio-pair` | Pairs, trusts and connects a speaker, saves it and switches audio to it. |
| `radio-web.service` | The web UI on port 80 (Python standard library). There's **no login**, so only use it on a home network you trust. |
| journald | Persistent but small (16 MB, 1 month, synced once a minute), so the previous boot's log survives (`journalctl -b -1`). |
| WiFi / BlueZ | WiFi power saving is off (WiFi and Bluetooth share one chip). BlueZ always bonds when pairing. |

Audio path: mpv → ALSA → bluez-alsa (`bluealsa`, A2DP) → speaker. There's no PulseAudio or PipeWire.

## Troubleshooting

```sh
radio status                       # services, speaker, WiFi power save, next alarm
radio log 100                      # recent log of all radio services
journalctl -u bluetooth -u bluealsa -n 50
systemctl list-timers radio-alarm.timer
```

- **`pialarmradio.local` doesn't open:** see *Finding the radio's address* above.
- **Speaker won't connect (`avdtp ... Permission denied`):** the pairing is lost. Put the speaker in pairing mode, remove it with
  `bluetoothctl remove <MAC>`, and pick it again in the web UI.
- **The Pi reboots by itself:** check the power. Use a good 5 V ≥ 2 A supply and don't charge anything from the Pi.
  `vcgencmd get_throttled` other than `0x0` means undervoltage. `journalctl -b -1 -n 80` shows the end of the previous boot. If the log just
  stops, the power was lost.
- **No sound at all:** `sudo systemctl restart radio-mpv radio-keepalive`. Also check the speaker's own volume and whether a phone is connected to it.
- **Stuttering:** WiFi/Bluetooth interference. Check that `radio status` shows `power save off`, and move the Pi closer to the speaker.
- **Alarm didn't fire:** `systemctl list-timers radio-alarm.timer` (if it's missing, run `sudo radio-apply`). Check `timedatectl`: is the clock synced and the time zone right?
- **Fallback chime instead of radio:** the stream URL can't be reached. Test it with `curl -I <url>` on the Pi.

## Building the OS image

`image/` contains a [pi-gen](https://github.com/RPi-Distro/pi-gen) stage that installs the radio on top of Raspberry Pi OS Lite
(32-bit). GitHub Actions (`.github/workflows/image.yml`) builds it when a version tag `v*` is pushed and attaches the
`.img.xz` to the release. See `image/README.md`.

## Releasing a version

1. Update `VERSION` and `CHANGELOG.md`.
2. `git tag v$(cat VERSION) && git push --tags`. The workflow builds the image and creates the GitHub release.

## Files

```
install.sh                 copy to a Pi over SSH and install
pi-setup.sh                the installer (runs on the Pi as root; IMAGE_BUILD=1 inside the image build)
VERSION, CHANGELOG.md
bin/radio                  the `radio` command
bin/radio-player           plays the stream/alarm with fade-in and fallback
bin/radio-apply            config → transient alarm timer
bin/radio-keepalive        keep-alive tone
bin/radio-lib.sh           shared helpers (mpv IPC)
bin/bt-watchdog            Bluetooth reconnect watchdog
bin/radio-pair             pair/switch the speaker
bin/radio-web              web UI
systemd/*.service          units
etc/                       config template, station list, ALSA, journald and NetworkManager snippets
image/                     pi-gen stage for the OS image
```
