# Soon — What to do next (handoff)

**Updated:** 2026-08-07 · Read this first when picking up Soon.

## 📍 Where we are

**v1.0 is LIVE on the App Store.** The Guideline 2.1 review that this doc used to
call "#1 priority, blocking release" was cleared long ago — that entry sat here
stale from 8 July and would have sent the next person to redo finished work.

**All planned v1.0 features shipped:** countdowns, home widgets (small + medium),
lock-screen widgets, lock-screen live timer ticking `{days}d HH:MM:SS`,
Live Activity / Dynamic Island, per-event notifications, urgency mode, confetti,
share-as-image, in-app widget guide.

## 📊 The numbers, and what they actually say (ASC Analytics, 90 days to 5 Aug)

| | Soon |
|---|---:|
| App Store Search impressions | **153** (Browse 2) |
| Product page views | 7 |
| **Impression → page view** | **4.5%** |
| Downloads | 8 |

Read against the other two apps in the account over the same window:

| | Peak launch bump | Tap rate | Still getting impressions? | Downloads |
|---|---:|---:|:---:|---:|
| Hydrate | ~600/day | 4.1% | ✅ yes | 30 |
| **Soon** | **~21/day** | **4.5%** | ✅ **yes** | 8 |
| Unflinch | ~800/day | 1.3% | ❌ zero since 31 Jul | 4 |

**Soon has the best tap rate of the three.** Its launch bump was ~40× smaller
than Unflinch's and it is the one still alive — it took twice the downloads from
a sixth of the impressions.

> **The funnel is not broken. The top of it is empty.**
> 153 impressions in 90 days is under 2 a day. Adding features cannot fix that —
> a new feature only ever reaches the 8 people who already have the app.

## 🔴 #1 — "countdown" is the category's biggest search word and it is not in the name

App Store name: **`Soon: Days Until`** — 16 characters of the 30 Apple allows.
**14 are being thrown away.**

People type **"countdown"**. The competition is literally named for it:
Countdown+, Countdown Widget, Countdown Star, Dreamdays. **"Soon" is a brand
word with no search value at all.**

The name field carries more ASO weight than the keyword field. This is the
cheapest, highest-leverage change available:

| Candidate | Chars |
|---|---:|
| `Soon: Countdown Widget` | 22 |
| `Soon: Countdown & Days Until` | 28 |

Also worth checking while in there: the **subtitle** (another 30 characters) and
the keyword field — neither has been reviewed against real search terms.

## 🟠 #2 — the strongest feature is invisible in the listing

**"countdown widget"** is a heavily searched term, and Soon has one of the best
widget stories in the category — home, lock screen, a live ticking timer, and
Dynamic Island. Most countdown apps have no Live Activity at all.

The word **"widget" does not appear in the app's name.**

## 🟡 #3 — AdMob is costing more than it earns

In the code: `GoogleMobileAds` plus an `ATTrackingManager` prompt at launch
(`Sources/SoonApp.swift`, `Sources/Ads/AdBanner.swift`).

What it costs:
- It is what triggered the **Guideline 2.1 review hold**.
- A first-time user meets an **ATT permission prompt before creating a single
  countdown**.
- At 8 downloads in 90 days the revenue is negligible. (Check AdMob for the real
  figure — it does not appear in ASC.)

And it interacts with everything above: **first-run experience feeds the ranking
loop.** A permission prompt on launch is friction at exactly the moment Apple is
measuring whether people engage.

This is an owner's call, not a technical one. But the trade currently runs the
wrong way.

## ⛔ What NOT to do next

`ROADMAP.md` lists a **paywall** under v1.1. **Do not build it yet.**

Unflinch is the cautionary case in this same account: the most monetisation work
of any app here, and the least demand — all of it behind a door nobody reached.
Its impressions have been zero since 31 July.

At 153 impressions per 90 days a paywall monetises nobody. Fix the name, watch
whether impressions move, and let that decide when monetisation is worth
building.

The other v1.1 items (configurable widget via AppIntent, iCloud sync, polish) are
fine work — they are just not what is limiting this app.

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
- [`app-review-notes.md`](app-review-notes.md) — the Apple 2.1 reply. Already used;
  keep it, it is reusable for other apps in the account.
- `superpowers/specs/` — design specs for the shipped feature batches.
