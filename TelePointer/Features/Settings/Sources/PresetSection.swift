import SwiftUI

struct PresetSection: View {
    private static let rowHeight: CGFloat = 24
    private static let nameWidth: CGFloat = 150
    private static let barButtonSize = CGSize(width: 24, height: 20)

    let store: PresetStore

    @State private var selection: Preset.ID?

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
                        store.add()
                    }

                    Divider()
                        .frame(height: 12)

                    // TODO: preset 삭제
                    barButton("minus") {}
                        .disabled(true)
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
                        Text(preset.name)
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
