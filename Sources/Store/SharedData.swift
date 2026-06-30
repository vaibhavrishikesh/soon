import Foundation

/// Single source of truth for the App Group container the app and the widget
/// both read/write. The widget runs in its own process, so the events must
/// live in a shared UserDefaults suite (not `.standard`).
enum AppGroup {
    static let id = "group.com.tranquilwaters.soon"
    static let eventsKey = "soon.events.v1"

    /// Shared suite; falls back to `.standard` only if the suite can't be opened.
    static var defaults: UserDefaults { UserDefaults(suiteName: id) ?? .standard }
}

/// Plain (non-observable) load/save used by both targets. The app's `EventStore`
/// wraps this for SwiftUI; the widget timeline reads it directly.
enum SoonData {
    static func loadEvents() -> [CountdownEvent] {
        guard let data = AppGroup.defaults.data(forKey: AppGroup.eventsKey),
              let decoded = try? JSONDecoder().decode([CountdownEvent].self, from: data)
        else { return [] }
        return decoded
    }

    static func saveEvents(_ events: [CountdownEvent]) {
        if let data = try? JSONEncoder().encode(events) {
            AppGroup.defaults.set(data, forKey: AppGroup.eventsKey)
        }
    }
}
