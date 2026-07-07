# Soon — Roadmap & Feature Plan

> Living plan for **Soon** (offline "days-until" countdown app). What's shipped,
> what's next, and a pointer for each. Specs live in `docs/superpowers/specs/`.

_Last updated: 2026-06-30_

## ✅ Shipped

- **Core app** — add / edit / delete countdowns (title, date, SF Symbol, color),
  list sorted soonest-first, full-screen detail with a live D:H:M:S ticker +
  animated gradient background. Fully offline (UserDefaults + Codable).
- **WidgetKit widgets** — small + medium (home) + lock-screen
  (rectangular / circular / inline). Auto-shows the soonest upcoming event.
  Shared with the app via App Group `group.com.tranquilwaters.soon`.
- **Lock-screen live timer** — rectangular widget ticks `{days}d HH:MM:SS` down to
  the next midnight, live on the lock screen without the app running.
  Spec: [`specs/2026-06-30-lock-screen-live-timer-design.md`](superpowers/specs/2026-06-30-lock-screen-live-timer-design.md)
- **Notifications** — per-event "day before" / "on the day" local reminders; events
  gained a time-of-day. `UNUserNotificationCenter` via NotificationManager.
  Spec: [`specs/2026-06-30-notifications-design.md`](superpowers/specs/2026-06-30-notifications-design.md)

## 🔜 Next (prioritized)

### 1. Configurable widget (AppIntent) · _medium effort_
Let the user pick *which* countdown a widget shows (not just the soonest), via
`AppIntentConfiguration` + a `WidgetConfigurationIntent`. Builds on the existing
widget; mostly additive. Pairs well with multiple widgets on one screen.

### 2. iCloud sync · _medium effort_
Events across the user's devices. Start simple with
`NSUbiquitousKeyValueStore` (small data, key-value) or step up to CloudKit if we
outgrow it. Requires iCloud capability + entitlement.

### 3. Paywall / monetization · _depends on RevenueCat_
Free tier: N countdowns (e.g. 3) + base themes. Premium: unlimited countdowns,
premium gradient themes, maybe widget themes. RevenueCat for subscriptions + IAP.
Aligns with the indie playbook (hard paywall, onboarding-driven). Gate after the
app has real users / the above polish is in.

### 4. Polish & delight · _ongoing_
- App icon variants / alternate icons
- More SF Symbols + color palettes in the picker
- Haptics on add/complete, micro-interactions
- "Share countdown as image" (great for the before/after / story-share loop)
- Onboarding (sell the paywall later)

## 🧭 Sequencing rationale

Notifications shipped (cheap, high retention). Next: **Configurable widget**
(power-user delight on top of what we built), then **iCloud** (multi-device
trust) before **Paywall** (monetize once there's something worth paying for).
Polish runs alongside throughout.

## 📦 Parked / out of scope (for now)

 Apple Watch app. Android. These wait until the core loop + monetization
are proven.

## ✅ 2026-07-07 delight batch (shipped)
Time-aware states · reminders default ON · opt-in rainbow glow · urgency mode
(pulse→jump→roam) · confetti · share-as-image · **Live Activity (final-24h
Dynamic Island + lock banner)**. Spec: `specs/2026-07-07-time-aware-ux-delight-design.md`.
