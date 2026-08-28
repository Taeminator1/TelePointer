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
        
        Button("Move Pointer") {
            PointerMover.cycleScreenCenter()
        }
        .globalKeyboardShortcut(.movePointer)

        settingsButton("Keyboard Shortcuts…", windowID: ShortcutSettings.windowID)
        settingsButton("Pointer Speed…", windowID: SpeedSettings.windowID)

        Divider()

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }

    private func settingsButton(_ title: LocalizedStringKey, windowID: String) -> some View {
        Button(title) {
            NSApp.unhide(nil)
            openWindow(id: windowID)
            NSApp.activate()
        }
    }
}
