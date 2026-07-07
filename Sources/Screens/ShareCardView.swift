import SwiftUI

/// The 1080×1350 (4:5, story/feed-ready) image rendered by "Share as image".
/// No app chrome — just the countdown, on the event's gradient.
struct ShareCardView: View {
    let event: CountdownEvent

    var body: some View {
        ZStack {
            event.gradient
            VStack(spacing: 24) {
                Spacer()
                Image(systemName: event.symbol)
                    .font(.system(size: 150, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.95))
                Text(event.countText)
                    .font(.system(size: 300, weight: .heavy, design: .rounded))
                    .minimumScaleFactor(0.4).lineLimit(1)
                    .foregroundStyle(.white)
                Text(event.captionText)
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                Text(event.title)
                    .font(.system(size: 88, weight: .bold))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5).lineLimit(2)
                    .foregroundStyle(.white)
                Text(event.dateTimeText)
                    .font(.system(size: 42, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
                HStack {
                    Spacer()
                    Text("⏳ Soon")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.65))
                }
            }
            .padding(70)
        }
        .frame(width: 1080, height: 1350)
    }
}
