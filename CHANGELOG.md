# Changelog

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
