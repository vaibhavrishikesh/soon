# Soon — Time-aware UX + delight features (design)

**Date:** 2026-07-07
**Source:** Live user-testing session (3 failed reminder attempts + "when does it
start/end?" confusion) + feature brainstorm.
**Language rule:** the app is **English-only**. No Hindi/Hinglish strings, ever.

## Workstreams (in build order)

### A) Time-aware countdown states — foundation
Events carry a time now, but the app still thinks in days. Fix every surface:

- **Detail ticker target = `event.date`** (the exact moment), not midnight of the
  event day. "When does it end" is always answerable.
- **Today, time still ahead:** big D:H:M:S ticker (D will be 00) + caption
  "today at 9:56 AM".
- **Today, time passed:** celebration state — "🎉 Started at 9:56 AM".
- **Future days:** ticker to `event.date` as before (days component now exact).
- **Past days:** unchanged ("time since", days-based).
- **Cards:** Today events show "Today · 9:56 AM" in the count block area caption
  (time becomes primary info on the day itself). Other cards keep the compact
  date+time line (already shipped).

### B) Reminders default ON
Three consecutive real-user attempts failed to set a reminder. Fix the default:

- New events: `remindOnDay = true` by default (`remindDayBefore` stays false).
- The permission prompt therefore fires on first Save — a natural moment.
- If permission is denied, save proceeds; the inline hint (already built) shows
  on next edit.
- Sample/seed events keep reminders off.

### C) Animated gradient border on cards
A slow "light sweep" — an angular-gradient stroke rotating along the card border.

- Always on for **upcoming** events' cards (subtle, slow: one revolution ~6s).
- Implementation: `AngularGradient` stroke on the card's RoundedRectangle
  overlay, hue positions driven by `TimelineView(.animation)` phase. White ~20%
  opacity head fading to clear tail — visible on any card gradient.
- Past events: no sweep (they're asleep).

### D) Urgency mode — "the card tells you how important it is" 🔥
In the event's **final stretch**, the card escalates until the user acknowledges:

- **Stage 1 — final 60 min:** border sweep speeds up (~1.5s/rev) and the card
  gently pulses (scale 1.0→1.02 heartbeat).
- **Stage 2 — final 10 min:** the card **jumps** — periodic spring bounce
  (offset y −14pt with rotation jitter ±2°) every few seconds + haptic tick.
- **Stage 3 — final 3 min (unacknowledged):** the card **breaks loose**: a
  compact floating version drifts around the whole app over every screen
  (root-level overlay, slow bouncing-drift path), demanding attention.
- **Acknowledge:** tapping the roaming card (or the home card during stage 2+)
  opens the detail and sets `urgencyAcknowledged = true` on the event → all
  urgency animation stops for that event. A small "Okay okay, I'm ready 🙌"
  button on detail also acknowledges.
- Model: add `urgencyAcknowledged: Bool = false` (migration-safe decode, same
  `decodeIfPresent ?? false` pattern). Reset to `false` whenever the event's
  date is edited (new moment = new urgency).
- All stages only render while the app is open (in-app delight; notifications
  cover out-of-app).

### E) Confetti on the day 🎉
Opening the detail of an event whose day is today (or whose moment just passed
within the last hour) fires a one-shot confetti burst + success haptic. Pure
SwiftUI particle view (30–40 rects/circles falling with random spin), no
dependency. Fires once per view appearance, not per second.

### F) Share as image 📸
On the detail screen: a Share button renders a clean 1080×1350 (4:5) countdown
card — event gradient, symbol, big count, title, date — via `ImageRenderer`,
then presents the system share sheet (`ShareLink` with the rendered `UIImage`).
No app chrome in the image; a tiny "Soon" wordmark bottom-right. Story-ready.

### G) Live Activity — final 24 hours 🏝️ (last, biggest)
When an event enters its final 24h and the app is opened, start a Live Activity:
Dynamic Island (compact: symbol + `Text(timerInterval:)`; expanded: title +
ticker) and lock-screen banner with the event gradient. Ends at the event
moment with a brief "🎉 It's time" state. Requires `NSSupportsLiveActivities`
in Info.plist + an `ActivityConfiguration` added to the existing widget bundle,
and an `ActivityAttributes` type shared app↔widget. Start/refresh from app
foreground (no push channel — local only).

## Out of scope
Recurring events, Siri, custom sounds, Android-style full-screen alarms.

## Build order & checkpoints
A → B (foundation + biggest pain) → C (ambient delight) → D (the wild one,
depends on A's time states) → E → F → G. Build + simulator screenshot after
each letter; commit per letter.

## Verification
- A: detail of a today-event shows ticking to the event time; passed event shows
  started-state. Cards show "Today · time".
- B: create new event → toggle already ON → Save → permission dialog appears →
  bell on card; plist shows `remindOnDay=True`.
- C/D: visual verification on simulator (border sweep; stage animations by
  creating events 5/60 min out). Stage 3 roam visible over Home and Detail.
- E: open today-event detail → confetti fires once.
- F: share sheet presents; saved image is 1080×1350 with correct content.
- G: event <24h away → Dynamic Island shows ticker (simulator supports DI).
