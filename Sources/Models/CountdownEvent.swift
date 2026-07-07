import SwiftUI

struct CountdownEvent: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var date: Date          // includes a time-of-day (used for reminders)
    var symbol: String      // SF Symbol name
    var colorIndex: Int     // index into Palette.gradients
    var remindDayBefore: Bool = false
    var remindOnDay: Bool = false
    var urgencyAcknowledged: Bool = false   // user has "calmed" the final-stretch card
    var borderGlow: Bool = false            // opt-in animated glow on this card

    init(id: UUID = UUID(), title: String, date: Date, symbol: String, colorIndex: Int,
         remindDayBefore: Bool = false, remindOnDay: Bool = false,
         urgencyAcknowledged: Bool = false, borderGlow: Bool = false) {
        self.id = id; self.title = title; self.date = date; self.symbol = symbol
        self.colorIndex = colorIndex
        self.remindDayBefore = remindDayBefore; self.remindOnDay = remindOnDay
        self.urgencyAcknowledged = urgencyAcknowledged
        self.borderGlow = borderGlow
    }

    // Migration-safe decode: events saved before these fields existed lack the keys.
    enum CodingKeys: String, CodingKey {
        case id, title, date, symbol, colorIndex, remindDayBefore, remindOnDay,
             urgencyAcknowledged, borderGlow
    }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id         = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title      = try c.decode(String.self, forKey: .title)
        date       = try c.decode(Date.self, forKey: .date)
        symbol     = try c.decode(String.self, forKey: .symbol)
        colorIndex = try c.decode(Int.self, forKey: .colorIndex)
        remindDayBefore = try c.decodeIfPresent(Bool.self, forKey: .remindDayBefore) ?? false
        remindOnDay     = try c.decodeIfPresent(Bool.self, forKey: .remindOnDay) ?? false
        urgencyAcknowledged = try c.decodeIfPresent(Bool.self, forKey: .urgencyAcknowledged) ?? false
        borderGlow = try c.decodeIfPresent(Bool.self, forKey: .borderGlow) ?? false
    }

    // MARK: Urgency — the final stretch, escalating until acknowledged
    enum UrgencyStage: Int, Comparable {
        case none = 0, pulse, jump, roam
        static func < (a: Self, b: Self) -> Bool { a.rawValue < b.rawValue }
    }

    /// How loudly this event should be demanding attention right now.
    func urgencyStage(asOf now: Date = Date()) -> UrgencyStage {
        guard !urgencyAcknowledged, date > now else { return .none }
        let minutes = date.timeIntervalSince(now) / 60
        if minutes <= 3  { return .roam }
        if minutes <= 10 { return .jump }
        if minutes <= 60 { return .pulse }
        return .none
    }

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

    /// Date + time-of-day, e.g. "Sunday, 5 July 2026 · 9:00 AM" (detail screen).
    var dateTimeText: String {
        dateText + " · " + date.formatted(date: .omitted, time: .shortened)
    }

    /// Compact date + time for list cards, e.g. "Sun, 12 Jul · 9:47 AM".
    var cardDateText: String {
        date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
            + " · " + date.formatted(date: .omitted, time: .shortened)
    }

    var hasReminder: Bool { remindDayBefore || remindOnDay }

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
