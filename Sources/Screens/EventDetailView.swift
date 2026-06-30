import SwiftUI

struct EventDetailView: View {
    @EnvironmentObject private var store: EventStore
    @Environment(\.dismiss) private var dismiss
    let event: CountdownEvent

    @State private var showingEdit = false
    @State private var confirmDelete = false
    @State private var drift = false        // drives the animated background

    /// Always read the freshest copy from the store (so edits reflect live).
    private var current: CountdownEvent {
        store.events.first { $0.id == event.id } ?? event
    }

    /// Midnight of the event day — what we tick toward.
    private var target: Date { Calendar.current.startOfDay(for: current.date) }

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

                if current.daysAway == 0 {
                    Text("Today")
                        .font(.system(size: 72, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text("happening today 🎉")
                        .font(.title3.weight(.semibold)).foregroundStyle(.white.opacity(0.9))
                } else {
                    liveTicker
                    Text(current.isPast ? "time since" : "until the big day")
                        .font(.subheadline.weight(.semibold)).foregroundStyle(.white.opacity(0.85))
                }

                Text(current.title)
                    .font(.largeTitle.bold()).foregroundStyle(.white)
                    .multilineTextAlignment(.center).padding(.top, 8)
                Text(current.dateTimeText)
                    .font(.subheadline).foregroundStyle(.white.opacity(0.8))
                if current.hasReminder {
                    Label(current.remindDayBefore && current.remindOnDay ? "Day before & on the day"
                          : current.remindDayBefore ? "Reminder: day before" : "Reminder: on the day",
                          systemImage: "bell.fill")
                        .font(.caption).foregroundStyle(.white.opacity(0.85))
                        .padding(.top, 2)
                }

                Spacer()

                HStack(spacing: 12) {
                    actionButton("Edit", "pencil") { showingEdit = true }
                    actionButton("Delete", "trash") { confirmDelete = true }
                }
                .padding(.bottom, 24)
            }
            .padding(28)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear { withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) { drift = true } }
        .sheet(isPresented: $showingEdit) { AddEventView(editing: current) }
        .confirmationDialog("Delete this countdown?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { store.delete(current); dismiss() }
        }
    }

    // MARK: Live ticking D : H : M : S
    private var liveTicker: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let p = parts(now: context.date)
            HStack(spacing: 10) {
                unit(p.d, "DAYS")
                unit(p.h, "HRS")
                unit(p.m, "MIN")
                unit(p.s, "SEC")
            }
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
}
