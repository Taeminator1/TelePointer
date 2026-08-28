import AppKit

@MainActor
public final class DirectionalMover {
    public struct Tuning {
        public var tick: Duration
        public var holdLimit: Double

        public init(
            tick: Duration = .milliseconds(8),
            holdLimit: Double = 5
        ) {
            self.tick = tick
            self.holdLimit = holdLimit
        }
    }

    private let tuning: Tuning
    private let settings: SpeedStore

    private var active: [Direction: NSEvent.ModifierFlags] = [:]
    private var position: CGPoint?
    private var warpFrames: [CGRect] = []
    private var curve: SpeedCurve = .default
    private var repeater: Task<Void, Never>?
    private var generation = 0

    public init(tuning: Tuning = Tuning(), settings: SpeedStore = .shared) {
        self.tuning = tuning
        self.settings = settings
    }

    public func press(_ direction: Direction, requiredModifiers: NSEvent.ModifierFlags) {
        if active.isEmpty {
            position = PointerMover.currentLocation()
            warpFrames = PointerMover.screenWarpFrames()
            curve = settings.curve
        }

        active[direction] = requiredModifiers

        guard repeater == nil else { return }

        generation += 1
        let token = generation
        repeater = Task { [weak self] in
            await self?.run(token: token)
        }
    }

    public func release(_ direction: Direction) {
        active.removeValue(forKey: direction)

        if active.isEmpty {
            stop()
        }
    }

    private func stop() {
        generation += 1
        repeater?.cancel()
        repeater = nil
        active.removeAll()
        position = nil
    }

    private func run(token: Int) async {
        let clock = ContinuousClock()
        let began = clock.now
        var previous = began

        while !Task.isCancelled {
            active = active.filter { modifiersHeld($0.value) }
            guard !active.isEmpty else { break }

            let now = clock.now
            let elapsed = seconds(from: began, to: now)
            guard elapsed < tuning.holdLimit else { break }

            let delta = seconds(from: previous, to: now)
            previous = now

            let speed = curve.speed(at: elapsed)

            step(normalizedVector(of: Set(active.keys)), distance: speed * delta)

            try? await Task.sleep(for: tuning.tick)
        }

        if token == generation {
            stop()
        }
    }

    private func step(_ vector: CGVector, distance: Double) {
        guard let current = position else { return }

        let moved = CGPoint(
            x: current.x + vector.dx * distance,
            y: current.y + vector.dy * distance
        )
        let target = clamped(moved, to: warpFrames)

        position = target
        PointerMover.move(to: target)
    }

    private func seconds(from start: ContinuousClock.Instant, to end: ContinuousClock.Instant) -> Double {
        let components = (end - start).components
        return Double(components.seconds) + Double(components.attoseconds) * 1e-18
    }
}
