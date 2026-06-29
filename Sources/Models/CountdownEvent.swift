import SwiftUI

struct CountdownEvent: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var date: Date
    var symbol: String      // SF Symbol name
    var colorIndex: Int     // index into Palette.gradients

    var gradient: LinearGradient { Palette.gradient(colorIndex) }
    var colors: [Color] { Palette.colors(colorIndex) }

    /// Whole days from today (start of day) to the event day. Negative = past.
    var daysAway: Int {
        let cal = Calendar.current
        let from = cal.startOfDay(for: Date())
        let to   = cal.startOfDay(for: date)
        return cal.dateComponents([.day], from: from, to: to).day ?? 0
    }

    var isPast: Bool { daysAway < 0 }

    /// Big number / word shown on the card.
    var countText: String {
        switch daysAway {
        case 0:  return "Today"
        case 1:  return "1"
        case -1: return "1"
        default: return String(abs(daysAway))
        }
    }

    /// Small caption under the number.
    var captionText: String {
        switch daysAway {
        case 0:            return "happening today 🎉"
        case 1:            return "day to go · tomorrow"
        case -1:           return "day ago · yesterday"
        case let d where d > 1:  return "days to go"
        default:           return "days ago"
        }
    }

    var dateText: String {
        date.formatted(.dateTime.weekday(.wide).day().month(.wide).year())
    }
}
