# Soon — What to do next (handoff)

**Updated:** 2026-07-08 · Cross-system handoff. Read this first when picking up Soon.

## 📍 Where we are
- **v1.0 (build 2) submitted to the App Store.** Apple replied with **Guideline 2.1 —
  Information Needed** (the mildest outcome — not a defect; they want more info,
  triggered by the ATT prompt + AdMob ads).
- **All planned features shipped** (see ROADMAP): widgets, lock-screen live timer,
  per-event notifications, urgency mode, confetti, share-as-image, Live Activity
  (Dynamic Island) with dismiss + respect, in-app widget guide.
- Build number is at **CURRENT_PROJECT_VERSION = 2** (already bumped for resubmit).

## 🔴 #1 priority — clear the App Store review (blocking release)
Everything is ready; it just needs a reply + a recording.

1. **Screen recording** on a physical iPhone (latest iOS), starting from app launch:
   launch → create a countdown → show the notification + **ATT** prompts → open a
   countdown. ~30–60s. (No account/purchase/UGC flows exist.)
2. **Reply to Apple** in App Store Connect → the rejected submission → *Reply to App
   Review*: paste the plain-text notes from **[`app-review-notes.md`](app-review-notes.md)**
   (fill in device model + iOS version) and **attach the recording**.
3. Also paste the same into **App Information → App Review Information → Notes**.
4. **Resubmit** (build 2, no code change needed).

> This is likely all it takes — 2.1 Information Needed usually resolves on reply.
> The same notes doc is reusable for **unflinch** and **shwaas** (adapt sections 3/4/5).

## 🟡 After approval — launch
- App Store screenshots must show the app **in use** (not splash/title art) — reuse
  the share-card look. Set up the listing copy.
- Marketing loop: the **share-as-image** feature is the content engine — before/after
  reels of a countdown ticking → Dynamic Island → the moment. Ride that.

## 🟢 Next features (v1.1+, from ROADMAP — none blocking review)
1. **Configurable widget** (AppIntent — pick which event a widget shows).
2. **iCloud sync** (`NSUbiquitousKeyValueStore` first).
3. **Paywall** (RevenueCat — free N countdowns / premium themes).
4. Polish: alternate app icons, more symbols/palettes, onboarding.

## 🛠 Build / run notes (don't lose time to these)
- **After adding ANY Swift file, run `xcodegen generate`** before building — a missing
  file in the project silently sends the Swift type-checker into a multi-minute
  "hung build" (it's not hung — the file just isn't in the target). This cost ~40 min once.
- Keep SwiftUI expressions small (stored `[Color]` arrays, extract row views) — big
  literal/ternary expressions blow up type-inference.
- Simulator build: `./run.sh` (ad-hoc signing so App Groups work). Device build needs
  the real `DEVELOPMENT_TEAM` (already baked into `project.yml`).
- App Group `group.com.tranquilwaters.soon` bridges app ↔ widget ↔ Live Activity.

## 📂 Key docs
- [`ROADMAP.md`](ROADMAP.md) — shipped + next.
- [`app-review-notes.md`](app-review-notes.md) — the Apple reply (ready to paste).
- `superpowers/specs/` — design specs for the shipped feature batches.
