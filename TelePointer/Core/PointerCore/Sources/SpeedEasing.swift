import CoreGraphics

public struct SpeedEasing: Equatable, Sendable, Codable {
    public static let `default` = SpeedEasing(
        first: CGPoint(x: 1.0 / 3, y: 0),
        second: CGPoint(x: 2.0 / 3, y: 1.0 / 3)
    )

    public private(set) var first: CGPoint
    public private(set) var second: CGPoint

    public init(first: CGPoint, second: CGPoint) {
        self.first = first.clampedToUnitSquare()
        self.second = second.clampedToUnitSquare()
    }

    public func value(at progress: Double) -> Double {
        sampleY(t(forX: progress.clamped(to: 0...1)))
    }

    private var cx: Double { 3 * Double(first.x) }
    private var bx: Double { 3 * Double(second.x - first.x) - cx }
    private var ax: Double { 1 - cx - bx }

    private var cy: Double { 3 * Double(first.y) }
    private var by: Double { 3 * Double(second.y - first.y) - cy }
    private var ay: Double { 1 - cy - by }

    private func sampleX(_ t: Double) -> Double { ((ax * t + bx) * t + cx) * t }
    private func sampleY(_ t: Double) -> Double { ((ay * t + by) * t + cy) * t }
    private func slopeX(_ t: Double) -> Double { (3 * ax * t + 2 * bx) * t + cx }

    private func t(forX x: Double) -> Double {
        let tolerance = 1e-7
        var t = x

        for _ in 0..<8 {
            let error = sampleX(t) - x
            guard abs(error) > tolerance else { return t }

            let slope = slopeX(t)
            guard abs(slope) > tolerance else { break }

            t -= error / slope
        }

        var low = 0.0
        var high = 1.0
        t = x

        for _ in 0..<24 {
            let sample = sampleX(t)
            guard abs(sample - x) > tolerance else { return t }

            if sample < x {
                low = t
            } else {
                high = t
            }
            t = (low + high) / 2
        }

        return t
    }
}

extension CGPoint {
    fileprivate func clampedToUnitSquare() -> CGPoint {
        CGPoint(x: x.clamped(to: 0...1), y: y.clamped(to: 0...1))
    }
}
