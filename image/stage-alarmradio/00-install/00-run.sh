#!/bin/bash -e
# Install the alarm radio into the image with the same installer used on a live Pi.
# files/alarm-radio/ is filled from the repository by the build workflow (see image/README.md).
# Not /tmp: pi-gen mounts a fresh tmpfs on the image's /tmp while running chroot commands.
SRC=/opt/alarm-radio-install
install -d "${ROOTFS_DIR}${SRC}"
cp -r files/alarm-radio/. "${ROOTFS_DIR}${SRC}/"
ls "${ROOTFS_DIR}${SRC}"
on_chroot << CHROOT
IMAGE_BUILD=1 bash ${SRC}/pi-setup.sh
rm -rf ${SRC}
CHROOT
