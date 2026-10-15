import AppKit

@MainActor
public final class DirectionalMover {
    public struct Tuning {
        public var tick: Duration
        public var holdLimit: Double
        public var turnDuration: Double
        public var turnSlowdown: Double
        public var steadyModifier: NSEvent.ModifierFlags

        public init(
            tick: Duration = .milliseconds(8),
            holdLimit: Double = 5,
            turnDuration: Double = 0.08,
            turnSlowdown: Double = 0.8,
            steadyModifier: NSEvent.ModifierFlags = .command
        ) {
            self.tick = tick
            self.holdLimit = holdLimit
            self.turnDuration = turnDuration
            self.turnSlowdown = turnSlowdown
            self.steadyModifier = steadyModifier
        }
    }

    private let tuning: Tuning
    private let settings: SpeedStore
    private let experiments: ExperimentStore

    private var active: [Direction: NSEvent.ModifierFlags] = [:]
    private var position: CGPoint?
    private var warpFrames: [CGRect] = []
    private var curve: SpeedCurve = .default
    private var steady: Double = SteadySpeed.default
    private var smoothTurning = SmoothTurning.default
    private var slowOnTurn = SlowOnTurn.default
    private var noHoldLimit = false
    private var heading: CGVector?
    private var offset = CGVector.zero
    private var offsetVelocity = CGVector.zero
    private var repeater: Task<Void, Never>?
    private var generation = 0

    public init(
        tuning: Tuning = Tuning(),
        settings: SpeedStore = .shared,
        experiments: ExperimentStore = .shared
    ) {
        self.tuning = tuning
        self.settings = settings
        self.experiments = experiments
    }

    public func press(_ direction: Direction, requiredModifiers: NSEvent.ModifierFlags) {
        if active.isEmpty {
            position = PointerMover.currentLocation()
            warpFrames = PointerMover.screenWarpFrames()
            curve = settings.curve
            steady = settings.steadySpeed
            smoothTurning = experiments.smoothTurning
            slowOnTurn = experiments.slowOnTurn
            noHoldLimit = experiments.noHoldLimit
        }

        active[direction] = requiredModifiers.subtracting(tuning.steadyModifier)

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

    public func releaseHeld() {
        guard !active.isEmpty else { return }

        stop()
    }

    private func stop() {
        generation += 1
        repeater?.cancel()
        repeater = nil
        active.removeAll()
        position = nil
        heading = nil
        offset = .zero
        offsetVelocity = .zero
    }

    private func run(token: Int) async {
        let clock = ContinuousClock()
        let began = clock.now
        var previous = began
        var ramped = 0.0
        var lastTarget: CGVector?
        var sinceTurn: Double?

        while !Task.isCancelled {
            active = active.filter { modifiersHeld($0.value) }
            guard !active.isEmpty else { break }

            let now = clock.now
            guard noHoldLimit || seconds(from: began, to: now) < tuning.holdLimit else { break }

            let delta = seconds(from: previous, to: now)
            previous = now

            let target = normalizedVector(of: Set(active.keys))
            sinceTurn = sinceTurn.map { $0 + delta }
            if let lastTarget, lastTarget != target {
                switch slowOnTurn {
                case .off: break
                case .dip: sinceTurn = 0
                case .restartRamp: ramped = 0
                }
            }
            lastTarget = target

            var speed: Double
            if modifiersHeld(tuning.steadyModifier) {
                ramped = 0
                speed = steady
            } else {
                ramped += delta
                speed = curve.speed(at: ramped)
            }

            if let sinceTurn {
                speed *= slowdown(at: sinceTurn)
            }

            let displacement = turn(toward: target, speed: speed, over: delta)
            step(displacement)

            try? await Task.sleep(for: tuning.tick)
        }

        if token == generation {
            stop()
        }
    }

    private func slowdown(at elapsed: Double) -> Double {
        let progress = elapsed / tuning.turnDuration
        return 1 - tuning.turnSlowdown * progress * exp(1 - progress)
    }

    private func turn(toward target: CGVector, speed: Double, over delta: Double) -> CGVector {
        switch smoothTurning {
        case .off:
            CGVector(dx: target.dx * speed * delta, dy: target.dy * speed * delta)
        case .headingBlend:
            blendHeading(toward: target, speed: speed, over: delta)
        case .overshootReturn:
            returnOvershoot(toward: target, speed: speed, over: delta)
        }
    }

    private func blendHeading(toward target: CGVector, speed: Double, over delta: Double) -> CGVector {
        let turned: CGVector
        if let current = heading {
            let blend = 1 - exp(-delta / tuning.turnDuration)
            turned = CGVector(
                dx: current.dx + (target.dx - current.dx) * blend,
                dy: current.dy + (target.dy - current.dy) * blend
            )
        } else {
            turned = target
        }

        heading = turned
        return CGVector(dx: turned.dx * speed * delta, dy: turned.dy * speed * delta)
    }

    private func returnOvershoot(toward target: CGVector, speed: Double, over delta: Double) -> CGVector {
        let ideal = CGVector(dx: target.dx * speed * delta, dy: target.dy * speed * delta)

        if let previous = heading {
            offsetVelocity.dx -= (target.dx - previous.dx) * speed
            offsetVelocity.dy -= (target.dy - previous.dy) * speed
        }
        heading = target

        let (dx, vx) = settle(offset.dx, velocity: offsetVelocity.dx, over: delta)
        let (dy, vy) = settle(offset.dy, velocity: offsetVelocity.dy, over: delta)
        let moved = CGVector(dx: dx - offset.dx, dy: dy - offset.dy)

        offset = CGVector(dx: dx, dy: dy)
        offsetVelocity = CGVector(dx: vx, dy: vy)

        return CGVector(dx: ideal.dx + moved.dx, dy: ideal.dy + moved.dy)
    }

    private func settle(_ offset: Double, velocity: Double, over delta: Double) -> (Double, Double) {
        let rate = 1 / tuning.turnDuration
        let decay = exp(-rate * delta)
        let carry = velocity + rate * offset

        return ((offset + carry * delta) * decay, (velocity - rate * carry * delta) * decay)
    }

    private func step(_ displacement: CGVector) {
        guard !PointerMover.isScrolling else {
            PointerMover.scroll(by: displacement)
            return
        }

        guard let current = position else { return }

        let moved = CGPoint(
            x: current.x + displacement.dx,
            y: current.y + displacement.dy
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
