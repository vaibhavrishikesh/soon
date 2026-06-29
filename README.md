# Soon ⏳

**Soon — your countdowns.** Beautiful, fully offline "days until" tracker for the
events you’re looking forward to — trips, birthdays, deadlines.

SwiftUI · no backend · no AI · local storage. Built and run entirely from the CLI.

## Build & run (no Xcode GUI)

Requires Xcode 16 CLT + [`xcodegen`](https://github.com/yonaskolb/XcodeGen).

```bash
xcodegen generate
xcodebuild -project Soon.xcodeproj -scheme Soon -sdk iphoneos \
  -destination 'platform=iOS,id=<device-udid>' -derivedDataPath build \
  -allowProvisioningUpdates DEVELOPMENT_TEAM=<team> CODE_SIGN_STYLE=Automatic build
xcrun devicectl device install app --device <udid> build/Build/Products/Debug-iphoneos/Soon.app
```

## Structure
```
project.yml                 # xcodegen spec
Sources/
  SoonApp.swift             # @main
  Theme.swift               # colors + gradient palette
  Models/CountdownEvent.swift
  Store/EventStore.swift    # local persistence (UserDefaults + Codable)
  Screens/
    HomeView.swift          # list of countdown cards
    EventCard.swift
    AddEventView.swift      # add / edit (name, date, icon, color)
    EventDetailView.swift   # big full-screen countdown
```

## Roadmap
- [ ] Home & lock-screen widgets (WidgetKit)
- [ ] Notifications (remind me the day before)
- [ ] iCloud sync
- [ ] Paywall for unlimited countdowns / premium themes
