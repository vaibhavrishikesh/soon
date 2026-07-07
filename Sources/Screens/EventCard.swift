import SwiftUI

/// A colorful light ring running along a rounded-rect border — a rainbow comet
/// chasing its tail. `speed` = seconds per revolution.
struct BorderSweep: View {
    var cornerRadius: CGFloat = 24
    var lineWidth: CGFloat = 2.5
    var speed: Double = 6
    var autoStopAfter: Double? = nil   // nil = run forever; else fade out after N seconds

    @State private var spin = false
    @State private var faded = false

    // Stored with an explicit type — a bare 8-element Color literal inside the
    // AngularGradient call sends the type-checker into a long inference spiral.
    private static let sweepColors: [Color] = [
        .clear, .cyan, .mint, .yellow, .orange, .pink, .purple, .clear,
    ]

    var body: some View {
        AngularGradient(colors: Self.sweepColors, center: .center)
            .scaleEffect(1.8)   // keep corners covered while rotating
            .rotationEffect(.degrees(spin ? 360 : 0))
            .animation(.linear(duration: speed).repeatForever(autoreverses: false), value: spin)
            .mask(RoundedRectangle(cornerRadius: cornerRadius).strokeBorder(lineWidth: lineWidth))
            .opacity(faded ? 0 : 1)
            .allowsHitTesting(false)
            .onAppear {
                spin = true
                if let t = autoStopAfter {
                    DispatchQueue.main.asyncAfter(deadline: .now() + t) {
                        withAnimation(.easeOut(duration: 0.8)) { faded = true }
                    }
                }
            }
    }
}

struct EventCard: View {
    let event: CountdownEvent
    var urgency: CountdownEvent.UrgencyStage = .none

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
                Text(event.daysAway == 0
                     ? "at \(event.date.formatted(date: .omitted, time: .shortened)) 🎉"
                     : event.captionText)
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
        .overlay {
            // Opt-in per event; urgency forces it on (and races) in the final stretch.
            if !event.isPast && (event.borderGlow || urgency >= .pulse) {
                // Opt-in glow greets for ~10s then rests; urgency keeps racing until acknowledged.
                BorderSweep(speed: urgency >= .pulse ? 1.5 : 6,
                            autoStopAfter: urgency >= .pulse ? nil : 10)
            }
        }
        .opacity(event.isPast ? 0.78 : 1)
        .shadow(color: event.colors[0].opacity(0.35), radius: 14, y: 8)
    }
}
