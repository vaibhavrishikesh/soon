import Foundation
import ActivityKit

/// Live Activity payload for an event's final 24 hours — shared between the
/// app (which starts/ends it) and the widget extension (which renders it).
struct SoonActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// The exact event moment the ticker counts down to.
        var eventDate: Date
    }

    var eventID: UUID
    var title: String
    var symbol: String
    var colorIndex: Int
}
