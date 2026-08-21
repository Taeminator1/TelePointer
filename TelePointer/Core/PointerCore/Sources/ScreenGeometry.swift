import CoreGraphics

public func warpPoint(centerOf screenFrame: CGRect, primaryScreenHeight: CGFloat) -> CGPoint {
    CGPoint(
        x: screenFrame.midX,
        y: primaryScreenHeight - screenFrame.midY
    )
}
