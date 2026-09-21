import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: EventStore
    @State private var showingAdd = false
    @State private var showingWidgetGuide = false
    @State private var path = NavigationPath()
    @AppStorage("widgetPromoDismissed") private var widgetPromoDismissed = false

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Theme.background

                if store.events.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        // Re-evaluate urgency stages every 15s so cards escalate live.
                        TimelineView(.periodic(from: .now, by: 15)) { context in
                            LazyVStack(spacing: 16) {
                                if !widgetPromoDismissed && !StoreShots.enabled {
                                    WidgetPromoCard(
                                        onOpen: { showingWidgetGuide = true },
                                        onDismiss: { withAnimation { widgetPromoDismissed = true } })
                                }
                                ForEach(store.sorted) { event in
                                    EventRow(event: event, now: context.date)
                                }
                            }
                            .padding(.horizontal, 18)
                            .padding(.top, 6)
                            // Room for trailing circular FAB (ad sits in safeAreaInset below).
                            .padding(.bottom, 88)
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { SoonLogo() } }
            .navigationDestination(for: CountdownEvent.self) { EventDetailView(event: $0) }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingWidgetGuide = true } label: {
                        Image(systemName: "square.grid.2x2")
                            .font(.subheadline.bold())
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: {
                        Image(systemName: "plus")
                            .font(.headline.bold())
                    }
                }
            }
            // WhatsApp-style FAB: trailing circle above the banner — never overlaps the ad.
            .overlay(alignment: .bottomTrailing) { addButton }
            .safeAreaInset(edge: .bottom) {
                if !StoreShots.enabled {
                    AdBannerView()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEventView()
            }
            .sheet(isPresented: $showingWidgetGuide) {
                WidgetGuideView(sampleEvent: store.sorted.first)
            }
            .onAppear { applyStoreShotsLanding() }
        }
        .tint(.white)
        // Stage 3: final-minutes bubble (hidden on detail/add store-shot screens).
        .overlay {
            if shouldShowRoamOverlay {
                roamOverlay
            }
        }
    }

    private var shouldShowRoamOverlay: Bool {
        guard StoreShots.enabled else { return true }
        // Only show roam bubble when capturing the roam / home / urgency list shots.
        switch StoreShots.screen {
        case "roam", "urgency", "home": return true
        default: return false
        }
    }

    private var roamOverlay: some View {
        TimelineView(.periodic(from: .now, by: 10)) { context in
            if let loose = roamingEvent(asOf: context.date) {
                RoamingCard(event: loose) {
                    store.acknowledgeUrgency(loose)
                    path.append(loose)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private func roamingEvent(asOf now: Date) -> CountdownEvent? {
        store.events.first { $0.urgencyStage(asOf: now) == .roam }
    }

    /// Trailing circular + — sits in the thumb zone, clear of the AdMob banner.
    private var addButton: some View {
        Button { showingAdd = true } label: {
            Image(systemName: "plus")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(Palette.gradient(0), in: Circle())
                .shadow(color: Palette.colors(0)[0].opacity(0.55), radius: 14, y: 6)
                .accessibilityLabel("New countdown")
        }
        .padding(.trailing, 20)
        .padding(.bottom, 16)
        .opacity(store.events.isEmpty ? 0 : 1)
        .allowsHitTesting(!store.events.isEmpty)
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

    private func applyStoreShotsLanding() {
        guard StoreShots.enabled else { return }
        widgetPromoDismissed = true
        switch StoreShots.screen {
        case "detail":
            // Multi-day animated ticker (Goa Trip ≈ 5 days).
            if let e = store.sorted.first(where: { $0.title == "Goa Trip" }) ?? store.sorted.first {
                path = NavigationPath(); path.append(e)
            }
        case "today":
            // 00 DAYS live ticker + confetti — pick "Date Night" (today).
            if let e = store.events.first(where: { $0.title == "Date Night" })
                ?? store.sorted.first(where: { Calendar.current.isDateInToday($0.date) }) {
                path = NavigationPath(); path.append(e)
            }
        case "add":
            showingAdd = true
        case "widgets":
            showingWidgetGuide = true
        case "urgency", "roam", "home":
            break // list: Flight Home pulses; Testing (≤3 min) shows roaming overlay
        default:
            break
        }
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
