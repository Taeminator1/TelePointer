import AppKit

@MainActor
public final class DirectionalMover {
    public struct Tuning {
        /// 포인터를 다시 그리는 주기
        public var tick: Duration

        /// 누른 직후의 속도
        public var baseSpeed: Double

        /// 도달 가능한 최고 속도
        public var peakSpeed: Double

        /// 최고 속도까지 걸리는 시간
        public var rampDuration: Double

        /// 강제 정지까지의 시간
        public var holdLimit: Double

        public init(
            tick: Duration = .milliseconds(8),
            baseSpeed: Double = 400,
            peakSpeed: Double = 2800,
            rampDuration: Double = 0.4,
            holdLimit: Double = 5
        ) {
            self.tick = tick
            self.baseSpeed = baseSpeed
            self.peakSpeed = peakSpeed
            self.rampDuration = rampDuration
            self.holdLimit = holdLimit
        }
    }

    private let tuning: Tuning

    private var active: [Direction: NSEvent.ModifierFlags] = [:]
    private var position: CGPoint?
    private var warpFrames: [CGRect] = []
    private var repeater: Task<Void, Never>?
    private var generation = 0

    public init(tuning: Tuning = Tuning()) {
        self.tuning = tuning
    }

    public func press(_ direction: Direction, requiredModifiers: NSEvent.ModifierFlags) {
        if active.isEmpty {
            position = PointerMover.currentLocation()
            warpFrames = PointerMover.screenWarpFrames()
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
            let flags = NSEvent.modifierFlags
            active = active.filter { flags.isSuperset(of: $0.value) }
            guard !active.isEmpty else { break }

            let now = clock.now
            let elapsed = seconds(from: began, to: now)
            guard elapsed < tuning.holdLimit else { break }

            let delta = seconds(from: previous, to: now)
            previous = now

            let speed = rampedSpeed(
                elapsed: elapsed,
                base: tuning.baseSpeed,
                peak: tuning.peakSpeed,
                rampDuration: tuning.rampDuration
            )

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
