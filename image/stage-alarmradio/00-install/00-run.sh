#!/bin/bash -e
# Install the alarm radio into the image with the same installer used on a live Pi.
# files/alarm-radio/ is filled from the repository by the build workflow (see image/README.md).
install -d "${ROOTFS_DIR}/tmp/alarm-radio"
cp -r files/alarm-radio/. "${ROOTFS_DIR}/tmp/alarm-radio/"
on_chroot << CHROOT
IMAGE_BUILD=1 bash /tmp/alarm-radio/pi-setup.sh
rm -rf /tmp/alarm-radio
CHROOT
