import SwiftUI
import UIKit

/// Escalating attention animation for a card in its final stretch:
/// pulse (heartbeat scale) → jump (periodic spring bounce + haptic).
/// Crucially it STOPS the moment the stage drops (acknowledged tap, or the
/// event's time passing), so a card never keeps twitching after it's over.
struct UrgencyEffect: ViewModifier {
    let stage: CountdownEvent.UrgencyStage

    @State private var pulsing = false
    @State private var jumping = false
    private let jumpTimer = Timer.publish(every: 3.2, on: .main, in: .common).autoconnect()

    func body(content: Content) -> some View {
        content
            .scaleEffect(pulsing ? 1.03 : 1.0)
            .offset(y: jumping ? -14 : 0)
            .rotationEffect(.degrees(jumping ? 2 : 0))
            .onAppear { syncPulse() }
            .onChange(of: stage) { _, _ in syncPulse() }
            .onReceive(jumpTimer) { _ in
                guard stage >= .jump else { return }
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                withAnimation(.spring(response: 0.22, dampingFraction: 0.35)) { jumping = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) { jumping = false }
                }
            }
    }

    /// Start the repeating pulse when urgent; hard-stop it otherwise.
    private func syncPulse() {
        if stage >= .pulse {
            guard !pulsing else { return }
            withAnimation(.easeInOut(duration: 0.65).repeatForever(autoreverses: true)) { pulsing = true }
        } else if pulsing {
            // Non-repeating animation cancels the repeatForever and settles at 1.0.
            withAnimation(.easeOut(duration: 0.2)) { pulsing = false }
            jumping = false
        }
    }
}

extension View {
    func urgency(_ stage: CountdownEvent.UrgencyStage) -> some View {
        modifier(UrgencyEffect(stage: stage))
    }
}

/// Stage 3: final minutes — a WhatsApp-style circular bubble parks in the
/// trailing thumb zone (no random drift). Pulse + live timer; tap opens detail.
struct RoamingCard: View {
    let event: CountdownEvent
    let acknowledge: () -> Void

    @State private var pop = false
    @State private var breathe = false

    private let bubble: CGFloat = 72

    var body: some View {
        GeometryReader { geo in
            Button(action: acknowledge) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(event.gradient)
                            .frame(width: bubble, height: bubble)
                            .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 1.5))
                            .overlay(BorderSweep(cornerRadius: bubble / 2, lineWidth: 2.5, speed: 1.0))
                            .shadow(color: event.colors[0].opacity(0.65), radius: 16, y: 6)

                        VStack(spacing: 2) {
                            Image(systemName: event.symbol)
                                .font(.system(size: 22, weight: .bold))
                            if event.date > Date() {
                                Text(timerInterval: Date()...event.date, countsDown: true)
                                    .font(.system(size: 9, weight: .bold).monospacedDigit())
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(width: bubble - 12)
                    }
                    .scaleEffect(pop ? 1.0 : 0.25)
                    .scaleEffect(breathe ? 1.06 : 1.0)
                    .opacity(pop ? 1 : 0)

                    Text(event.title)
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: Capsule())
                        .opacity(pop ? 1 : 0)

                    Text("almost time — tap me")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.85))
                        .opacity(pop ? 1 : 0)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(event.title), almost time, tap to open")
            // Trailing thumb zone — clear of status bar and bottom FAB/ad chrome.
            .position(
                x: geo.size.width - (bubble / 2) - 18,
                y: min(max(geo.size.height * 0.42, 160), geo.size.height - 220)
            )
            .onAppear {
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                withAnimation(.spring(response: 0.5, dampingFraction: 0.55)) { pop = true }
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true).delay(0.55)) {
                    breathe = true
                }
            }
        }
        .allowsHitTesting(true)
    }
}
