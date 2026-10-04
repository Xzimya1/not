# SleepGuard — native macOS MVP

This version removes Qt/macdeployqt completely. It is a native SwiftUI macOS application designed to build with Xcode.

## Included
- SwiftUI dashboard
- Demo sleep stream
- Heuristic sleep-stage estimation: Awake / Light / Deep / REM
- Sleep quality summary
- Heart-rate chart
- Smart Wake settings
- Bluetooth scanner using CoreBluetooth
- CSV export
- macOS microphone/Bluetooth usage descriptions prepared in Info.plist

## Requirements
- macOS 13+
- Xcode 15+ recommended
- Intel Mac supported (`x86_64`); Apple Silicon also works from the same source

## Open
Open `SleepGuard.xcodeproj` in Xcode and press Run.

The demo mode works without a bracelet. Real BLE data protocol is intentionally left as the next integration step because the hardware UUIDs/services/characteristics were not specified in the original MVP specification.

## Important
The sleep-stage classifier is a demonstration baseline, not a clinically validated medical device algorithm.
