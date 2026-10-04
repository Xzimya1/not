#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

APP="build/SleepGuard.app"
DMG="build/SleepGuard-Intel-x86_64.dmg"

if [ ! -d "$APP" ]; then
  ./build_macos.sh
fi

rm -f "$DMG"
STAGE="build/dmg-stage"
rm -rf "$STAGE"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname "SleepGuard" -srcfolder "$STAGE" -ov -format UDZO "$DMG"

echo "Created: $PWD/$DMG"
