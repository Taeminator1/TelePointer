import AppKit

@MainActor
public enum PointerMover {
    public static func moveToScreenCenter() {
        guard let primaryScreen = NSScreen.screens.first else { return }

        let cursor = NSEvent.mouseLocation
        let targetScreen = NSScreen.screens.first { $0.frame.contains(cursor) } ?? primaryScreen

        CGWarpMouseCursorPosition(
            warpPoint(
                centerOf: targetScreen.frame,
                primaryScreenHeight: primaryScreen.frame.height
            )
        )
    }
}
