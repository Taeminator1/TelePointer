import KeyboardShortcuts
import PointerCore
import Settings
import SwiftUI

public struct MenuBarContent: View {
    @Environment(\.openWindow) private var openWindow

    public init() {}

    public var body: some View {
        AccessibilityPermissionItem()
        LoginItemToggle()
        
        Divider()
        
        Button {
            PointerMover.cycleScreenCenter()
        } label: {
            Label("Move Pointer", systemImage: "pointer.arrow.and.square.on.square.dashed")
        }
        .globalKeyboardShortcut(.movePointer)

        settingsButton("Settings…", systemImage: "gearshape", windowID: AppSettings.windowID)

        Divider()

        Button {
            SettingsTransfer.importFromFile()
        } label: {
            Label("Import Settings…", systemImage: "square.and.arrow.down")
        }

        Button {
            SettingsTransfer.exportToFile()
        } label: {
            Label("Export Settings…", systemImage: "square.and.arrow.up")
        }

        Divider()

        Button {
            NSApplication.shared.terminate(nil)
        } label: {
            Label("Quit", systemImage: "xmark.rectangle")
        }
        .keyboardShortcut("q")
    }

    private func settingsButton(
        _ title: LocalizedStringKey,
        systemImage: String,
        windowID: String
    ) -> some View {
        Button {
            NSApp.unhide(nil)
            openWindow(id: windowID)
            NSApp.activate(ignoringOtherApps: true)
        } label: {
            Label(title, systemImage: systemImage)
        }
    }
}
