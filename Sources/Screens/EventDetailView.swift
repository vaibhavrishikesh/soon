import SwiftUI
import UIKit

struct EventDetailView: View {
    @EnvironmentObject private var store: EventStore
    @Environment(\.dismiss) private var dismiss
    let event: CountdownEvent

    @State private var showingEdit = false
    @State private var confirmDelete = false
    @State private var drift = false        // drives the animated background
    @State private var showConfetti = false
    @State private var shareImage: UIImage?

    /// Always read the freshest copy from the store (so edits reflect live).
    private var current: CountdownEvent {
        store.events.first { $0.id == event.id } ?? event
    }

    /// The exact moment of the event — what we tick toward.
    private var target: Date { current.date }

    var body: some View {
        ZStack {
            current.gradient.ignoresSafeArea()
            animatedBlobs
            Color.black.opacity(0.10).ignoresSafeArea()

            VStack(spacing: 14) {
                Spacer()
                Image(systemName: current.symbol)
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.95))

                countdownSection

                Text(current.title)
                    .font(.largeTitle.bold()).foregroundStyle(.white)
                    .multilineTextAlignment(.center).padding(.top, 8)
                Text(current.dateTimeText)
                    .font(.subheadline).foregroundStyle(.white.opacity(0.8))
                if current.hasReminder {
                    Label(reminderText, systemImage: "bell.fill")
                        .font(.caption).foregroundStyle(.white.opacity(0.85))
                        .padding(.top, 2)
                }

                Spacer()

                HStack(spacing: 12) {
                    actionButton("Edit", "pencil") { showingEdit = true }
                    shareButton
                    actionButton("Delete", "trash") { confirmDelete = true }
                }
                .padding(.bottom, 24)
            }
            .padding(28)

            if showConfetti { ConfettiView() }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) { drift = true }
            // Opening the detail counts as "seen it" — calm ALL urgency animations
            // (pulse/jump/roam) for this event once the user taps in.
            if current.urgencyStage() > .none { store.acknowledgeUrgency(current) }
            fireConfettiIfToday()
        }
        .task { shareImage = renderShareCard() }
        .sheet(isPresented: $showingEdit) { AddEventView(editing: current) }
        .confirmationDialog("Delete this countdown?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { store.delete(current); dismiss() }
        }
    }

    private var reminderText: String {
        if current.remindDayBefore && current.remindOnDay { return "Day before & on the day" }
        if current.remindDayBefore { return "Reminder: day before" }
        return "Reminder: on the day"
    }

    private var eventTimeText: String {
        current.date.formatted(date: .omitted, time: .shortened)
    }

    // MARK: Countdown states (re-evaluated every second, so "it's time" flips live)
    private var countdownSection: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            countdownContent(now: context.date)
        }
    }

    @ViewBuilder
    private func countdownContent(now: Date) -> some View {
        let isEventToday = Calendar.current.isDate(current.date, inSameDayAs: now)
        if target > now {
            // Counting down — to the exact moment.
            VStack(spacing: 14) {
                ticker(now: now)
                Text(isEventToday ? "today at \(eventTimeText)" : "until the big day")
                    .font(.subheadline.weight(.semibold)).foregroundStyle(.white.opacity(0.85))
            }
        } else if isEventToday {
            // The moment arrived today.
            VStack(spacing: 8) {
                Text("It's time!")
                    .font(.system(size: 60, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text("🎉 started at \(eventTimeText)")
                    .font(.title3.weight(.semibold)).foregroundStyle(.white.opacity(0.9))
            }
        } else {
            // Past — count up since the moment.
            VStack(spacing: 14) {
                ticker(now: now)
                Text("time since")
                    .font(.subheadline.weight(.semibold)).foregroundStyle(.white.opacity(0.85))
            }
        }
    }

    private func ticker(now: Date) -> some View {
        let p = parts(now: now)
        return HStack(spacing: 10) {
            unit(p.d, "DAYS")
            unit(p.h, "HRS")
            unit(p.m, "MIN")
            unit(p.s, "SEC")
        }
    }

    private func unit(_ value: Int, _ label: String) -> some View {
        VStack(spacing: 6) {
            Text(String(format: "%02d", value))
                .font(.system(size: 40, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
                .contentTransition(.numericText())
            Text(label)
                .font(.system(size: 11, weight: .bold)).foregroundStyle(.white.opacity(0.75))
        }
        .frame(width: 72, height: 86)
        .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 16))
    }

    private func parts(now: Date) -> (d: Int, h: Int, m: Int, s: Int) {
        var diff = Int(abs(target.timeIntervalSince(now)))
        let d = diff / 86400; diff %= 86400
        let h = diff / 3600;  diff %= 3600
        let m = diff / 60
        let s = diff % 60
        return (d, h, m, s)
    }

    // MARK: Animated background
    private var animatedBlobs: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: geo.size.width * 0.8)
                    .blur(radius: 60)
                    .offset(x: drift ? -90 : 80, y: drift ? -140 : -60)
                Circle()
                    .fill(.black.opacity(0.18))
                    .frame(width: geo.size.width * 0.7)
                    .blur(radius: 70)
                    .offset(x: drift ? 110 : -70, y: drift ? 200 : 120)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func actionButton(_ title: String, _ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.headline).foregroundStyle(.white)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: Share as image
    @ViewBuilder
    private var shareButton: some View {
        if let ui = shareImage {
            ShareLink(item: Image(uiImage: ui),
                      preview: SharePreview(current.title, image: Image(uiImage: ui))) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .font(.headline).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    @MainActor
    private func renderShareCard() -> UIImage? {
        let renderer = ImageRenderer(content: ShareCardView(event: current))
        renderer.proposedSize = ProposedViewSize(width: 1080, height: 1350)
        renderer.scale = 1
        return renderer.uiImage
    }

    // MARK: Confetti
    private func fireConfettiIfToday() {
        let now = Date()
        let isToday = Calendar.current.isDate(current.date, inSameDayAs: now)
        guard isToday, !showConfetti else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        showConfetti = true
        Task {
            try? await Task.sleep(for: .seconds(3.5))
            showConfetti = false
        }
    }
}
