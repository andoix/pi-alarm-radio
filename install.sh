#!/bin/bash
# Install / reinstall the alarm radio on the Pi from this Mac.
#   ./install.sh user@host        e.g. ./install.sh pi@pialarmradio.local
# Copies bin/, systemd/, etc/ and pi-setup.sh to the Pi and runs pi-setup.sh as root.
# An existing /etc/alarm-radio.conf on the Pi is kept (pass FORCE_CONF=1 to overwrite it).
set -e
HOST=${1:?usage: ./install.sh user@host   (e.g. pi@pialarmradio.local)}
O=(-o HostKeyAlias=pialarmradio.local)   # same host key whether reached by name or IP
cd "$(dirname "$0")"
ssh "${O[@]}" "$HOST" 'rm -rf /tmp/alarm-radio && mkdir /tmp/alarm-radio'
scp "${O[@]}" -rq bin systemd etc assets pi-setup.sh VERSION "$HOST":/tmp/alarm-radio/
ssh "${O[@]}" -t "$HOST" "sudo FORCE_CONF=${FORCE_CONF:-0} bash /tmp/alarm-radio/pi-setup.sh"
