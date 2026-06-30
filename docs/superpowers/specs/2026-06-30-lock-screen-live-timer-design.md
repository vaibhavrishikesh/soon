# Soon — Lock-screen live timer (design)

**Date:** 2026-06-30
**Scope:** One focused feature. Make the lock-screen **rectangular** widget show a
live, self-ticking countdown to the soonest upcoming event. Nothing else changes.

## Goal

Today the lock-screen rectangular widget shows a static line ("Goa Trip · in 5
days"). Upgrade it to a glanceable, *alive* countdown that ticks every second on
the lock screen **without the app running**:

```
⏳  Goa Trip
    5d  14:23:07
```

## Key constraint

WidgetKit's self-updating `Text(timerInterval:)` renders only an `H:MM:SS`-style
clock — it cannot render a "days" component. So "days" and the live ticker are two
separate pieces that must stay coherent:

- **`5d`** — the calendar-day count, identical to what the app shows everywhere
  (`CountdownEvent.daysAway`, computed start-of-day to start-of-day).
- **`14:23:07`** — `Text(timerInterval: now ... nextMidnight, countsDown: true)`,
  the OS-driven ticker counting down to the next local midnight, i.e. the moment
  the day count decrements from `5d` to `4d`.

At each midnight the widget timeline reloads once: the day count flips and the
ticker resets (`4d 23:59:59`). One reload per day — negligible cost.

This keeps the day number consistent across the home list, the detail screen, and
the widget (all say "5d"), while the lock screen feels live. We deliberately do
**not** show a precise time-to-event (which could read "4d" when the app says
"5d") — consistency wins over precision here.

## Behaviour by state (rectangular)

| Event state            | Display                         | Ticking? |
|------------------------|---------------------------------|----------|
| Upcoming (≥1 day away) | `{days}d  HH:MM:SS`             | yes      |
| Today (`daysAway == 0`)| `🎉 Today`                      | no       |
| Past (`daysAway < 0`)  | `{n}d ago`                      | no       |

Line 1 is always `symbol + title`. Rendering is monochrome / system-tinted, as the
lock screen requires (no gradients).

## Other lock-screen families (unchanged)

- **Circular** — large `{days}d` (or `Today`), no ticker.
- **Inline** — `⏳ Goa Trip · in 5 days`, no ticker.

Home-screen widgets (small / medium) are **out of scope** and stay exactly as they
are — they keep the calm "5 / days to go" card.

## Implementation

Single file: `SoonWidget/SoonWidget.swift`. No new target, no model change, no
App-Group change.

1. **`LockRectangular`** — branch on the event state:
   - Upcoming: `HStack { Text("\(days)d"); Text(timerInterval: entry.date ... nextMidnight, countsDown: true).monospacedDigit() }` under the title. `nextMidnight = Calendar.current.startOfDay(for: entry.date) + 1 day`.
   - Today / past: the static strings above (reuse existing `lockSubtitle`).
2. **Provider timeline** — already emits an entry at each upcoming midnight for 14
   days. Confirm the first entry is "now" and subsequent entries land exactly on
   `startOfDay + n·day` so the day flip and ticker reset align. Policy stays
   `.atEnd`; editing events still triggers `WidgetCenter.reloadAllTimelines()`.

`days` for an entry is `event.days(asOf: entry.date)` (already exists). The ticker's
end (`nextMidnight`) is derived from the entry date, so each timeline entry is
self-contained.

## Edge cases

- **Event today** — show `🎉 Today`, no ticker (ticking to "midnight tonight" would
  imply it ends at midnight, which is wrong for an all-day event).
- **Crossing midnight** — handled by the per-midnight timeline entries + reload.
- **All events past** — soonest-first still selects the most recent past event;
  show `{n}d ago`, no ticker.
- **Timer reaching 00:00:00 before reload fires** — `Text(timerInterval:)` clamps at
  zero; the scheduled midnight reload immediately replaces it with the next day's
  entry, so a stale `0d 00:00:00` is never shown for more than an instant.

## Testing / verification

- Build the app + widget target (ad-hoc signing on simulator for App Groups).
- Confirm compile + that `LockRectangular` renders for upcoming / today / past via
  the widget gallery preview (snapshot uses sample data).
- Live ticking + midnight flip are best confirmed on a real device (lock screen);
  the simulator's lock-screen widget host is unreliable (SpringBoard ripple crash).

## Out of scope (parked)

Notifications, configurable widget (AppIntent), iCloud sync, paywall, and any
home-screen widget changes. Also parked: a separate cross-project knowledge
manager / "second brain" idea (its own future brainstorm).
