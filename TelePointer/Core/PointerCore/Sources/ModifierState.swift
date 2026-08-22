import AppKit

private let modifierKeyCodes: [(flag: NSEvent.ModifierFlags, keys: [CGKeyCode])] = [
    (.control, [59, 62]),
    (.option, [58, 61]),
    (.shift, [56, 60]),
    (.command, [55, 54]),
]

func modifiersHeld(_ required: NSEvent.ModifierFlags) -> Bool {
    modifierKeyCodes
        .filter { required.contains($0.flag) }
        .allSatisfy { pair in
            pair.keys.contains { CGEventSource.keyState(.hidSystemState, key: $0) }
        }
}
