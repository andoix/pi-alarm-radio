# Changelog

## 1.0.0-beta.1 — 2026-11-08

First release (beta: the OS image and the WiFi setup hotspot are still being tested on real hardware).

- Alarm-clock web radio for Raspberry Pi (Zero W and up) with a Bluetooth speaker: alarm time, days, station, volume,
  fade-in and duration in a web UI, with a local fallback chime when the stream can't be reached.
- Station picker (Estonian stations, editable list) or any http(s) stream. Play/Stop, live volume, test alarm.
- Speaker setup in the web UI: scan, pair and switch Bluetooth speakers.
- Reliability: one permanent mpv audio engine, Bluetooth reconnect watchdog, keep-alive tone, transient alarm timer
  (saving in ~3 s on a Pi Zero), persistent small journal.
- First-boot setup: without a known WiFi the Pi opens the open hotspot "PiAlarmRadio-Setup" with a captive-portal
  page to pick the WiFi network; then a welcome step (time zone from the phone, speaker). Settings card for
  time zone and WiFi; the hotspot comes back by itself if the WiFi is gone for good.
- North UP krafts branding (northup.ee): dark theme, gold accent, logo; setup hotspot "PiAlarmRadio-Setup".
- Ready-to-flash OS image (Raspberry Pi OS Lite 32-bit, trixie) built by GitHub Actions.
