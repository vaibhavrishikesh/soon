import WidgetKit
import SwiftUI

// MARK: - Timeline

struct SoonEntry: TimelineEntry {
    let date: Date
    let events: [CountdownEvent]
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SoonEntry {
        SoonEntry(date: Date(), events: CountdownEvent.samples)
    }

    func getSnapshot(in context: Context, completion: @escaping (SoonEntry) -> Void) {
        let events = SoonData.loadEvents()
        completion(SoonEntry(date: Date(), events: events.isEmpty ? CountdownEvent.samples : events))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SoonEntry>) -> Void) {
        let events = SoonData.loadEvents()
        let cal = Calendar.current
        let startOfToday = cal.startOfDay(for: Date())

        // One entry now, then one at each upcoming midnight so the day count
        // ticks down on its own even if the app doesn't push a reload.
        var entries: [SoonEntry] = [SoonEntry(date: Date(), events: events)]
        for dayOffset in 1...14 {
            if let midnight = cal.date(byAdding: .day, value: dayOffset, to: startOfToday) {
                entries.append(SoonEntry(date: midnight, events: events))
            }
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

// MARK: - Entry view (routes by widget family)

struct SoonWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: SoonEntry

    private var soonest: CountdownEvent? { entry.events.soonestFirst(asOf: entry.date).first }

    var body: some View {
        if let event = soonest {
            switch family {
            case .systemSmall:        SmallWidget(event: event, asOf: entry.date)
            case .systemMedium:       MediumWidget(events: entry.events, asOf: entry.date)
            case .accessoryRectangular: LockRectangular(event: event, asOf: entry.date)
            case .accessoryCircular:  LockCircular(event: event, asOf: entry.date)
            case .accessoryInline:    LockInline(event: event, asOf: entry.date)
            default:                  SmallWidget(event: event, asOf: entry.date)
            }
        } else {
            EmptyWidget(family: family)
        }
    }
}

// MARK: - Home screen widgets

private struct SmallWidget: View {
    let event: CountdownEvent
    let asOf: Date

    var body: some View {
        let days = event.days(asOf: asOf)
        VStack(alignment: .leading, spacing: 2) {
            Image(systemName: event.symbol)
                .font(.title3.bold())
            Spacer(minLength: 4)
            Text(CountdownEvent.countText(forDays: days))
                .font(.system(size: 46, weight: .heavy, design: .rounded))
                .minimumScaleFactor(0.4).lineLimit(1)
            Text(CountdownEvent.captionText(forDays: days))
                .font(.caption2.weight(.semibold)).opacity(0.9)
            Text(event.title)
                .font(.footnote.bold()).lineLimit(1).opacity(0.95)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(for: .widget) { event.gradient }
    }
}

private struct MediumWidget: View {
    let events: [CountdownEvent]
    let asOf: Date

    var body: some View {
        let top = Array(events.soonestFirst(asOf: asOf).prefix(3))
        let hero = top.first
        VStack(spacing: 8) {
            ForEach(top) { event in
                let days = event.days(asOf: asOf)
                HStack(spacing: 12) {
                    Text(CountdownEvent.countText(forDays: days))
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .frame(minWidth: 50)
                        .minimumScaleFactor(0.5).lineLimit(1)
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 5) {
                            Image(systemName: event.symbol).font(.caption.bold())
                            Text(event.title).font(.subheadline.bold()).lineLimit(1)
                        }
                        Text(CountdownEvent.captionText(forDays: days))
                            .font(.caption2).opacity(0.85)
                    }
                    Spacer(minLength: 0)
                }
                .foregroundStyle(.white)
            }
            if top.count < 3 { Spacer(minLength: 0) }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .containerBackground(for: .widget) { (hero ?? events.first)?.gradient ?? Palette.gradient(0) }
    }
}

// MARK: - Lock screen widgets (rendered monochrome / vibrant by the system)

private struct LockRectangular: View {
    let event: CountdownEvent
    let asOf: Date

    var body: some View {
        let days = event.days(asOf: asOf)
        HStack(spacing: 8) {
            Image(systemName: event.symbol).font(.title3)
            VStack(alignment: .leading, spacing: 1) {
                Text(event.title).font(.headline).lineLimit(1)
                if event.date > asOf {
                    // Live ticking countdown straight to the event (updates on its own).
                    Text(timerInterval: asOf...event.date, countsDown: true)
                        .font(.title3.monospacedDigit().bold())
                        .lineLimit(1).minimumScaleFactor(0.7)
                } else {
                    Text(lockSubtitle(days: days)).font(.caption)
                }
            }
            Spacer(minLength: 0)
        }
        .containerBackground(for: .widget) { Color.clear }
    }
}

private struct LockCircular: View {
    let event: CountdownEvent
    let asOf: Date

    var body: some View {
        let days = event.days(asOf: asOf)
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Image(systemName: event.symbol).font(.caption2)
                Text(CountdownEvent.countText(forDays: days))
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .minimumScaleFactor(0.4).lineLimit(1)
                Text(days == 0 ? "" : (abs(days) == 1 ? "day" : "days"))
                    .font(.system(size: 9, weight: .semibold))
            }
        }
        .containerBackground(for: .widget) { Color.clear }
    }
}

private struct LockInline: View {
    let event: CountdownEvent
    let asOf: Date

    var body: some View {
        let days = event.days(asOf: asOf)
        Label("\(event.title) · \(lockSubtitle(days: days))", systemImage: event.symbol)
    }
}

private func lockSubtitle(days: Int) -> String {
    switch days {
    case 0:  return "Today 🎉"
    case 1:  return "Tomorrow"
    case -1: return "Yesterday"
    case let d where d > 1: return "in \(d) days"
    default: return "\(abs(days)) days ago"
    }
}

// MARK: - Empty state

private struct EmptyWidget: View {
    let family: WidgetFamily

    private var isLockScreen: Bool {
        switch family {
        case .accessoryInline, .accessoryCircular, .accessoryRectangular: return true
        default: return false
        }
    }

    var body: some View {
        Group {
            switch family {
            case .accessoryInline:
                Label("Add a countdown", systemImage: "hourglass")
            case .accessoryCircular:
                ZStack { AccessoryWidgetBackground(); Image(systemName: "hourglass") }
            case .accessoryRectangular:
                Label("Open Soon to add", systemImage: "hourglass")
            default:
                VStack(spacing: 6) {
                    Image(systemName: "hourglass").font(.title)
                    Text("No countdowns").font(.footnote.bold())
                    Text("Open Soon to add one").font(.caption2).opacity(0.8)
                }
                .foregroundStyle(.white)
            }
        }
        .containerBackground(for: .widget) {
            if isLockScreen { Color.clear } else { Palette.gradient(0) }
        }
    }
}

// MARK: - Widget definition

struct SoonWidget: Widget {
    let kind = "SoonWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SoonWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Soon")
        .description("Your next countdown at a glance.")
        .supportedFamilies([
            .systemSmall, .systemMedium,
            .accessoryRectangular, .accessoryCircular, .accessoryInline,
        ])
    }
}

@main
struct SoonWidgetBundle: WidgetBundle {
    var body: some Widget { SoonWidget() }
}
