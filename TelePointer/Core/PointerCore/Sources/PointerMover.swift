import AppKit

@MainActor
public enum PointerMover {
    public static func moveToScreenCenter() {
        guard let primaryScreen = NSScreen.screens.first else { return }

        let cursor = NSEvent.mouseLocation
        let targetScreen = NSScreen.screens.first { $0.frame.contains(cursor) } ?? primaryScreen

        move(
            to: warpPoint(
                centerOf: targetScreen.frame,
                primaryScreenHeight: primaryScreen.frame.height
            )
        )
    }

    static func move(to point: CGPoint) {
        CGWarpMouseCursorPosition(point)
    }

    static func currentLocation() -> CGPoint? {
        CGEvent(source: nil)?.location
    }

    static func screenWarpFrames() -> [CGRect] {
        guard let primaryScreen = NSScreen.screens.first else { return [] }

        return NSScreen.screens.map {
            warpFrame(of: $0.frame, primaryScreenHeight: primaryScreen.frame.height)
        }
    }
}