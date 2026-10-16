import SwiftUI

struct PresetSection: View {
    private static let rowHeight: CGFloat = 24
    private static let nameWidth: CGFloat = 150
    private static let barButtonSize = CGSize(width: 24, height: 20)

    let store: PresetStore

    @State private var selection: Set<Preset.ID> = []
    @State private var renamingID: Preset.ID?
    @State private var draftName = ""
    @FocusState private var isNameFocused: Bool

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Presets")
                        .font(.body.weight(.semibold))

                    Text("The preset at the top is in use.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.top, 4)
                .padding(.bottom, 10)

                Divider()

                list

                Divider()

                HStack(spacing: 0) {
                    barButton("plus") {
                        add()
                    }

                    Divider()
                        .frame(height: 12)

                    barButton("minus") {
                        remove()
                    }
                    .disabled(selection.isEmpty)
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, -10)
            .padding(.vertical, -6)
        }
    }

    private func barButton(_ systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .frame(width: Self.barButtonSize.width, height: Self.barButtonSize.height)
                .contentShape(.rect)
        }
    }

    private func add() {
        let id = store.add()

        selection = [id]
        startRenaming(id)
    }

    private func remove() {
        store.remove(selection)
        selection = []
    }

    @ViewBuilder
    private func name(of preset: Preset) -> some View {
        if renamingID == preset.id {
            TextField("Name", text: $draftName)
                .textFieldStyle(.plain)
                .labelsHidden()
                .focused($isNameFocused)
                .onAppear { isNameFocused = true }
                .onSubmit(finishRenaming)
                .onExitCommand { renamingID = nil }
                .onChange(of: isNameFocused) { _, isFocused in
                    if !isFocused {
                        finishRenaming()
                    }
                }
        } else {
            Text(preset.name)
        }
    }

    private func startRenaming(_ id: Preset.ID) {
        guard let preset = store.presets.first(where: { $0.id == id }) else { return }

        draftName = preset.name
        renamingID = id
    }

    private func finishRenaming() {
        guard let id = renamingID else { return }

        store.rename(id, to: draftName)
        renamingID = nil
    }

    @ViewBuilder
    private var list: some View {
        if store.presets.isEmpty {
            Text("No Presets")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: Self.rowHeight)
        } else {
            List(selection: $selection) {
                ForEach(Array(store.presets.enumerated()), id: \.element.id) { index, preset in
                    HStack(spacing: 0) {
                        name(of: preset)
                            .frame(width: Self.nameWidth, alignment: .leading)

                        if index == 0 {
                            Text("In Use")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.leading, 4)
                    .frame(height: Self.rowHeight)
                    .listRowInsets(EdgeInsets())
                }
                .onMove(perform: store.move)
            }
            .contextMenu(forSelectionType: Preset.ID.self) { _ in
            } primaryAction: { ids in
                guard ids.count == 1, let id = ids.first else { return }

                startRenaming(id)
            }
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, Self.rowHeight)
            .alternatingRowBackgrounds()
            .scrollDisabled(true)
            .frame(height: CGFloat(store.presets.count) * Self.rowHeight)
        }
    }
}

#Preview {
    Form {
        PresetSection(store: PresetStore(defaults: UserDefaults(suiteName: "PresetSectionPreview")!))
    }
    .formStyle(.grouped)
}
