# Soon — Notifications (design)

**Date:** 2026-06-30
**Scope:** Per-event local reminders. Each event can remind the user **a day
before** and/or **on the day**, at a per-event time. Local only — no backend, no
push server.

## Goal

Soon currently has no reminders — a countdown silently arrives. Add opt-in local
notifications so an event can nudge the user as it approaches:

- **Day before:** "⏳ Goa Trip is tomorrow"
- **On the day:** "🎉 Goa Trip is today!"

## Key decisions

- **Events gain a time.** `CountdownEvent.date` already a `Date`; the Add/Edit
  picker is extended from `.date` to `.date + .hourAndMinute`. No new date field.
- **The countdown stays calendar-day based.** `daysAway`, the detail ticker, and
  the lock-screen widget timer are unchanged — they keep using `startOfDay`. The
  time is used only to schedule notifications and to display the event time. This
  deliberately avoids touching the just-shipped widget/timer.
- **Two toggles, not presets.** Per event: `remindDayBefore`, `remindOnDay`
  (both default off). Keep it minimal.
- **Local notifications** via `UNUserNotificationCenter`. No remote push.

## Model changes (`CountdownEvent`)

Add two fields:
```swift
var remindDayBefore: Bool = false
var remindOnDay: Bool = false
```
**Migration safety:** existing events are persisted in the App Group without these
keys. Synthesised `Codable` would throw on the missing keys, so add a custom
`init(from:)` that uses `decodeIfPresent(...) ?? false` for both flags (every other
field decodes normally). This is the same migration concern handled before.

The notification fire time is the event's own `date` (now carrying hour/minute).

## UI (`AddEventView`)

- Date field: `DatePicker(..., displayedComponents: [.date, .hourAndMinute])`.
- A new "Reminders" section with two toggles styled like the existing fields:
  - **Remind a day before**
  - **Remind on the day**
- `save()` persists the two flags alongside the rest.
- Detail screen (`EventDetailView`): show the event time next to the date
  (e.g. "Sunday, 5 July 2026 · 9:00 AM") — `dateText` extended with the time.

## NotificationManager (new — `Sources/Notifications/NotificationManager.swift`)

A small `@MainActor` helper (singleton or injected) wrapping `UNUserNotificationCenter`:

- `requestAuthorizationIfNeeded() async -> Bool` — ask once (`.alert, .sound, .badge`);
  return current granted state.
- `reschedule(_ event: CountdownEvent)` — cancel this event's pending requests, then
  add the ones its flags + times call for.
- `cancel(_ event: CountdownEvent)` — remove this event's pending requests.
- `rescheduleAll(_ events: [CountdownEvent])` — used on launch to self-heal.

**Request identifiers:** `"<event.id>-before"` and `"<event.id>-onday"`, so a given
event's notifications are addressable for cancel/replace.

### Scheduling rules
- **On the day:** fire at `event.date`. Title `event.title`, body
  "🎉 {title} is today!".
- **Day before:** fire at `event.date` minus 1 day (same time). Body
  "⏳ {title} is tomorrow".
- **Skip past fire times:** if the computed fire `Date` is in the past, do not
  schedule that request (e.g. enabling "day before" for an event that's already
  tomorrow, or an on-day time earlier today that has passed).
- Use `UNCalendarNotificationTrigger` from the fire date's
  `dateComponents([.year,.month,.day,.hour,.minute])`, non-repeating.

## Integration

- `EventStore.add/update` → call `NotificationManager.reschedule(event)` after save
  (mirrors the existing `WidgetCenter.reloadAllTimelines()` hook).
- `EventStore.delete` → `NotificationManager.cancel(event)`.
- `SoonApp` → on first appearance, `rescheduleAll(store.events)` to self-heal
  (covers reinstalled/edited state).
- **Permission:** request lazily the first time a user enables a reminder toggle and
  saves. If denied, show an inline note in the form ("Reminders are off — enable
  notifications for Soon in Settings"). Do not nag on every save.

## Edge cases

- **All-day "today" events:** if `remindOnDay` is on but the event time already
  passed today, skip the on-day notification (past-time rule).
- **Editing an event:** `reschedule` cancels old requests first, so changing the
  date/time/flags never leaves stale notifications.
- **Toggles off:** `reschedule` cancels both requests for that event.
- **Permission denied later:** scheduled requests simply won't display; no crash.

## Out of scope (parked)

Snooze, recurring events, custom offsets (week before / N days), per-notification
sound choice, notification actions, a global default-time Settings screen.

## Verification

- Build app + widget (ad-hoc signing on simulator).
- In the simulator: create an event a couple of minutes out with both toggles on;
  confirm the on-day banner fires (simulator delivers local notifications).
- Confirm editing the time reschedules (old request gone, new one present via
  `getPendingNotificationRequests`).
- Confirm a denied-permission path shows the inline hint and does not crash.
