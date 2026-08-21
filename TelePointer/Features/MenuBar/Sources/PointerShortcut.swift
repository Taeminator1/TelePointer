import AppKit
import KeyboardShortcuts
import PointerCore

@MainActor
public enum PointerShortcut {
    public static func registerHandler() {
        KeyboardShortcuts.onKeyDown(for: .movePointer) {
            PointerMover.moveToScreenCenter()
        }
    }
}

extension KeyboardShortcuts.Name {
    static let movePointer = Self(
        "movePointer",
        initial: .init(.c, modifiers: [.control, .option, .command])
    )
}
