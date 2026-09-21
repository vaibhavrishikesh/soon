# Soon — ASO plan (20 Sep 2026)

**Goal:** impressions / tap-through. Feature / paywall / Android — **out**.  
**Owner lock (20 Sep):** **name + subtitle stay** — only **screenshots** this wave.

Live name: `Soon: Days Until Countdown` · Subtitle: `Day counter & event tracker` — mat chedo.

## Diagnosis

Current 6.5" set (ASC): poetic captions, detail/add/list heavy. **Widget / lock-screen live timer is the product moat and is almost invisible in shot 1.** Shot 4 list has a tiny “Add the widget” banner — too late. Dates show Aug 2020 — looks stale.

## This wave — screenshots only

### New order (6.5" iPhone)

| # | Raw capture needed | Caption (ASO — say the search words) |
|---|---|---|
| **1** | **Lock screen** with rectangular live countdown widget ticking | `Lock screen countdown <em>widget</em>` |
| **2** | Home screen with Soon **small/medium widgets** | `Home screen. Always <em>counting down.</em>` |
| **3** | Full-screen detail D:H:M:S (**fresh dates**, not 2020) | `Watch them melt away — <em>to the second.</em>` |
| **4** | List of upcoming events (+ New countdown) | `The days you <em>can't wait</em> for.` |
| 5 optional | Add form OR Dynamic Island / Live Activity | `Add one <em>in seconds.</em>` |

Drop as shot 1: “And then, one morning — it’s today” (delight, weak ASO).

### Capture checklist

1. Add 2–3 countdowns with **near-future dates** (this month / this year).  
2. Add home widgets + lock-screen rectangular widget for soonest event.  
3. Save raw PNGs as: `lock.png` · `widgets.png` · `detail.png` · `home.png` · (`add.png` optional)  
4. Run factory → upload to ASC 6.5".

```bash
cd ~/workspace/ios-apps/soon/marketing/appstore
python3 build-shots.py ~/Desktop/soon-raw-shots ~/Desktop/soon-store-screenshots-v2
```

Factory captions already updated in `marketing/appstore/build-shots.py`.

### ASC

- New version **1.0.2** (screenshots editable with version) **or** if ASC allows screenshot replace on prepare — same.  
- Name / subtitle / keywords: **do not touch**.

## Success (14–21 days after live)

Search impressions/day up; CR hold ≥ ~2.5%. If flat → then revisit name (not this wave).

## Out of scope

Name, subtitle, keywords, paywall, features, Android, Hydrate review.
