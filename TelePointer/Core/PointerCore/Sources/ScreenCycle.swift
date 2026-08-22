import CoreGraphics

func orderedLeftToRight(_ screenFrames: [CGRect]) -> [CGRect] {
    screenFrames.sorted { ($0.minX, $0.minY) < ($1.minX, $1.minY) }
}

func isCentered(_ point: CGPoint, in screenFrame: CGRect, tolerance: CGFloat) -> Bool {
    abs(point.x - screenFrame.midX) <= tolerance && abs(point.y - screenFrame.midY) <= tolerance
}

func targetFrame(for cursor: CGPoint, among screenFrames: [CGRect], centerTolerance: CGFloat) -> CGRect? {
    let ordered = orderedLeftToRight(screenFrames)

    let current = ordered.firstIndex { $0.contains(cursor) }
        ?? nearestIndex(to: cursor, among: ordered)

    guard let current else { return nil }
    guard isCentered(cursor, in: ordered[current], tolerance: centerTolerance) else { return ordered[current] }

    return ordered[(current + 1) % ordered.count]
}

private func nearestIndex(to point: CGPoint, among screenFrames: [CGRect]) -> Int? {
    screenFrames.indices.min {
        squaredDistance(from: point, to: screenFrames[$0]) < squaredDistance(from: point, to: screenFrames[$1])
    }
}

private func squaredDistance(from point: CGPoint, to frame: CGRect) -> CGFloat {
    let nearest = CGPoint(
        x: min(max(point.x, frame.minX), frame.maxX),
        y: min(max(point.y, frame.minY), frame.maxY)
    )

    return squaredDistance(nearest, point)
}
