#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

xcodebuild \
  -project SleepGuard.xcodeproj \
  -scheme SleepGuard \
  -configuration Release \
  -sdk macosx \
  -arch x86_64 \
  -derivedDataPath build/DerivedData \
  CONFIGURATION_BUILD_DIR="$PWD/build" \
  build

echo "Built: $PWD/build/SleepGuard.app"
