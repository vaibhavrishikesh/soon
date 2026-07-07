import SwiftUI

/// A one-shot confetti burst: pieces rain from the top with random drift/spin.
/// Purely decorative — add/remove the view to fire it.
struct ConfettiView: View {
    private struct Piece: Identifiable {
        let id: Int
        let xFraction: CGFloat   // 0...1 across the width
        let delay: Double
        let duration: Double
        let color: Color
        let width: CGFloat
        let spin: Double
    }

    private static let palette: [Color] = [
        .cyan, .mint, .yellow, .orange, .pink, .purple, .red, .blue,
    ]

    private let pieces: [Piece]
    @State private var fall = false

    init(count: Int = 36) {
        pieces = (0..<count).map { i in
            Piece(id: i,
                  xFraction: CGFloat.random(in: 0.03...0.97),
                  delay: Double.random(in: 0...0.5),
                  duration: Double.random(in: 1.6...2.8),
                  color: Self.palette[i % Self.palette.count],
                  width: CGFloat.random(in: 8...14),
                  spin: Double.random(in: 360...1080))
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { p in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(p.color)
                        .frame(width: p.width, height: p.width * 0.5)
                        .rotationEffect(.degrees(fall ? p.spin : 0))
                        .position(x: p.xFraction * geo.size.width,
                                  y: fall ? geo.size.height + 30 : -30)
                        .animation(.easeIn(duration: p.duration).delay(p.delay), value: fall)
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { fall = true }
    }
}
