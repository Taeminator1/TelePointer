import PointerCore
import SwiftUI

struct SpeedSection: View {
    private static let valueWidth: CGFloat = 72

    @Bindable var settings: SpeedSettings

    var body: some View {
        SpeedGraph(curve: $settings.curve)

        slider(
            "Base Speed",
            value: $settings.curve.base,
            in: SpeedCurve.baseRange,
            step: 50,
            format: .speed
        )

        slider(
            "Peak Speed",
            value: $settings.curve.peak,
            in: SpeedCurve.peakRange,
            step: 50,
            format: .speed
        )

        slider(
            "Ramp Duration",
            value: $settings.curve.rampDuration,
            in: SpeedCurve.rampDurationRange,
            step: 0.05,
            format: .duration
        )
    }

    private func slider(
        _ title: LocalizedStringKey,
        value: Binding<Double>,
        in range: ClosedRange<Double>,
        step: Double,
        format: ValueFormat
    ) -> some View {
        LabeledContent(title) {
            HStack(spacing: 8) {
                Slider(value: value.snapped(to: step), in: range)

                Text(format.string(for: value.wrappedValue))
                    .font(.callout)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .frame(width: Self.valueWidth, alignment: .trailing)
            }
        }
    }
}

extension Binding<Double> {
    /// `Slider(step:)`은 스냅과 함께 스냅 지점마다 눈금 점을 그린다 — 점 없이 스냅만 남긴다
    fileprivate func snapped(to step: Double) -> Binding<Double> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = ($0 / step).rounded() * step }
        )
    }
}

private enum ValueFormat {
    case speed
    case duration

    func string(for value: Double) -> String {
        switch self {
        case .speed: "\(Int(value.rounded())) pt/s"
        case .duration: String(format: "%.2f s", value)
        }
    }
}

#Preview {
    Form {
        Section("Speed") {
            SpeedSection(settings: SpeedSettings(defaults: .standard))
        }
    }
    .formStyle(.grouped)
    .frame(width: 420)
}
