import SwiftUI

/// In-app guide for adding the Soon widget — iOS has no API to place a widget
/// programmatically, so the next best thing: a preview + dead-simple steps.
struct WidgetGuideView: View {
    @Environment(\.dismiss) private var dismiss
    let sampleEvent: CountdownEvent?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 26) {
                        header
                        widgetPreview
                        stepsCard(title: "HOME SCREEN", steps: homeSteps)
                        stepsCard(title: "LOCK SCREEN (live timer!)", steps: lockSteps)
                    }
                    .padding(18)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Widgets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.bold().tint(.white)
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("Your countdown, always visible")
                .font(.title3.bold()).foregroundStyle(.white)
            Text("See the days tick down right on your Home and Lock Screen — no need to open the app.")
                .font(.subheadline).foregroundStyle(Theme.textDim)
                .multilineTextAlignment(.center)
        }
    }

    /// A faithful mock of the small home-screen widget, so users know what
    /// they're looking for in the gallery.
    private var widgetPreview: some View {
        let event = sampleEvent ?? CountdownEvent(
            title: "Goa Trip", date: Date().addingTimeInterval(5 * 86400),
            symbol: "airplane", colorIndex: 3)
        return VStack(alignment: .leading, spacing: 2) {
            Image(systemName: event.symbol).font(.title3.bold())
            Spacer(minLength: 4)
            Text(event.countText)
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .minimumScaleFactor(0.4).lineLimit(1)
            Text(event.captionText).font(.caption2.weight(.semibold)).opacity(0.9)
            Text(event.title).font(.footnote.bold()).lineLimit(1).opacity(0.95)
        }
        .foregroundStyle(.white)
        .padding(16)
        .frame(width: 158, height: 158, alignment: .leading)
        .background(event.gradient, in: RoundedRectangle(cornerRadius: 32))
        .shadow(color: event.colors[0].opacity(0.45), radius: 18, y: 10)
    }

    private var homeSteps: [String] {
        ["Long-press an empty spot on your Home Screen",
         "Tap Edit (top-left), then Add Widget ＋",
         "Search “Soon” and pick a size",
         "Tap Add Widget — done!"]
    }

    private var lockSteps: [String] {
        ["Long-press your Lock Screen, tap Customize",
         "Choose Lock Screen, tap the widget strip",
         "Pick Soon — the wide one ticks live to your event"]
    }

    private func stepsCard(title: String, steps: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.caption.bold()).foregroundStyle(Theme.textDim)
            ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(i + 1)")
                        .font(.footnote.bold()).foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Palette.gradient(0), in: Circle())
                    Text(step)
                        .font(.subheadline).foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(16)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 18))
    }
}

/// Dismissible nudge card shown at the top of the home list until acted on.
struct WidgetPromoCard: View {
    let onOpen: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "square.grid.2x2.fill")
                .font(.title3).foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text("Add the widget").font(.subheadline.bold()).foregroundStyle(.white)
                Text("Days tick down on your Home Screen")
                    .font(.caption).foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption.bold()).foregroundStyle(.white.opacity(0.8))
                    .padding(8).background(.white.opacity(0.15), in: Circle())
            }
        }
        .padding(14)
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.15), lineWidth: 1))
        .contentShape(Rectangle())
        .onTapGesture(perform: onOpen)
    }
}
