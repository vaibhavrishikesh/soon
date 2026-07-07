import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: EventStore
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background

                if store.events.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        // Re-evaluate urgency stages every 15s so cards escalate live.
                        TimelineView(.periodic(from: .now, by: 15)) { context in
                            LazyVStack(spacing: 16) {
                                ForEach(store.sorted) { event in
                                    EventRow(event: event, now: context.date)
                                }
                            }
                            .padding(.horizontal, 18)
                            .padding(.top, 6)
                            .padding(.bottom, 90)
                        }
                    }
                }
            }
            .navigationTitle("Soon")
            .navigationDestination(for: CountdownEvent.self) { EventDetailView(event: $0) }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: {
                        Image(systemName: "plus")
                            .font(.headline.bold())
                    }
                }
            }
            .overlay(alignment: .bottom) { addButton }
            .safeAreaInset(edge: .bottom) {
                AdBannerView()
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
            }
            .sheet(isPresented: $showingAdd) {
                AddEventView()
            }
        }
        .tint(.white)
        // Stage 3: a final-minutes card breaks loose and roams the whole app
        // (over every screen) until it's tapped.
        .overlay { roamOverlay }
    }

    private var roamOverlay: some View {
        TimelineView(.periodic(from: .now, by: 10)) { context in
            if let loose = roamingEvent(asOf: context.date) {
                RoamingCard(event: loose) { store.acknowledgeUrgency(loose) }
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private func roamingEvent(asOf now: Date) -> CountdownEvent? {
        store.events.first { $0.urgencyStage(asOf: now) == .roam }
    }

    private var addButton: some View {
        Button { showingAdd = true } label: {
            Label("New countdown", systemImage: "plus")
                .font(.headline).foregroundStyle(.white)
                .padding(.vertical, 15).frame(maxWidth: .infinity)
                .background(Palette.gradient(0), in: Capsule())
                .shadow(color: Palette.colors(0)[0].opacity(0.5), radius: 16, y: 8)
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 14)
        .opacity(store.events.isEmpty ? 0 : 1)
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "hourglass")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(Palette.gradient(0))
            Text("No countdowns yet")
                .font(.title2.bold()).foregroundStyle(.white)
            Text("Add the days you’re looking forward to —\ntrips, birthdays, deadlines.")
                .font(.subheadline).foregroundStyle(Theme.textDim)
                .multilineTextAlignment(.center)
            Button { showingAdd = true } label: {
                Label("Add your first", systemImage: "plus")
                    .font(.headline).foregroundStyle(.white)
                    .padding(.vertical, 14).padding(.horizontal, 24)
                    .background(Palette.gradient(0), in: Capsule())
            }
            .padding(.top, 4)
        }
        .padding(40)
    }
}

/// One home-list row — its own small view so the type-checker handles each row
/// body separately (a `let` + modifier chain inside ForEach blew up inference).
private struct EventRow: View {
    @EnvironmentObject private var store: EventStore
    let event: CountdownEvent
    let now: Date

    var body: some View {
        let stage: CountdownEvent.UrgencyStage = event.urgencyStage(asOf: now)
        NavigationLink(value: event) {
            EventCard(event: event, urgency: stage)
        }
        .buttonStyle(.plain)
        .urgency(stage)
        .contextMenu {
            Button(role: .destructive) {
                store.delete(event)
            } label: { Label("Delete", systemImage: "trash") }
        }
    }
}
