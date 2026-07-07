import SwiftUI
import UIKit

/// Escalating attention animation for a card in its final stretch:
/// pulse (heartbeat scale) → jump (periodic spring bounce + haptic).
struct UrgencyEffect: ViewModifier {
    let stage: CountdownEvent.UrgencyStage

    @State private var pulsing = false
    @State private var jumping = false
    private let jumpTimer = Timer.publish(every: 3.2, on: .main, in: .common).autoconnect()

    func body(content: Content) -> some View {
        content
            .scaleEffect(stage >= .pulse && pulsing ? 1.02 : 1.0)
            .offset(y: jumping ? -14 : 0)
            .rotationEffect(.degrees(jumping ? 2 : 0))
            .onAppear {
                guard stage >= .pulse else { return }
                withAnimation(.easeInOut(duration: 0.65).repeatForever(autoreverses: true)) {
                    pulsing = true
                }
            }
            .onReceive(jumpTimer) { _ in
                guard stage >= .jump else { return }
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                withAnimation(.spring(response: 0.22, dampingFraction: 0.35)) { jumping = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) { jumping = false }
                }
            }
    }
}

extension View {
    func urgency(_ stage: CountdownEvent.UrgencyStage) -> some View {
        modifier(UrgencyEffect(stage: stage))
    }
}

/// Stage 3: the card breaks loose — a compact version drifts around the whole
/// app, ticking, until the user taps it (acknowledge).
struct RoamingCard: View {
    let event: CountdownEvent
    let acknowledge: () -> Void

    @State private var pos = CGPoint(x: 140, y: 220)
    private let driftTimer = Timer.publish(every: 2.4, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            Button(action: acknowledge) {
                HStack(spacing: 10) {
                    Image(systemName: event.symbol).font(.headline)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(event.title).font(.subheadline.bold()).lineLimit(1)
                        if event.date > Date() {
                            Text(timerInterval: Date()...event.date, countsDown: true)
                                .font(.caption.monospacedDigit().bold())
                        }
                        Text("It's almost time — tap me!")
                            .font(.system(size: 9, weight: .semibold)).opacity(0.85)
                    }
                }
                .foregroundStyle(.white)
                .padding(.vertical, 10).padding(.horizontal, 14)
                .background(event.gradient, in: Capsule())
                .overlay(BorderSweep(cornerRadius: 26, lineWidth: 2, speed: 1.2))
                .shadow(color: event.colors[0].opacity(0.6), radius: 14, y: 6)
            }
            .position(pos)
            .onAppear {
                pos = CGPoint(x: geo.size.width / 2, y: 160)
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            }
            .onReceive(driftTimer) { _ in
                let minX: CGFloat = 90
                let maxX: CGFloat = max(minX + 20, geo.size.width - 90)
                let minY: CGFloat = 130
                let maxY: CGFloat = max(minY + 40, geo.size.height - 170)
                let x = CGFloat.random(in: minX...maxX)
                let y = CGFloat.random(in: minY...maxY)
                withAnimation(.easeInOut(duration: 2.2)) { pos = CGPoint(x: x, y: y) }
            }
        }
    }
}
