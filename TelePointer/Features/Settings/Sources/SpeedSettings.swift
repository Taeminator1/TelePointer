import AppKit
import PointerCore
import SwiftUI

public struct SpeedSettings: View {
    public static let windowID = "speedSettings"

    @Environment(\.dismiss) private var dismiss

    @Bindable private var settings: SpeedStore

    public init(settings: SpeedStore = .shared) {
        self.settings = settings
    }

    public var body: some View {
        VStack(spacing: 0) {
            Form {
                Section("Pointer Speed") {
                    SpeedGraph(curve: $settings.curve)

                    // 트랙은 절대 범위로 고정하고 벽만 좁힌다 —
                    // 트랙이 바뀌면 값이 그대로인 슬라이더의 노브도 미끄러진다
                    slider(
                        "Base Speed",
                        value: $settings.curve.base,
                        in: SpeedCurve.baseRange,
                        limitedTo: settings.curve.allowedBaseRange,
                        step: 50
                    )

                    slider(
                        "Peak Speed",
                        value: $settings.curve.peak,
                        in: SpeedCurve.peakRange,
                        limitedTo: settings.curve.allowedPeakRange,
                        step: 50
                    )

                    slider(
                        "Ramp Duration",
                        value: $settings.curve.rampDuration,
                        in: SpeedCurve.rampDurationRange,
                        step: 0.05
                    )
                }
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            .fixedSize(horizontal: false, vertical: true)

            Divider()

            HStack {
                Button("Restore Defaults") {
                    settings.reset()
                }

                Spacer()

                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(16)
        }
        .frame(width: 400)
        .settingsWindowChrome()
    }

    /// 현재 값은 그래프의 축 양 끝 라벨이 보여준다 — 슬라이더 옆에 다시 쓰지 않는다
    private func slider(
        _ title: LocalizedStringKey,
        value: Binding<Double>,
        in range: ClosedRange<Double>,
        limitedTo limit: ClosedRange<Double>? = nil,
        step: Double
    ) -> some View {
        LabeledContent(title) {
            Slider(value: value.snapped(to: step, within: limit), in: range)
        }
    }
}

extension Binding<Double> {
    /// `Slider(step:)`은 스냅과 함께 스냅 지점마다 눈금 점을 그린다 — 점 없이 스냅만 남긴다.
    /// 벽도 `Slider(in:)`이 아니라 여기서 세운다 — 트랙 범위는 노브의 위치 계산에 쓰이므로,
    /// 상대 값에 따라 좁히면 값이 그대로인 슬라이더의 노브가 조작 중에 미끄러진다
    fileprivate func snapped(to step: Double, within limit: ClosedRange<Double>?) -> Binding<Double> {
        Binding(
            get: { wrappedValue },
            set: { proposed in
                let snapped = (proposed / step).rounded() * step

                guard let limit else {
                    wrappedValue = snapped
                    return
                }

                // `Binding`의 dynamic member lookup이 가로채므로 모듈을 붙인다
                wrappedValue = Swift.min(Swift.max(snapped, limit.lowerBound), limit.upperBound)
            }
        )
    }
}

#Preview {
    SpeedSettings()
}
