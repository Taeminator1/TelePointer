import AppKit
import KeyboardShortcuts
import PointerCore
import Settings

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
