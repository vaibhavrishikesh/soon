import SwiftUI

/// Brand wordmark for the home nav bar — hourglass + gradient "Soon".
struct SoonLogo: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "hourglass")
                .font(.system(size: 16, weight: .bold))
            Text("Soon")
                .font(.system(size: 20, weight: .heavy, design: .rounded))
        }
        .foregroundStyle(Palette.gradient(0))
        .accessibilityAddTraits(.isHeader)
    }
}
