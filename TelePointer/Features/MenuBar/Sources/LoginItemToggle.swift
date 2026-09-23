import AppKit
import LaunchAtLogin
import SwiftUI

struct LoginItemToggle: View {
    @State private var state = LoginItem.state

    var body: some View {
        Toggle(isOn: Binding(
            get: { state == .enabled },
            set: { setEnabled($0) }
        )) {
            Label("Open at Login", systemImage: "arrow.up.forward.app")
        }
        .onAppear { state = LoginItem.state }
    }

    private func setEnabled(_ isEnabled: Bool) {
        guard state != .requiresApproval else {
            LoginItem.openSystemSettings()
            return
        }

        do {
            try LoginItem.setEnabled(isEnabled)
        } catch {
            NSApp.activate()
            NSAlert(error: error).runModal()
        }

        state = LoginItem.state

        if state == .requiresApproval {
            LoginItem.openSystemSettings()
        }
    }
}
