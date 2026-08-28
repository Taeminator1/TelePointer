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
    fileprivate func snapped(to step: Double, within limit: ClosedRange<Double>?) -> Binding<Double> {
        Binding(
            get: { wrappedValue },
            set: { proposed in
                let snapped = (proposed / step).rounded() * step

                guard let limit else {
                    wrappedValue = snapped
                    return
                }

                wrappedValue = Swift.min(Swift.max(snapped, limit.lowerBound), limit.upperBound)
            }
        )
    }
}

#Preview {
    SpeedSettings()
}
