# Changelog

## 1.0.0 — 2026-11-08

First release.

- Alarm-clock web radio for Raspberry Pi (Zero W and up) with a Bluetooth speaker: alarm time, days, station, volume,
  fade-in and duration in a web UI, with a local fallback chime when the stream can't be reached.
- Station picker (Estonian stations, editable list) or any http(s) stream. Play/Stop, live volume, test alarm.
- Speaker setup in the web UI: scan, pair and switch Bluetooth speakers.
- RGB speaker bulb support ("bt-speaker", TMSmartBulb): light controls, and a wake-up light that fades in with the alarm
  volume. After a power-up the bulb flashes blue and turns off.
- Reliability: one permanent mpv audio engine, Bluetooth reconnect watchdog, keep-alive tone, transient alarm timer
  (saving in ~3 s on a Pi Zero), persistent small journal.
- First-boot setup: without a known WiFi the Pi opens the open hotspot "AlarmRadio-Setup" with a captive-portal
  page to pick the WiFi network; then a welcome step (time zone from the phone, speaker). Settings card for
  time zone and WiFi; the hotspot comes back by itself if the WiFi is gone for good.
- Ready-to-flash OS image (Raspberry Pi OS Lite 32-bit, trixie) built by GitHub Actions.
