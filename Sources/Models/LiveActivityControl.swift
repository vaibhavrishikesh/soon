import Foundation
import ActivityKit
import AppIntents

/// Remembers which event's Live Activity the user dismissed — so we don't
/// pushily restart it on the next app open. Keyed by event id → event moment:
/// if the event's date changes, the old dismissal no longer matches and the
/// activity is allowed again. Stored in the App Group (both processes read it).
enum LiveActivityDismissals {
    private static let key = "soon.liveActivity.dismissed.v1"

    private static func load() -> [String: Double] {
        AppGroup.defaults.dictionary(forKey: key) as? [String: Double] ?? [:]
    }

    static func record(eventID: UUID, eventDate: Date) {
        var d = load()
        d[eventID.uuidString] = eventDate.timeIntervalSinceReferenceDate
        AppGroup.defaults.set(d, forKey: key)
    }

    static func isDismissed(eventID: UUID, eventDate: Date) -> Bool {
        load()[eventID.uuidString] == eventDate.timeIntervalSinceReferenceDate
    }
}

/// The ✕ button inside the Live Activity — ends the activity and records the
/// dismissal so it stays gone (until the event's date changes).
struct EndSoonActivityIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Dismiss Countdown"
    static var isDiscoverable: Bool = false

    @Parameter(title: "Event ID")
    var eventID: String

    init() {}
    init(eventID: String) { self.eventID = eventID }

    func perform() async throws -> some IntentResult {
        for activity in Activity<SoonActivityAttributes>.activities
        where activity.attributes.eventID.uuidString == eventID {
            LiveActivityDismissals.record(eventID: activity.attributes.eventID,
                                          eventDate: activity.content.state.eventDate)
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        return .result()
    }
}
