#!/usr/bin/env bash
# Runs inside the emulator step. The static server already listens on the runner host (10.0.2.2 from the emulator).
set -euo pipefail
OUT="${OUT_DIR:-artifacts}"
mkdir -p "$OUT"

adb wait-for-device
adb root || true
adb wait-for-device
# skip Chrome's first-run screens
adb shell 'echo "chrome --disable-fre --no-default-browser-check --no-first-run" > /data/local/tmp/chrome-command-line'
adb shell chmod 755 /data/local/tmp/chrome-command-line

adb shell am start -a android.intent.action.VIEW -d "http://10.0.2.2:8000/?platform=android-api${API_LEVEL}" com.android.chrome

for i in $(seq 1 90); do
  [ -f "$OUT/report-android-api${API_LEVEL}.json" ] && break
  sleep 1
done
sleep 2
adb exec-out screencap -p > "$OUT/android-api${API_LEVEL}.png"
[ -f "$OUT/report-android-api${API_LEVEL}.json" ] || { echo "no report received"; exit 1; }
