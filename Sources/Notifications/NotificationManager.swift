import Foundation
import UserNotifications

/// Thin wrapper over UNUserNotificationCenter for per-event local reminders.
/// Each event owns up to two requests: "<id>-before" and "<id>-onday".
@MainActor
enum NotificationManager {
    private static var center: UNUserNotificationCenter { .current() }

    /// Ask for permission once (only when status is undetermined). Returns whether
    /// notifications are currently allowed.
    @discardableResult
    static func requestAuthorizationIfNeeded() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        case .authorized, .provisional, .ephemeral:
            return true
        default:
            return false
        }
    }

    static func isDenied() async -> Bool {
        await center.notificationSettings().authorizationStatus == .denied
    }

    /// Cancel this event's pending requests, then add the ones its flags call for.
    static func reschedule(_ e: CountdownEvent) {
        cancel(e)
        if e.remindOnDay {
            schedule(id: ids(e).onday, fire: e.date,
                     title: e.title, body: "🎉 \(e.title) is today!")
        }
        if e.remindDayBefore,
           let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: e.date) {
            schedule(id: ids(e).before, fire: dayBefore,
                     title: e.title, body: "⏳ \(e.title) is tomorrow")
        }
    }

    static func cancel(_ e: CountdownEvent) {
        let i = ids(e)
        center.removePendingNotificationRequests(withIdentifiers: [i.before, i.onday])
    }

    /// Self-heal on launch: re-apply every event's reminders.
    static func rescheduleAll(_ events: [CountdownEvent]) {
        for e in events { reschedule(e) }
    }

    // MARK: - internals

    private static func ids(_ e: CountdownEvent) -> (before: String, onday: String) {
        ("\(e.id.uuidString)-before", "\(e.id.uuidString)-onday")
    }

    private static func schedule(id: String, fire: Date, title: String, body: String) {
        guard fire > Date() else { return }   // never schedule a past fire time
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let comps = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: fire)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }
}
