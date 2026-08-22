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

    public static func registerHandler() {
        KeyboardShortcuts.onKeyDown(for: .movePointer) {
            PointerMover.moveToScreenCenter()
        }

        KeyboardShortcuts.onKeyDown(for: .clickPointerLeft) {
            PointerMover.clickLeft()
        }

        KeyboardShortcuts.onKeyDown(for: .clickPointerRight) {
            PointerMover.clickRight()
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
    }
}

private let directionModifiers: NSEvent.ModifierFlags = [.control, .option]

extension KeyboardShortcuts.Name {
    static let movePointer = Self(
        "movePointer",
        initial: .init(.c, modifiers: [.control, .option, .command])
    )

    static let clickPointerLeft = Self(
        "clickPointerLeft",
        initial: .init(.u, modifiers: directionModifiers)
    )

    static let clickPointerRight = Self(
        "clickPointerRight",
        initial: .init(.o, modifiers: directionModifiers)
    )

    static let movePointerUp = Self(
        "movePointerUp",
        initial: .init(.i, modifiers: directionModifiers)
    )

    static let movePointerLeft = Self(
        "movePointerLeft",
        initial: .init(.j, modifiers: directionModifiers)
    )

    static let movePointerDown = Self(
        "movePointerDown",
        initial: .init(.k, modifiers: directionModifiers)
    )

    static let movePointerRight = Self(
        "movePointerRight",
        initial: .init(.l, modifiers: directionModifiers)
    )
}
