import SwiftUI
import WidgetKit

@MainActor
final class EventStore: ObservableObject {
    @Published private(set) var events: [CountdownEvent] = []

    init() { load() }

    /// Upcoming first (soonest on top), then past events (most recent first).
    var sorted: [CountdownEvent] { events.soonestFirst() }

    func add(_ e: CountdownEvent) {
        events.append(e); save()
        NotificationManager.reschedule(e)
    }

    func update(_ e: CountdownEvent) {
        guard let i = events.firstIndex(where: { $0.id == e.id }) else { return }
        events[i] = e; save()
        NotificationManager.reschedule(e)
    }

    func delete(_ e: CountdownEvent) {
        events.removeAll { $0.id == e.id }; save()
        NotificationManager.cancel(e)
    }

    /// The user calmed a final-stretch card — stop all urgency animation for it.
    func acknowledgeUrgency(_ e: CountdownEvent) {
        guard let i = events.firstIndex(where: { $0.id == e.id }),
              !events[i].urgencyAcknowledged else { return }
        events[i].urgencyAcknowledged = true; save()
    }

    // MARK: Persistence (App Group — shared with the widget)
    private func load() {
        let stored = SoonData.loadEvents()
        if stored.isEmpty {
            // First run: seed samples and persist them so the widget sees them too.
            events = CountdownEvent.samples
            save()
        } else {
            events = stored
        }
    }

    private func save() {
        SoonData.saveEvents(events)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
