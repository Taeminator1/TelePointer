import CoreGraphics

func warpPoint(centerOf screenFrame: CGRect, primaryScreenHeight: CGFloat) -> CGPoint {
    CGPoint(
        x: screenFrame.midX,
        y: primaryScreenHeight - screenFrame.midY
    )
}

func warpFrame(of screenFrame: CGRect, primaryScreenHeight: CGFloat) -> CGRect {
    CGRect(
        x: screenFrame.minX,
        y: primaryScreenHeight - screenFrame.maxY,
        width: screenFrame.width,
        height: screenFrame.height
    )
}

func clamped(_ point: CGPoint, to warpFrames: [CGRect]) -> CGPoint {
    guard !warpFrames.isEmpty else { return point }
    guard !warpFrames.contains(where: { $0.contains(point) }) else { return point }

    let candidates = warpFrames.map { frame in
        CGPoint(
            x: min(max(point.x, frame.minX), frame.maxX - 1),
            y: min(max(point.y, frame.minY), frame.maxY - 1)
        )
    }

    return candidates.min {
        squaredDistance($0, point) < squaredDistance($1, point)
    } ?? point
}

func squaredDistance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
    let dx = a.x - b.x
    let dy = a.y - b.y
    return dx * dx + dy * dy
}
