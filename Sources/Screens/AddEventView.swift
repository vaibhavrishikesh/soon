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
    @State private var borderGlow: Bool
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
        let presets = Self.makePresets()
        self.datePresets = presets
        let defaultDate = presets.first { $0.label == "Next Week" }?.target
            ?? Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        _title = State(initialValue: editing?.title ?? "")
        _date = State(initialValue: editing?.date ?? defaultDate)
        _symbol = State(initialValue: editing?.symbol ?? "sparkles")
        _colorIndex = State(initialValue: editing?.colorIndex ?? 0)
        _remindDayBefore = State(initialValue: editing?.remindDayBefore ?? false)
        // New events default to an on-the-day reminder — a countdown you never
        // hear from isn't doing its job (real users missed the toggle entirely).
        _remindOnDay = State(initialValue: editing?.remindOnDay ?? true)
        _borderGlow = State(initialValue: editing?.borderGlow ?? false)
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
                        whenSection
                        reminders
                        effects
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
                                        date: date, symbol: symbol, colorIndex: colorIndex,
                                        borderGlow: borderGlow))
            .allowsHitTesting(false)
            .id(borderGlow)   // restart the sweep when toggled so the preview reflects it
    }

    private func field<Content: View>(_ label: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased()).font(.caption.bold()).foregroundStyle(Theme.textDim)
            content()
                .padding(14)
                .background(Theme.card, in: RoundedRectangle(cornerRadius: 14))
        }
    }

    // Quick date presets — most countdowns are "N days/weeks away", so offer
    // one-tap choices instead of making everyone spin the date wheel.
    private struct DatePreset: Identifiable { let id = UUID(); let label: String; let target: Date }
    private let datePresets: [DatePreset]

    // Real-world anchors people actually count down to. Computed once at init so
    // the selected chip stays highlighted (no drift).
    private static func makePresets() -> [DatePreset] {
        let cal = Calendar.current
        let now = Date()
        func add(_ c: Calendar.Component, _ n: Int) -> Date { cal.date(byAdding: c, value: n, to: now) ?? now }
        let eightToday = cal.date(bySettingHour: 20, minute: 0, second: 0, of: now) ?? now
        let tonight = eightToday.timeIntervalSince(now) > 1800
            ? eightToday
            : (cal.date(bySettingHour: 20, minute: 0, second: 0, of: add(.day, 1)) ?? add(.day, 1))
        let saturday = cal.nextDate(after: now, matching: DateComponents(hour: 12, weekday: 7),
                                    matchingPolicy: .nextTime) ?? add(.day, 3)
        let newYear = cal.nextDate(after: now, matching: DateComponents(month: 1, day: 1, hour: 0),
                                   matchingPolicy: .nextTime) ?? add(.year, 1)
        return [
            DatePreset(label: "Tonight",      target: tonight),
            DatePreset(label: "Tomorrow",     target: add(.day, 1)),
            DatePreset(label: "This Weekend", target: saturday),
            DatePreset(label: "Next Week",    target: add(.day, 7)),
            DatePreset(label: "2 Weeks",      target: add(.day, 14)),
            DatePreset(label: "1 Month",      target: add(.month, 1)),
            DatePreset(label: "3 Months",     target: add(.month, 3)),
            DatePreset(label: "6 Months",     target: add(.month, 6)),
            DatePreset(label: "New Year",     target: newYear),
        ]
    }

    private var whenSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WHEN").font(.caption.bold()).foregroundStyle(Theme.textDim)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(datePresets) { p in
                        let selected = date == p.target
                        Button {
                            date = p.target
                        } label: {
                            Text(p.label)
                                .font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                                .padding(.horizontal, 14).padding(.vertical, 9)
                                .background(selected ? AnyShapeStyle(Palette.gradient(colorIndex))
                                                     : AnyShapeStyle(Theme.card),
                                            in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
            DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                .labelsHidden().datePickerStyle(.compact)
                .tint(Palette.colors(colorIndex)[0])
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

    private var effects: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("EFFECTS").font(.caption.bold()).foregroundStyle(Theme.textDim)
            VStack(alignment: .leading, spacing: 6) {
                Toggle("✨ Animated glow border", isOn: $borderGlow)
                    .tint(Palette.colors(colorIndex)[0])
                    .foregroundStyle(.white)
                Text("Adds a moving rainbow ring around this countdown's card.")
                    .font(.caption2).foregroundStyle(Theme.textDim)
            }
            .padding(14)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 14))
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
                if e.date != date { e.urgencyAcknowledged = false }   // new moment = new urgency
                e.title = trimmed; e.date = date; e.symbol = symbol; e.colorIndex = colorIndex
                e.remindDayBefore = remindDayBefore; e.remindOnDay = remindOnDay
                e.borderGlow = borderGlow
                store.update(e)
            } else {
                store.add(CountdownEvent(title: trimmed, date: date, symbol: symbol, colorIndex: colorIndex,
                                         remindDayBefore: remindDayBefore, remindOnDay: remindOnDay,
                                         borderGlow: borderGlow))
            }
            dismiss()
        }
    }
}
