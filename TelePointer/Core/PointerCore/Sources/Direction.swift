import CoreGraphics

public enum Direction {
    case up
    case down
    case left
    case right

    var unit: CGVector {
        switch self {
        case .up: CGVector(dx: 0, dy: -1)
        case .down: CGVector(dx: 0, dy: 1)
        case .left: CGVector(dx: -1, dy: 0)
        case .right: CGVector(dx: 1, dy: 0)
        }
    }
}

func normalizedVector(of directions: Set<Direction>) -> CGVector {
    let sum = directions.reduce(into: CGVector.zero) { result, direction in
        result.dx += direction.unit.dx
        result.dy += direction.unit.dy
    }

    let length = (sum.dx * sum.dx + sum.dy * sum.dy).squareRoot()
    guard length > 0 else { return .zero }

    return CGVector(dx: sum.dx / length, dy: sum.dy / length)
}
