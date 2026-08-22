import AppKit
import KeyboardShortcuts

private let pointerModifiers: NSEvent.ModifierFlags = [.control, .option]

extension KeyboardShortcuts.Name {
    public static let movePointer = Self(
        "movePointer",
        initial: .init(.c, modifiers: pointerModifiers)
    )

    public static let clickPointerLeft = Self(
        "clickPointerLeft",
        initial: .init(.x, modifiers: pointerModifiers)
    )

    public static let clickPointerRight = Self(
        "clickPointerRight",
        initial: .init(.v, modifiers: pointerModifiers)
    )

    public static let movePointerUp = Self(
        "movePointerUp",
        initial: .init(.i, modifiers: pointerModifiers)
    )

    public static let movePointerLeft = Self(
        "movePointerLeft",
        initial: .init(.j, modifiers: pointerModifiers)
    )

    public static let movePointerDown = Self(
        "movePointerDown",
        initial: .init(.k, modifiers: pointerModifiers)
    )

    public static let movePointerRight = Self(
        "movePointerRight",
        initial: .init(.l, modifiers: pointerModifiers)
    )
}
