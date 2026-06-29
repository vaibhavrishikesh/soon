import SwiftUI

@MainActor
final class EventStore: ObservableObject {
    @Published private(set) var events: [CountdownEvent] = []
    private let key = "soon.events.v1"

    init() { load() }

    /// Upcoming first (soonest on top), then past events (most recent first).
    var sorted: [CountdownEvent] {
        events.sorted { a, b in
            let da = a.daysAway, db = b.daysAway
            if (da >= 0) != (db >= 0) { return da >= 0 }   // upcoming before past
            return da >= 0 ? da < db : da > db
        }
    }

    func add(_ e: CountdownEvent) { events.append(e); save() }

    func update(_ e: CountdownEvent) {
        guard let i = events.firstIndex(where: { $0.id == e.id }) else { return }
        events[i] = e; save()
    }

    func delete(_ e: CountdownEvent) { events.removeAll { $0.id == e.id }; save() }

    // MARK: Persistence
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([CountdownEvent].self, from: data) {
            events = decoded
        } else {
            events = Self.samples
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static var samples: [CountdownEvent] {
        let cal = Calendar.current
        func day(_ n: Int) -> Date { cal.date(byAdding: .day, value: n, to: Date()) ?? Date() }
        return [
            CountdownEvent(title: "Goa Trip",    date: day(5),  symbol: "airplane",          colorIndex: 3),
            CountdownEvent(title: "My Birthday", date: day(23), symbol: "birthday.cake.fill", colorIndex: 1),
            CountdownEvent(title: "New Year",    date: day(40), symbol: "sparkles",           colorIndex: 0),
        ]
    }
}
