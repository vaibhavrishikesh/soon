import Foundation
import ActivityKit

/// Starts a Live Activity for the soonest event inside its final 24 hours,
/// and ends any activity that no longer matches (event edited/deleted/passed).
/// Called on launch and whenever the store saves — local only, no push channel.
@MainActor
enum LiveActivityManager {
    private static let window: TimeInterval = 24 * 3600

    static func sync(_ events: [CountdownEvent]) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let now = Date()
        let candidate = events
            .filter { $0.date > now && $0.date.timeIntervalSince(now) <= window }
            .min { $0.date < $1.date }

        Task {
            // Respect a lock-screen swipe-dismissal: remember it, then let go.
            for activity in Activity<SoonActivityAttributes>.activities
            where activity.activityState == .dismissed {
                LiveActivityDismissals.record(eventID: activity.attributes.eventID,
                                              eventDate: activity.content.state.eventDate)
            }
            // End anything stale (wrong event, changed date, or moment passed).
            for activity in Activity<SoonActivityAttributes>.activities {
                let matches = candidate.map {
                    activity.attributes.eventID == $0.id
                        && activity.content.state.eventDate == $0.date
                } ?? false
                if !matches {
                    await activity.end(nil, dismissalPolicy: .immediate)
                }
            }
            guard let event = candidate else { return }
            // The user closed this one — don't restart it (a new date re-allows).
            if LiveActivityDismissals.isDismissed(eventID: event.id, eventDate: event.date) {
                return
            }
            let alreadyRunning = Activity<SoonActivityAttributes>.activities.contains {
                $0.attributes.eventID == event.id
                    && $0.content.state.eventDate == event.date
            }
            guard !alreadyRunning else { return }

            let attributes = SoonActivityAttributes(
                eventID: event.id, title: event.title,
                symbol: event.symbol, colorIndex: event.colorIndex)
            let state = SoonActivityAttributes.ContentState(eventDate: event.date)
            _ = try? Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: event.date))
        }
    }
}
