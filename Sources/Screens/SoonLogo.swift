import SwiftUI

/// Brand wordmark for the home nav bar — a gradient hourglass badge + "Soon".
struct SoonLogo: View {
    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "hourglass.bottomhalf.filled")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(Palette.gradient(0), in: RoundedRectangle(cornerRadius: 8))
            Text("Soon")
                .font(.system(size: 21, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
        }
        .accessibilityAddTraits(.isHeader)
    }
}
