# Changelog

## 1.0.0-beta.6 — 2026-11-09

- **Station search:** *Find stations…* searches the free radio-browser.info directory by name and/or country. ▶ plays a station
  right away, **Add** puts it in your list, and *Remove from list* takes one out. The welcome step has *Find stations in my country*.
- The phone's country is used as the default for the WiFi country on the setup page and for the station search.
- License: GPL-3.0-or-later. The license text is in the image, the installer download and `/usr/local/share/alarm-radio/`.
- `install.sh` works with any number of Pis (it no longer stores every Pi's SSH key under one name).
- README: *Known limitations (DIY risks)* and *Roadmap*.
- **Installer download:** every release now has `pialarmradio-<version>-installer.tar.gz` next to the image, for a Pi that
  already runs Raspberry Pi OS (Bookworm or newer, 32- or 64-bit).
- The installer checks the system first (OS version, Bluetooth, WiFi, NetworkManager, free port 80) and stops without
  changing anything if it doesn't fit.
- The image file is now named `pialarmradio-<version>.img.xz` (no date prefix).
- README: *Which Raspberry Pi?* table (tested on Pi Zero W; other models with built-in WiFi + Bluetooth should work).

## 1.0.0-beta.5 — 2026-11-09

- The radio's address is now **`pialarmradio.local`** (hostname `pialarmradio`), matching the product name.
- The setup hotspot page shows where to find the radio after setup (`pialarmradio.local`, `-2` when there is
  already a radio, or the IP address from the router), with a tip to take a screenshot.
- Clearer help on the radio's web address: the setup page mentions `pialarmradio-2.local` when another radio is on the
  network, and the README has a *Finding the radio's address* section (several radios, `.local` not working, IP address).

## 1.0.0-beta.4 — 2026-11-09

- Speaker card: **Keep speaker awake** switch (inaudible 20 Hz tone while idle, so speakers don't power off before
  the alarm) with Low / Normal / Strong level.

## 1.0.0-beta.3 — 2026-11-09

- Fix: on a fresh install (no speaker chosen yet) *Find Bluetooth speakers* could find nothing, because the Bluetooth
  adapter was never switched on. The watchdog now keeps it on, the scan switches it on first, and a missing
  adapter is shown as an error.
- Tested on a Pi Zero W: setup hotspot → WiFi → pairing a JBL GO Essential → radio plays.

## 1.0.0-beta.2 — 2026-11-09

First public beta of **Pi Alarm Radio** by North UP krafts.

- Alarm-clock web radio for Raspberry Pi (Zero W and up) with any Bluetooth speaker: alarm time, days, station,
  volume, fade-in and duration in a phone-friendly web UI, with a local fallback chime when the stream can't be reached.
- Station picker (Estonian stations, editable list) or any http(s) stream. Play/Stop, live volume, test alarm.
- Speaker setup in the web UI: scan, pair and switch Bluetooth speakers.
- First-boot setup without a keyboard or Imager settings: with no known WiFi, the Pi opens the open network
  "PiAlarmRadio-Setup" with a captive-portal page to choose the WiFi. Then a welcome step (time zone from the phone).
  Settings card for time zone and WiFi. The setup network comes back by itself if the WiFi is gone for good.
- The setup page and Settings show the radio's real address (e.g. `alarmradio-2.local` when two radios share a network).
- Reliability: one permanent mpv audio engine, Bluetooth reconnect watchdog, keep-alive tone, transient alarm timer
  (saving in ~3 s on a Pi Zero), small persistent journal.
- Ready-to-flash OS image (Raspberry Pi OS Lite 32-bit, trixie) built by GitHub Actions.
- North UP krafts look: dark theme, gold accent, logo.

Changes since 1.0.0-beta.1 (not published): renamed to Pi Alarm Radio, no light/bulb features, the image build installs from
/opt (the first build failed), real mDNS address shown.
