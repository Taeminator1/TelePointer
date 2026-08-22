import AppKit

@MainActor
public enum PointerMover {
    private static let doubleClickRadius: CGFloat = 5

    private static var lastClick: (at: ContinuousClock.Instant, point: CGPoint, button: CGMouseButton, state: Int64)?

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

    public static func clickLeft() {
        click(down: .leftMouseDown, up: .leftMouseUp, button: .left)
    }

    public static func clickRight() {
        click(down: .rightMouseDown, up: .rightMouseUp, button: .right)
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

    private static func click(down: CGEventType, up: CGEventType, button: CGMouseButton) {
        guard let location = currentLocation() else { return }

        let state = clickState(for: button, at: location)
        post(down, button: button, state: state, at: location)
        post(up, button: button, state: state, at: location)
    }

    private static func clickState(for button: CGMouseButton, at point: CGPoint) -> Int64 {
        let now = ContinuousClock.now
        let state: Int64

        if let last = lastClick,
           last.button == button,
           now - last.at < .seconds(NSEvent.doubleClickInterval),
           abs(point.x - last.point.x) < doubleClickRadius,
           abs(point.y - last.point.y) < doubleClickRadius {
            state = last.state + 1
        } else {
            state = 1
        }

        lastClick = (now, point, button, state)
        return state
    }

    private static func post(_ type: CGEventType, button: CGMouseButton, state: Int64, at point: CGPoint) {
        guard let event = CGEvent(
            mouseEventSource: nil,
            mouseType: type,
            mouseCursorPosition: point,
            mouseButton: button
        ) else { return }

        event.flags = []
        event.setIntegerValueField(.mouseEventClickState, value: state)
        event.post(tap: .cghidEventTap)
    }
}
