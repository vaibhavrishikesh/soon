import SwiftUI

extension Color {
    init(hex: UInt) {
        self.init(.sRGB,
                  red:   Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8)  & 0xFF) / 255,
                  blue:  Double( hex        & 0xFF) / 255,
                  opacity: 1)
    }
}

enum Theme {
    static let bg      = Color(hex: 0x0E0E14)
    static let card    = Color(hex: 0x191921)
    static let textDim = Color.white.opacity(0.55)

    /// Medium "dusk" app background — muted purple (not black, not white) with
    /// soft indigo/pink glows so the colorful cards pop.
    static var background: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0x514A74), Color(hex: 0x353051)],
                           startPoint: .top, endPoint: .bottom)
            RadialGradient(colors: [Color(hex: 0x8A78FF).opacity(0.28), .clear],
                           center: .topLeading, startRadius: 0, endRadius: 560)
            RadialGradient(colors: [Color(hex: 0xF06BD0).opacity(0.16), .clear],
                           center: .bottomTrailing, startRadius: 0, endRadius: 480)
        }
        .ignoresSafeArea()
    }
}

/// Gradient palette used for event cards. Index wraps around.
enum Palette {
    static let gradients: [[Color]] = [
        [Color(hex: 0x6D5BFF), Color(hex: 0xA15BFF)],
        [Color(hex: 0xFF6B6B), Color(hex: 0xFF3D77)],
        [Color(hex: 0xFF9F43), Color(hex: 0xFF5E62)],
        [Color(hex: 0x12C2E9), Color(hex: 0x2D6CFF)],
        [Color(hex: 0x11998E), Color(hex: 0x38EF7D)],
        [Color(hex: 0xEC38BC), Color(hex: 0x7303C0)],
        [Color(hex: 0xF7971E), Color(hex: 0xFFD200)],
        [Color(hex: 0x355C7D), Color(hex: 0xC06C84)],
    ]

    static func colors(_ i: Int) -> [Color] {
        let n = gradients.count
        return gradients[((i % n) + n) % n]
    }

    static func gradient(_ i: Int) -> LinearGradient {
        LinearGradient(colors: colors(i), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
