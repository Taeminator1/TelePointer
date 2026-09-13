import SwiftUI

public struct GeneralSettings: View {
    public init() {}

    public var body: some View {
        Form {
            Button("Import Settings…") {
                SettingsTransfer.importFromFile()
            }

            Button("Export Settings…") {
                SettingsTransfer.exportToFile()
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    GeneralSettings()
}
