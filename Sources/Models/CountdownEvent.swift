import SwiftUI

struct CountdownEvent: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var date: Date
    var symbol: String      // SF Symbol name
    var colorIndex: Int     // index into Palette.gradients

    var gradient: LinearGradient { Palette.gradient(colorIndex) }
    var colors: [Color] { Palette.colors(colorIndex) }

    /// Whole days from a reference day (start of day) to the event day. Negative = past.
    func days(asOf now: Date) -> Int {
        let cal = Calendar.current
        let from = cal.startOfDay(for: now)
        let to   = cal.startOfDay(for: date)
        return cal.dateComponents([.day], from: from, to: to).day ?? 0
    }

    /// Whole days from today to the event day. Negative = past.
    var daysAway: Int { days(asOf: Date()) }

    var isPast: Bool { daysAway < 0 }

    /// Big number / word shown on a card, for a given day count.
    static func countText(forDays days: Int) -> String {
        switch days {
        case 0:  return "Today"
        case 1:  return "1"
        case -1: return "1"
        default: return String(abs(days))
        }
    }

    /// Small caption under the number, for a given day count.
    static func captionText(forDays days: Int) -> String {
        switch days {
        case 0:            return "happening today 🎉"
        case 1:            return "day to go · tomorrow"
        case -1:           return "day ago · yesterday"
        case let d where d > 1:  return "days to go"
        default:           return "days ago"
        }
    }

    /// Big number / word shown on the card.
    var countText: String { Self.countText(forDays: daysAway) }

    /// Small caption under the number.
    var captionText: String { Self.captionText(forDays: daysAway) }

    var dateText: String {
        date.formatted(.dateTime.weekday(.wide).day().month(.wide).year())
    }

    // MARK: Sample seed (shared by the app's first-run and the widget placeholder)
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

extension Array where Element == CountdownEvent {
    /// Upcoming first (soonest on top), then past events (most recent first).
    func soonestFirst(asOf now: Date = Date()) -> [CountdownEvent] {
        sorted { a, b in
            let da = a.days(asOf: now), db = b.days(asOf: now)
            if (da >= 0) != (db >= 0) { return da >= 0 }   // upcoming before past
            return da >= 0 ? da < db : da > db
        }
    }
}
