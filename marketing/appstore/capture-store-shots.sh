#!/usr/bin/env bash
# Capture clean App Store raw screenshots on iPhone 16 Plus (6.5") simulator.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
UDID="${SIM_UDID:-FFDE3791-155E-4744-AEB0-56789960F5DE}"  # iPhone 16 Plus 18.6
RAW="${RAW_DIR:-/Users/vaibhav/workspace/ios-apps/soon/marketing/appstore/raw}"
OUT="${OUT_DIR:-$HOME/Desktop/soon-store-screenshots-v3}"
DERIVED="$ROOT/build/store-shots"

mkdir -p "$RAW" "$OUT"
cd "$ROOT"

echo "==> Boot sim $UDID"
xcrun simctl bootstatus "$UDID" -b 2>/dev/null || xcrun simctl boot "$UDID" || true
open -a Simulator --args -CurrentDeviceUDID "$UDID" || true
xcrun simctl bootstatus "$UDID" -b

echo "==> Generate + build"
command -v xcodegen >/dev/null && xcodegen generate
xcodebuild -project Soon.xcodeproj -scheme Soon \
  -destination "platform=iOS Simulator,id=$UDID" \
  -derivedDataPath "$DERIVED" \
  -configuration Debug \
  CODE_SIGN_IDENTITY="-" CODE_SIGNING_ALLOWED=YES \
  build | tail -25

APP=$(find "$DERIVED" -name 'Soon.app' -path '*/Debug-iphonesimulator/*' | head -1)
echo "APP=$APP"
xcrun simctl uninstall "$UDID" com.tranquilwaters.soon 2>/dev/null || true
xcrun simctl install "$UDID" "$APP"

shot() {
  local screen="$1" file="$2" wait="${3:-2.4}"
  xcrun simctl terminate "$UDID" com.tranquilwaters.soon 2>/dev/null || true
  sleep 0.4
  xcrun simctl launch "$UDID" com.tranquilwaters.soon -STORE_SHOTS -STORE_SHOTS_SCREEN "$screen"
  sleep "$wait"
  xcrun simctl io "$UDID" screenshot "$RAW/$file"
  echo "  wrote $file"
}

echo "==> Capture (7 shots)"
shot home home.png 2.6
shot detail detail.png 2.8
shot today today.png 2.8
shot roam roam.png 2.8
shot urgency urgency.png 2.6
shot widgets widgets.png 2.4
shot add add.png 2.4

echo "==> Factory cards → $OUT"
python3 "$ROOT/marketing/appstore/build-shots.py" "$RAW" "$OUT"
# Keep Desktop v2 folder in sync for ASC upload habit
cp -f "$OUT"/*.png "$HOME/Desktop/soon-store-screenshots-v2/" 2>/dev/null || true
echo "DONE raw=$RAW cards=$OUT (+ copied to Desktop/soon-store-screenshots-v2)"
open "$OUT" 2>/dev/null || true
