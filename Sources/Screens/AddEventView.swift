import SwiftUI

struct AddEventView: View {
    @EnvironmentObject private var store: EventStore
    @Environment(\.dismiss) private var dismiss

    /// Existing event when editing; nil when adding.
    var editing: CountdownEvent?

    @State private var title: String
    @State private var date: Date
    @State private var symbol: String
    @State private var colorIndex: Int
    @State private var remindDayBefore: Bool
    @State private var remindOnDay: Bool
    @State private var permissionDenied = false
    @FocusState private var titleFocused: Bool

    private var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    private let symbols = [
        "sparkles", "birthday.cake.fill", "airplane", "heart.fill",
        "gift.fill", "graduationcap.fill", "star.fill", "calendar",
        "flag.fill", "figure.run", "house.fill", "music.note",
        "camera.fill", "leaf.fill", "gamecontroller.fill", "cup.and.saucer.fill",
    ]

    init(editing: CountdownEvent? = nil) {
        self.editing = editing
        _title = State(initialValue: editing?.title ?? "")
        _date = State(initialValue: editing?.date ?? Calendar.current.date(byAdding: .day, value: 7, to: Date())!)
        _symbol = State(initialValue: editing?.symbol ?? "sparkles")
        _colorIndex = State(initialValue: editing?.colorIndex ?? 0)
        _remindDayBefore = State(initialValue: editing?.remindDayBefore ?? false)
        // New events default to an on-the-day reminder — a countdown you never
        // hear from isn't doing its job (real users missed the toggle entirely).
        _remindOnDay = State(initialValue: editing?.remindOnDay ?? true)
    }

    private let cols = [GridItem(.adaptive(minimum: 52), spacing: 12)]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        preview
                        field("Name") {
                            TextField("e.g. Goa Trip", text: $title)
                                .textInputAutocapitalization(.words)
                                .foregroundStyle(.white)
                                .focused($titleFocused)
                                .submitLabel(.done)
                                .onSubmit { titleFocused = false }
                        }
                        field("Date & time") {
                            DatePicker("", selection: $date,
                                       displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden().datePickerStyle(.compact)
                                .tint(Palette.colors(colorIndex)[0])
                        }
                        reminders
                        symbolPicker
                        colorPicker
                    }
                    .padding(18)
                    .padding(.bottom, 30)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .contentShape(Rectangle())
            .onTapGesture { titleFocused = false }
            .navigationTitle(editing == nil ? "New Countdown" : "Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.card, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.body.weight(.semibold)).tint(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: save) {
                        Text("Save").font(.body.bold()).foregroundStyle(.white)
                            .padding(.horizontal, 16).padding(.vertical, 7)
                            .background(canSave ? AnyShapeStyle(Palette.gradient(colorIndex))
                                                : AnyShapeStyle(Color.white.opacity(0.18)),
                                        in: Capsule())
                    }
                    .disabled(!canSave)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { titleFocused = false }.font(.body.bold())
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    private var preview: some View {
        EventCard(event: CountdownEvent(title: title.isEmpty ? "Your event" : title,
                                        date: date, symbol: symbol, colorIndex: colorIndex))
            .allowsHitTesting(false)
    }

    private func field<Content: View>(_ label: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased()).font(.caption.bold()).foregroundStyle(Theme.textDim)
            content()
                .padding(14)
                .background(Theme.card, in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private var symbolPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ICON").font(.caption.bold()).foregroundStyle(Theme.textDim)
            LazyVGrid(columns: cols, spacing: 12) {
                ForEach(symbols, id: \.self) { s in
                    Image(systemName: s)
                        .font(.title3).foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(symbol == s ? AnyShapeStyle(Palette.gradient(colorIndex)) : AnyShapeStyle(Theme.card),
                                    in: RoundedRectangle(cornerRadius: 14))
                        .onTapGesture { symbol = s }
                }
            }
        }
    }

    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("COLOR").font(.caption.bold()).foregroundStyle(Theme.textDim)
            LazyVGrid(columns: cols, spacing: 12) {
                ForEach(Palette.gradients.indices, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Palette.gradient(i))
                        .frame(width: 52, height: 52)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(.white, lineWidth: colorIndex == i ? 3 : 0)
                        )
                        .onTapGesture { colorIndex = i }
                }
            }
        }
    }

    private var reminders: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("REMINDERS").font(.caption.bold()).foregroundStyle(Theme.textDim)
            VStack(spacing: 12) {
                Toggle("Remind a day before", isOn: $remindDayBefore)
                    .onChange(of: remindDayBefore) { _, on in if on { requestPermission() } }
                Toggle("Remind on the day", isOn: $remindOnDay)
                    .onChange(of: remindOnDay) { _, on in if on { requestPermission() } }
            }
            .tint(Palette.colors(colorIndex)[0])
            .foregroundStyle(.white)
            .padding(14)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 14))
            if permissionDenied {
                Text("Notifications are off for Soon — enable them in Settings to get reminders.")
                    .font(.caption2).foregroundStyle(.orange)
            }
        }
    }

    private func requestPermission() {
        Task {
            let granted = await NotificationManager.requestAuthorizationIfNeeded()
            permissionDenied = !granted
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        Task {
            // Reminders are on by default, so the user may never touch the toggle —
            // make sure permission is requested before the first schedule.
            if remindDayBefore || remindOnDay {
                await NotificationManager.requestAuthorizationIfNeeded()
            }
            if var e = editing {
                e.title = trimmed; e.date = date; e.symbol = symbol; e.colorIndex = colorIndex
                e.remindDayBefore = remindDayBefore; e.remindOnDay = remindOnDay
                store.update(e)
            } else {
                store.add(CountdownEvent(title: trimmed, date: date, symbol: symbol, colorIndex: colorIndex,
                                         remindDayBefore: remindDayBefore, remindOnDay: remindOnDay))
            }
            dismiss()
        }
    }
}
