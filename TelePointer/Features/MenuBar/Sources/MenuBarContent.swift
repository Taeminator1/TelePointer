import KeyboardShortcuts
import PointerCore
import SwiftUI

public struct MenuBarContent: View {
    public init() {}

    public var body: some View {
        Button("Move Pointer") {
            PointerMover.moveToScreenCenter()
        }
        .globalKeyboardShortcut(.movePointer)

        LoginItemToggle()

        Divider()

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
