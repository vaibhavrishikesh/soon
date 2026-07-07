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

/// Stage 3: the card breaks loose — a bold pill pops in with a spring, breathes
/// for attention, and drifts around the whole app until the user taps it.
struct RoamingCard: View {
    let event: CountdownEvent
    let acknowledge: () -> Void

    @State private var pos = CGPoint(x: 160, y: 200)
    @State private var pop = false        // spring entrance
    @State private var breathe = false    // continuous attention pulse
    @State private var wiggle = false     // frantic "look at me!" shake
    private let driftTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            Button(action: acknowledge) {
                HStack(spacing: 11) {
                    Image(systemName: event.symbol)
                        .font(.title3.bold())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title).font(.subheadline.bold()).lineLimit(1)
                        if event.date > Date() {
                            Text(timerInterval: Date()...event.date, countsDown: true)
                                .font(.headline.monospacedDigit().bold())
                        }
                        Text("almost time — tap me! 👆")
                            .font(.system(size: 10, weight: .semibold)).opacity(0.9)
                    }
                }
                .foregroundStyle(.white)
                .padding(.vertical, 12).padding(.horizontal, 18)
                .background(event.gradient, in: Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.35), lineWidth: 1))
                .overlay(BorderSweep(cornerRadius: 40, lineWidth: 2.5, speed: 1.0))
                .shadow(color: event.colors[0].opacity(0.7), radius: 20, y: 8)
                .scaleEffect(pop ? 1.0 : 0.3)               // entrance
                .scaleEffect(breathe ? 1.09 : 0.97)         // urgent throb
                .rotationEffect(.degrees(wiggle ? 4 : -4))  // frantic waving
                .opacity(pop ? 1 : 0)
            }
            .position(pos)
            .onAppear {
                pos = CGPoint(x: geo.size.width / 2, y: 170)
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                withAnimation(.spring(response: 0.32, dampingFraction: 0.5)) { pop = true }
                withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true).delay(0.3)) {
                    breathe = true
                }
                withAnimation(.easeInOut(duration: 0.13).repeatForever(autoreverses: true)) {
                    wiggle = true
                }
            }
            .onReceive(driftTimer) { _ in
                let minX: CGFloat = 100
                let maxX = max(minX + 20, geo.size.width - 100)
                let minY: CGFloat = 140
                let maxY = max(minY + 40, geo.size.height - 180)
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    pos = CGPoint(x: .random(in: minX...maxX), y: .random(in: minY...maxY))
                }
            }
        }
    }
}
