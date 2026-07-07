import SwiftUI

struct EventCard: View {
    let event: CountdownEvent

    var body: some View {
        HStack(spacing: 16) {
            // count block
            VStack(spacing: 0) {
                Text(event.countText)
                    .font(.system(size: event.daysAway == 0 ? 26 : 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5).lineLimit(1)
            }
            .frame(width: 84, height: 84)
            .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 18))

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Image(systemName: event.symbol)
                        .font(.subheadline.bold())
                    Text(event.title)
                        .font(.title3.bold()).lineLimit(1)
                }
                .foregroundStyle(.white)
                Text(event.captionText)
                    .font(.caption).foregroundStyle(.white.opacity(0.85))
                HStack(spacing: 5) {
                    Text(event.cardDateText)
                    if event.hasReminder {
                        Image(systemName: "bell.fill").font(.system(size: 9))
                    }
                }
                .font(.caption2).foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.bold()).foregroundStyle(.white.opacity(0.7))
        }
        .padding(16)
        .background(event.gradient, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
        .opacity(event.isPast ? 0.78 : 1)
        .shadow(color: event.colors[0].opacity(0.35), radius: 14, y: 8)
    }
}
