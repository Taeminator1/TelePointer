import AppKit
import KeyboardShortcuts
import PointerCore

@MainActor
public enum PointerShortcut {
    private static let mover = DirectionalMover()

    private static let directions: [(name: KeyboardShortcuts.Name, direction: Direction)] = [
        (.movePointerUp, .up),
        (.movePointerLeft, .left),
        (.movePointerDown, .down),
        (.movePointerRight, .right),
    ]

    private static let buttons: [(name: KeyboardShortcuts.Name, button: PointerButton)] = [
        (.clickPointerLeft, .left),
        (.clickPointerRight, .right),
    ]

    public static func registerHandler() {
        KeyboardShortcuts.onKeyDown(for: .movePointer) {
            PointerMover.cycleScreenCenter()
        }

        for (name, button) in buttons {
            KeyboardShortcuts.onKeyDown(for: name) {
                PointerMover.press(
                    button,
                    requiredModifiers: KeyboardShortcuts.getShortcut(for: name)?.modifiers ?? []
                )
            }
            KeyboardShortcuts.onKeyUp(for: name) {
                PointerMover.release(button)
            }
        }

        for (name, direction) in directions {
            KeyboardShortcuts.onKeyDown(for: name) {
                mover.press(
                    direction,
                    requiredModifiers: KeyboardShortcuts.getShortcut(for: name)?.modifiers ?? []
                )
            }
            KeyboardShortcuts.onKeyUp(for: name) {
                mover.release(direction)
            }
        }

        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { _ in
            MainActor.assumeIsolated { PointerMover.releasePressed() }
        }
    }
}

private let pointerModifiers: NSEvent.ModifierFlags = [.control, .option]

extension KeyboardShortcuts.Name {
    static let movePointer = Self(
        "movePointer",
        initial: .init(.c, modifiers: pointerModifiers)
    )

    static let clickPointerLeft = Self(
        "clickPointerLeft",
        initial: .init(.x, modifiers: pointerModifiers)
    )

    static let clickPointerRight = Self(
        "clickPointerRight",
        initial: .init(.v, modifiers: pointerModifiers)
    )

    static let movePointerUp = Self(
        "movePointerUp",
        initial: .init(.i, modifiers: pointerModifiers)
    )

    static let movePointerLeft = Self(
        "movePointerLeft",
        initial: .init(.j, modifiers: pointerModifiers)
    )

    static let movePointerDown = Self(
        "movePointerDown",
        initial: .init(.k, modifiers: pointerModifiers)
    )

    static let movePointerRight = Self(
        "movePointerRight",
        initial: .init(.l, modifiers: pointerModifiers)
    )
}
