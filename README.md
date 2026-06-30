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
project.yml                 # xcodegen spec (app + widget targets)
Sources/
  SoonApp.swift             # @main
  Theme.swift               # colors + gradient palette          [shared w/ widget]
  Models/CountdownEvent.swift  # event model + day math           [shared w/ widget]
  Store/
    SharedData.swift        # App Group load/save (the bridge)    [shared w/ widget]
    EventStore.swift        # ObservableObject wrapper + widget reload
  Screens/
    HomeView.swift          # list of countdown cards
    EventCard.swift
    AddEventView.swift      # add / edit (name, date, icon, color)
    EventDetailView.swift   # big full-screen countdown
SoonWidget/
  SoonWidget.swift          # WidgetBundle: small + medium + lock-screen
  Info.plist                # WidgetKit extension point
```

The app and the widget share data through the **App Group**
`group.com.tranquilwaters.soon` (the widget runs in its own process, so events
live in a shared `UserDefaults` suite via `SharedData`). Editing events calls
`WidgetCenter.reloadAllTimelines()` so the widget updates immediately.

> **Simulator note:** App Groups need the entitlement embedded, which the
> `CODE_SIGNING_ALLOWED=NO` simulator build strips. For the widget to read shared
> data in the simulator, build with ad-hoc signing (`CODE_SIGN_IDENTITY="-"`) — on
> a real device with a `DEVELOPMENT_TEAM`, automatic signing handles it.

## Roadmap
- [x] Home & lock-screen widgets (WidgetKit) — auto-shows the soonest countdown
- [ ] Configurable widget (pick which event via AppIntent)
- [ ] Notifications (remind me the day before)
- [ ] iCloud sync
- [ ] Paywall for unlimited countdowns / premium themes
