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
                        LazyVStack(spacing: 16) {
                            ForEach(store.sorted) { event in
                                NavigationLink(value: event) {
                                    EventCard(event: event)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        store.delete(event)
                                    } label: { Label("Delete", systemImage: "trash") }
                                }
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 6)
                        .padding(.bottom, 90)
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
