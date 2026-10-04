# Build on Intel Mac

1. Install Xcode from the App Store.
2. Open `SleepGuard.xcodeproj`.
3. Select scheme `SleepGuard` and `My Mac`.
4. Press Run.

For a local Intel build from Terminal:

```bash
./build_macos.sh
```

For a DMG:

```bash
./make_dmg.sh
```

Output:
- `build/SleepGuard.app`
- `build/SleepGuard-Intel-x86_64.dmg`

No Qt, Homebrew Qt, aqtinstall or macdeployqt is required.
