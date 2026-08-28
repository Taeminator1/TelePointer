import PointerCore
import SwiftUI

struct SpeedGraph: View {
    /// 그래프로는 가속 모양만 바꾼다 — base · peak · rampDuration은 슬라이더가 소유한다
    private enum Handle: CaseIterable {
        case first
        case second
    }

    private static let height: CGFloat = 170

    /// 축 라벨이 들어갈 자리 — 아래쪽은 시간 라벨 한 줄, 왼쪽은 네 자리 속도 라벨
    private static let insets = EdgeInsets(top: 8, leading: 44, bottom: 20, trailing: 10)
    private static let grabRadius: CGFloat = 20

    @Binding var curve: SpeedCurve

    @State private var dragging: Handle?

    /// 축의 양 끝이 곧 곡선의 양 끝 — 램프의 시작점과 끝점이 좌측 하단 · 우측 상단 모서리에 닿는다
    private var timeRange: ClosedRange<Double> { 0...curve.rampDuration }
    private var speedRange: ClosedRange<Double> { curve.base...max(curve.peak, curve.base) }

    var body: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                let plot = Self.plot(in: size)

                drawAxes(&context, plot)
                drawCurve(&context, plot)
                drawHandles(&context, plot)
            }
            .gesture(drag(in: proxy.size))
        }
        .frame(height: Self.height)
        .accessibilityHidden(true)
    }

    // MARK: - 그리기

    private func drawAxes(_ context: inout GraphicsContext, _ plot: CGRect) {
        context.stroke(
            Path(roundedRect: plot, cornerRadius: 6),
            with: .color(.secondary.opacity(0.25)),
            lineWidth: 1
        )

        for speed in Self.ticks(over: speedRange) {
            let y = position(time: 0, speed: speed, in: plot).y

            if speed > speedRange.lowerBound, speed < speedRange.upperBound {
                drawGridLine(&context, from: CGPoint(x: plot.minX, y: y), to: CGPoint(x: plot.maxX, y: y))
            }

            context.draw(
                label("\(Int(speed))"),
                at: CGPoint(x: plot.minX - 6, y: y),
                anchor: .trailing
            )
        }

        let times = Self.ticks(over: timeRange)
        for (index, time) in times.enumerated() {
            let x = position(time: time, speed: curve.base, in: plot).x
            let isFirst = index == 0
            let isLast = index == times.count - 1

            // 양 끝의 눈금선은 그래프 테두리와 겹친다
            if !isFirst, !isLast {
                drawGridLine(&context, from: CGPoint(x: x, y: plot.minY), to: CGPoint(x: x, y: plot.maxY))
            }

            // 양 끝 라벨을 가운데 정렬하면 절반이 캔버스 밖으로 나간다 — 축 안쪽으로 붙인다
            let anchor: UnitPoint =
                if isFirst { .topLeading } else if isLast { .topTrailing } else { .top }

            context.draw(
                label(isFirst || isLast ? "\(Self.text(for: time)) s" : Self.text(for: time)),
                at: CGPoint(x: x, y: plot.maxY + 5),
                anchor: anchor
            )
        }
    }

    private func drawGridLine(_ context: inout GraphicsContext, from: CGPoint, to: CGPoint) {
        context.stroke(
            Path { $0.addLines([from, to]) },
            with: .color(.secondary.opacity(0.12)),
            lineWidth: 1
        )
    }

    /// 축 구간이 값에 따라 변하므로 눈금 간격도 매번 고른다 — 1 · 2 · 5의 10의 거듭제곱 배.
    /// 2.5배는 두지 않는다 — 시간축에서 0.025처럼 라벨이 소수점 세 자리로 늘어난다.
    /// 양 끝은 곡선이 닿는 지점이라 반올림하지 않고 그대로 남기고, 거기 붙는 눈금은 라벨이 겹쳐 버린다
    private static func ticks(over range: ClosedRange<Double>, count: Double = 4) -> [Double] {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return [range.lowerBound] }

        let rough = span / count
        let magnitude = pow(10, log10(rough).rounded(.down))
        let step: Double = switch rough / magnitude {
        case ...1: 1
        case ...2: 2
        case ...5: 5
        default: 10
        }

        let interval = step * magnitude
        let margin = span * 0.15
        let inner = stride(
            from: (range.lowerBound / interval).rounded(.up) * interval,
            to: range.upperBound,
            by: interval
        )
        .filter { $0 > range.lowerBound + margin && $0 < range.upperBound - margin }

        return [range.lowerBound] + inner + [range.upperBound]
    }

    private static func text(for time: Double) -> String {
        time.formatted(.number.precision(.fractionLength(0...2)))
    }

    private func drawCurve(_ context: inout GraphicsContext, _ plot: CGRect) {
        let start = position(time: 0, speed: curve.base, in: plot)
        let end = position(time: curve.rampDuration, speed: curve.peak, in: plot)
        let ramp = Path {
            $0.move(to: start)
            $0.addCurve(
                to: end,
                control1: control(curve.easing.first, in: plot),
                control2: control(curve.easing.second, in: plot)
            )
        }

        context.fill(
            Path {
                $0.addPath(ramp)
                $0.addLine(to: CGPoint(x: end.x, y: plot.maxY))
                $0.addLine(to: CGPoint(x: start.x, y: plot.maxY))
                $0.closeSubpath()
            },
            with: .color(.accentColor.opacity(0.12))
        )

        context.stroke(
            ramp,
            with: .color(.accentColor),
            style: StrokeStyle(lineWidth: 2, lineCap: .round)
        )
    }

    private func drawHandles(_ context: inout GraphicsContext, _ plot: CGRect) {
        let anchors: [(CGPoint, Handle)] = [
            (position(time: 0, speed: curve.base, in: plot), .first),
            (position(time: curve.rampDuration, speed: curve.peak, in: plot), .second),
        ]

        for (anchor, handle) in anchors {
            context.stroke(
                Path { $0.addLines([anchor, position(of: handle, in: plot)]) },
                with: .color(.secondary.opacity(0.5)),
                style: StrokeStyle(lineWidth: 1, dash: [2, 2])
            )
        }

        for handle in Handle.allCases {
            let radius: CGFloat = dragging == handle ? 7 : 5
            let center = position(of: handle, in: plot)
            let circle = Path(
                ellipseIn: CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )
            )

            context.fill(circle, with: .color(Color(nsColor: .controlBackgroundColor)))
            context.stroke(circle, with: .color(.accentColor), lineWidth: 2)
        }
    }

    private func label(_ text: String) -> Text {
        Text(text)
            .font(.caption2)
            .foregroundStyle(.secondary)
    }

    // MARK: - 드래그

    private func drag(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let plot = Self.plot(in: size)

                guard let handle = dragging ?? nearestHandle(to: value.startLocation, in: plot) else {
                    return
                }

                dragging = handle
                move(handle, to: value.location, in: plot)
            }
            .onEnded { _ in dragging = nil }
    }

    private func nearestHandle(to point: CGPoint, in plot: CGRect) -> Handle? {
        Handle.allCases
            .map { ($0, distance(from: point, to: position(of: $0, in: plot))) }
            .filter { $0.1 <= Self.grabRadius }
            .min { $0.1 < $1.1 }?
            .0
    }

    private func move(_ handle: Handle, to point: CGPoint, in plot: CGRect) {
        let unit = unitPoint(of: point, in: plot)

        switch handle {
        case .first:
            curve.easing = SpeedEasing(first: unit, second: curve.easing.second)
        case .second:
            curve.easing = SpeedEasing(first: curve.easing.first, second: unit)
        }
    }

    // MARK: - 좌표 변환

    private static func plot(in size: CGSize) -> CGRect {
        CGRect(
            x: insets.leading,
            y: insets.top,
            width: max(size.width - insets.leading - insets.trailing, 1),
            height: max(size.height - insets.top - insets.bottom, 1)
        )
    }

    private func position(time: Double, speed: Double, in plot: CGRect) -> CGPoint {
        CGPoint(
            x: plot.minX + plot.width * (time - timeRange.lowerBound) / Self.span(of: timeRange),
            y: plot.maxY - plot.height * (speed - speedRange.lowerBound) / Self.span(of: speedRange)
        )
    }

    /// peak를 base까지 내리면 속도 구간이 0이 된다 — 0으로 나누지 않는다
    private static func span(of range: ClosedRange<Double>) -> Double {
        max(range.upperBound - range.lowerBound, 1e-6)
    }

    private func position(of handle: Handle, in plot: CGRect) -> CGPoint {
        switch handle {
        case .first: control(curve.easing.first, in: plot)
        case .second: control(curve.easing.second, in: plot)
        }
    }

    /// 단위 공간의 제어점을 램프 구간 안의 (시간, 속도)로 펼친다
    private func control(_ unit: CGPoint, in plot: CGRect) -> CGPoint {
        position(
            time: curve.rampDuration * Double(unit.x),
            speed: curve.base + (curve.peak - curve.base) * Double(unit.y),
            in: plot
        )
    }

    private func unitPoint(of point: CGPoint, in plot: CGRect) -> CGPoint {
        let span = curve.peak - curve.base

        return CGPoint(
            x: curve.rampDuration > 0 ? time(atX: point.x, in: plot) / curve.rampDuration : 0,
            y: span > 0 ? (speed(atY: point.y, in: plot) - curve.base) / span : 0
        )
    }

    private func time(atX x: CGFloat, in plot: CGRect) -> Double {
        timeRange.lowerBound + Double((x - plot.minX) / plot.width) * Self.span(of: timeRange)
    }

    private func speed(atY y: CGFloat, in plot: CGRect) -> Double {
        speedRange.lowerBound + Double((plot.maxY - y) / plot.height) * Self.span(of: speedRange)
    }

    private func distance(from a: CGPoint, to b: CGPoint) -> CGFloat {
        hypot(a.x - b.x, a.y - b.y)
    }
}
