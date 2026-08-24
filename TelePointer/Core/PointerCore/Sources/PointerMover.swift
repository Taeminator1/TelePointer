import AppKit

@MainActor
public enum PointerMover {
    private static let doubleClickRadius: CGFloat = 5
    private static let watchdogTick = Duration.milliseconds(50)

    private static var lastClick: (at: ContinuousClock.Instant, point: CGPoint, button: PointerButton, state: Int64)?
    private static var pressed: (button: PointerButton, state: Int64)?
    private static var watchdog: Task<Void, Never>?

    public static func cycleScreenCenter() {
        guard let primaryScreen = NSScreen.screens.first else { return }

        guard let target = targetFrame(
            for: NSEvent.mouseLocation,
            among: NSScreen.screens.map(\.frame)
        ) else { return }

        move(to: warpPoint(centerOf: target, primaryScreenHeight: primaryScreen.frame.height))
    }

    public static func press(_ button: PointerButton, requiredModifiers: NSEvent.ModifierFlags) {
        guard pressed == nil, let location = currentLocation() else { return }

        let state = clickState(for: button, at: location)
        pressed = (button, state)
        post(button.downType, button: button, state: state, at: location)

        watchdog = Task { await watchModifiers(requiredModifiers) }
    }

    public static func release(_ button: PointerButton) {
        guard let current = pressed, current.button == button else { return }

        watchdog?.cancel()
        watchdog = nil
        pressed = nil

        guard let location = currentLocation() else { return }
        post(button.upType, button: button, state: current.state, at: location)
    }

    public static func releasePressed() {
        guard let current = pressed else { return }

        release(current.button)
    }

    static func move(to point: CGPoint) {
        guard let current = pressed else {
            CGWarpMouseCursorPosition(point)
            return
        }

        post(current.button.draggedType, button: current.button, state: current.state, at: point)
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

    private static func watchModifiers(_ required: NSEvent.ModifierFlags) async {
        guard !required.isEmpty else { return }

        while !Task.isCancelled {
            try? await Task.sleep(for: watchdogTick)

            guard !Task.isCancelled else { return }

            guard modifiersHeld(required) else {
                releasePressed()
                return
            }
        }
    }

    private static func clickState(for button: PointerButton, at point: CGPoint) -> Int64 {
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

    private static func post(_ type: CGEventType, button: PointerButton, state: Int64, at point: CGPoint) {
        guard let event = CGEvent(
            mouseEventSource: nil,
            mouseType: type,
            mouseCursorPosition: point,
            mouseButton: button.cgButton
        ) else { return }

        event.flags = []
        event.setIntegerValueField(.mouseEventClickState, value: state)
        event.post(tap: .cghidEventTap)
    }
}
