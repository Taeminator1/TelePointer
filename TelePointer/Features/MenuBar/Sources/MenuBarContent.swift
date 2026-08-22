import KeyboardShortcuts
import PointerCore
import Settings
import SwiftUI

public struct MenuBarContent: View {
    @Environment(\.openWindow) private var openWindow

    public init() {}

    public var body: some View {
        Button("Move Pointer") {
            PointerMover.cycleScreenCenter()
        }
        .globalKeyboardShortcut(.movePointer)

        AccessibilityPermissionItem()

        LoginItemToggle()

        Button("Keyboard Shortcuts…") {
            NSApp.unhide(nil)
            openWindow(id: ShortcutSettings.windowID)
            NSApp.activate()
        }

        Divider()

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
