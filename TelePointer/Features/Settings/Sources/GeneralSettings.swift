import SwiftUI

struct GeneralSettings: View {
    var body: some View {
        Form {
            Section {
                LabeledContent("Import Settings") {
                    Button("Import…") {
                        SettingsTransfer.importFromFile()
                    }
                }

                LabeledContent("Export Settings") {
                    Button("Export…") {
                        SettingsTransfer.exportToFile()
                    }
                }
            }

            PresetSection(store: .shared)
        }
        .formStyle(.grouped)
    }
}

#Preview {
    GeneralSettings()
}
