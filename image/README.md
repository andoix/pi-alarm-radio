# OS image

A [pi-gen](https://github.com/RPi-Distro/pi-gen) stage, `stage-alarmradio`, that runs after `stage2` (Raspberry Pi OS Lite, **32-bit**, so
it also runs on the Pi Zero W). It installs the radio with `pi-setup.sh` (`IMAGE_BUILD=1`, which skips everything that needs a running Pi).

- The image is built by GitHub Actions (`.github/workflows/image.yml`, using `usimd/pi-gen-action`) on every `v*` tag. The
  `.img.xz` is attached to the GitHub release. You can also start the workflow by hand (*Actions → Build OS image → Run workflow*).
- Image file `pialarmradio-<version>.img.xz`, hostname `alarmradio`, time zone `Europe/Tallinn`. **No default user or password**, and SSH is off. Set the user, WiFi and SSH in
  Raspberry Pi Imager's customisation settings (the image uses cloud-init, like stock Raspberry Pi OS trixie).
- The workflow copies `bin/ systemd/ etc/ assets/ pi-setup.sh VERSION` into `stage-alarmradio/00-install/files/alarm-radio/` before
  the build. That folder isn't committed.

To build locally with Docker instead: clone pi-gen (`master` branch = 32-bit), copy this stage into it, fill
`00-install/files/alarm-radio/` the same way, and run `./build-docker.sh` with a `config` containing
`STAGE_LIST="stage0 stage1 stage2 stage-alarmradio"`, `IMG_NAME=pi-alarm-radio`, `TARGET_HOSTNAME=pialarmradio`, `RELEASE=trixie`.
