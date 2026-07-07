import WidgetKit
import SwiftUI
import ActivityKit

/// The final-24h Live Activity: lock-screen banner + Dynamic Island, ticking
/// live to the event moment.
struct SoonLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SoonActivityAttributes.self) { context in
            LockBanner(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.attributes.symbol)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .padding(.leading, 6)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.title)
                        .font(.headline).lineLimit(1)
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 12) {
                        ActivityTicker(eventDate: context.state.eventDate)
                            .font(.system(size: 36, weight: .heavy, design: .rounded).monospacedDigit())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                        DismissButton(eventID: context.attributes.eventID)
                    }
                }
            } compactLeading: {
                Image(systemName: context.attributes.symbol)
                    .foregroundStyle(Palette.colors(context.attributes.colorIndex)[0])
            } compactTrailing: {
                ActivityTicker(eventDate: context.state.eventDate)
                    .font(.caption.monospacedDigit().bold())
                    .frame(maxWidth: 58)
                    .foregroundStyle(.white)
            } minimal: {
                Image(systemName: context.attributes.symbol)
                    .foregroundStyle(Palette.colors(context.attributes.colorIndex)[0])
            }
        }
    }
}

/// Ends the activity from inside the island/banner (and remembers the choice).
private struct DismissButton: View {
    let eventID: UUID

    var body: some View {
        Button(intent: EndSoonActivityIntent(eventID: eventID.uuidString)) {
            Image(systemName: "xmark")
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.9))
                .padding(10)
                .background(.white.opacity(0.18), in: Circle())
        }
        .buttonStyle(.plain)
    }
}

/// Counts down while the moment is ahead; flips to a celebration once it hits.
private struct ActivityTicker: View {
    let eventDate: Date

    var body: some View {
        if eventDate > Date() {
            Text(timerInterval: Date()...eventDate, countsDown: true)
        } else {
            Text("🎉 It's time")
        }
    }
}

private struct LockBanner: View {
    let context: ActivityViewContext<SoonActivityAttributes>

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: context.attributes.symbol)
                .font(.title.bold())
            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.title)
                    .font(.headline).lineLimit(1)
                Text("almost time")
                    .font(.caption).opacity(0.85)
            }
            Spacer()
            ActivityTicker(eventDate: context.state.eventDate)
                .font(.system(size: 30, weight: .heavy, design: .rounded).monospacedDigit())
            DismissButton(eventID: context.attributes.eventID)
        }
        .foregroundStyle(.white)
        .padding(18)
        .background(Palette.gradient(context.attributes.colorIndex))
        .activityBackgroundTint(Palette.colors(context.attributes.colorIndex)[0].opacity(0.4))
    }
}
