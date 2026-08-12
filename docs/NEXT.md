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

**The keyword field is already good** — checked in ASC on 7 Aug:

```
countdown,days until,event,birthday,trip,timer,widget,reminder,vacation,anniversary,date,big day
```

`countdown` is the first keyword and `widget` is in there. Nothing to fix.

**And that is exactly why the name matters.** The keywords already cover the
right terms and the app still saw 153 impressions in 90 days. Apple weights the
app *name* far more heavily than the keyword field. The keywords did their job;
the name did not.

Unflinch is in the identical position — a well-built keyword field
(`camera shy, public speaking, confidence, video journal, glossophobia, …`) and a
name nobody searches. **Two apps, same wall.**

Still unreviewed: the **subtitle** (another 30 characters).

## 🔴 #1b — the store listing points AdMob at github.com

**Support URL:** `https://github.com/vaibhavrishikesh/soon`
**Marketing URL:** *empty*

Two consequences, one of them costing money:

**AdMob cannot verify this app, ever, as things stand.** AdMob takes the
developer website from the store listing and crawls `<domain>/app-ads.txt`. With
Marketing URL empty it lands on **github.com**, which returns 406 and will never
carry our publisher ID. That is why AdMob's error for Soon reads *"your details
don't match"* while Hydrate's read *"we didn't find"* — different failures,
correctly described. The app has been on **limited ad serving** because of it.

**And a GitHub repo is not app support.** A user tapping "App Support" lands on
a code repository.

**Fix (needs a new version — the fields are greyed out on a released version):**
set **Marketing URL** to `https://tranquilwaters.in/`, which now serves a correct
`app-ads.txt` (added 7 Aug). Point Support URL at something a user can actually
use. This rides along with the name change below — one submission, both fixed.

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

---

## 7 Aug PM (sunil-Mac) — 1.0.1 SUBMITTED: naam + URLs + naye screenshots ✅

**Jo teen cheezein is doc me atki thi, teeno ek submission me gayin —
1.0.1 (build 4), Waiting for Review 12:29 PM:**

| Field | Ab |
|---|---|
| Name | **Soon: Days Until Countdown** (26/30) |
| Subtitle | **Day counter & event tracker** (naya — khali pada tha) |
| Marketing URL | https://tranquilwaters.in/ |
| Support URL | https://tranquilwaters.in/support/ (naya page, live, sab apps ke kaam ka) |
| Screenshots | 4 naye story-cards (Unflinch-style captions) — factory `marketing/appstore/build-shots.py` is branch pe |

- Branch: **`release/1.0.1`** (origin/main se; version bump + factory yahin) —
  approval ke baad main me merge karna.
- **`feature/cinematic-finale` branch + uska uncommitted WIP untouched hai** —
  local checkout us branch pe hi khada tha, release ke liye alag worktree
  (`~/Desktop/soon-release-101`) use hua.
- Upload CLI se hua (`xcodebuild -exportArchive destination=upload`) — Organizer
  ki zaroorat nahi padi. Auth sunil-user ke Xcode account se aaya.
- **Release ke BAAD hi**: AdMob me Soon ka "Check for updates" (naya support/
  marketing URL tabhi crawl hoga jab naya version live ho).
- Raw sim-shots: `~/Desktop/soon-store-screenshots/` (final 1284x2778 cards).
