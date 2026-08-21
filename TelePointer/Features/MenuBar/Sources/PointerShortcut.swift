import AppKit
import KeyboardShortcuts

public extension KeyboardShortcuts.Name {
    static let movePointer = Self(
        "movePointer",
        initial: .init(.c, modifiers: [.control, .option, .command])
    )
}
