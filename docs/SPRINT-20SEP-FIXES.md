# Soon — 2–3 day fix & improve sprint (deploy after)

**Locked:** 20 Sep 2026 · Deploy **after** this sprint (new binary + screenshots).  
**Out of scope this sprint:** Android port · full paywall · iCloud.

---

## Day 0 (today / tonight) — listing only, no binary

| Task | Notes |
|---|---|
| Upload 6.5" screenshots | `~/Desktop/soon-store-screenshots-v2/` (01–07) |
| Name / subtitle | **Do not change** (owner lock) |
| Version | Prepare **1.0.2** metadata; attach binary **after** Day 2–3 |

---

## Day 1 — Ads + bottom chrome (the pain you just shot)

**Problem:** AdMob banner sits under `+ New countdown` → FAB floats over list, ad eats space, looks broken. Test mode makes it worse on TF builds.

| # | Fix | Effort |
|---|---|---|
| 1.1 | **FAB vs ad layout** — move banner *above* safe FAB, or FAB to trailing circular (WhatsApp-style) so thumb + ad don’t fight | M |
| 1.2 | **Decide ad policy** — keep banner but never overlap primary CTA; optional: hide banner on empty state / first session | S |
| 1.3 | ATT / notif prompt order — already fixed once; re-verify no double-prompt race after layout change | S |

**Exit:** Device TF build — list scrollable, CTA tappable, ad never covers “New countdown”.

---

## Day 2 — Urgency roam UX + polish

| # | Fix | Effort |
|---|---|---|
| 2.1 | **Roaming card → right-side circular** (WhatsApp thumb zone) — drop random drift; keep pulse + timer + tap-to-open | M |
| 2.2 | Copy: “almost time — tap me” stay; title from event (no “Testing”) | S |
| 2.3 | Re-shoot store cards that change (04-roam, maybe 01-home / 05-urgency) | S |
| 2.4 | Detail ticker digit overlap (seconds mid-transition) — soft fix if still visible | S |

**Exit:** Roam feels intentional + reachable; new `04-roam` shot in set.

---

## Day 3 — Ship prep

| # | Task |
|---|---|
| 3.1 | Bump **1.0.2** (build N+1), changelog / release notes |
| 3.2 | TestFlight smoke: add / detail ticker / widget guide / roam / ads layout |
| 3.3 | ASC: attach binary + final screenshots → Submit |
| 3.4 | Brain / handoff update |

**Exit:** Waiting for Review (or Ready if already in review queue pattern).

---

## Suggested priority order

```
1. FAB + ad layout (must)     ← your screenshot
2. Circular roam (should)     ← thumb UX you asked about
3. Re-shoot + submit (must)
```

Optional later (not this sprint): configurable widget AppIntent · App Preview video · paywall.

---

## Open decisions (owner)

1. **Ads:** keep bottom banner (fixed layout) **or** move ads lighter (less frequent / only after N events)?  
2. **Roam:** circular right **now in this sprint** (Day 2) — yes/no? (you said wait on code earlier; confirm when Day 1 starts)

When you say **“Day 1 start”**, pehle 1.1 layout fix se code shuru.
