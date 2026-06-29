import SwiftUI

struct EventDetailView: View {
    @EnvironmentObject private var store: EventStore
    @Environment(\.dismiss) private var dismiss
    let event: CountdownEvent

    @State private var showingEdit = false
    @State private var confirmDelete = false

    /// Always read the freshest copy from the store (so edits reflect live).
    private var current: CountdownEvent {
        store.events.first { $0.id == event.id } ?? event
    }

    var body: some View {
        ZStack {
            current.gradient.ignoresSafeArea()
            Color.black.opacity(0.12).ignoresSafeArea()

            VStack(spacing: 14) {
                Spacer()
                Image(systemName: current.symbol)
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.95))

                Text(current.countText)
                    .font(.system(size: current.daysAway == 0 ? 72 : 120, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.4).lineLimit(1)

                Text(current.captionText)
                    .font(.title3.weight(.semibold)).foregroundStyle(.white.opacity(0.9))

                Text(current.title)
                    .font(.largeTitle.bold()).foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)
                Text(current.dateText)
                    .font(.subheadline).foregroundStyle(.white.opacity(0.8))

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
        .sheet(isPresented: $showingEdit) { AddEventView(editing: current) }
        .confirmationDialog("Delete this countdown?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                store.delete(current); dismiss()
            }
        }
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
