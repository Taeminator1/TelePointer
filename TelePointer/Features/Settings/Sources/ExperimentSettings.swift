#if DEBUG
import PointerCore
import SwiftUI

struct ExperimentSettings: View {
    @Environment(\.openWindow) private var openWindow
    @Bindable private var experiments = ExperimentStore.shared

    var body: some View {
        Form {
            Picker(selection: $experiments.smoothTurning) {
                ForEach(SmoothTurning.allCases, id: \.self) { mode in
                    Text(mode.label).tag(mode)
                }
            } label: {
                Text("Smooth Turning")
                Text(experiments.smoothTurning.summary)
            }
            Picker(selection: $experiments.slowOnTurn) {
                ForEach(SlowOnTurn.allCases, id: \.self) { mode in
                    Text(mode.label).tag(mode)
                }
            } label: {
                Text("Slow on Turn")
                Text(experiments.slowOnTurn.summary)
            }
            Toggle(isOn: $experiments.noHoldLimit) {
                Text("No Hold Limit")
                Text("Keeps moving no matter how long the keys are held.")
            }
        }
        .formStyle(.grouped)
        .bottomButtonBar("Open Playground") {
            openWindow(id: Playground.windowID)
        }
        .frame(width: 400)
    }
}

extension SmoothTurning {
    fileprivate var label: String {
        switch self {
        case .off: "Off"
        case .headingBlend: "Heading Blend"
        case .overshootReturn: "Overshoot Return"
        }
    }

    fileprivate var summary: String {
        switch self {
        case .off: "Changes direction instantly."
        case .headingBlend: "Gradually rotates the heading, leaving the new path offset past the turn point."
        case .overshootReturn: "Swings slightly past the corner, then settles back onto the line."
        }
    }
}

extension SlowOnTurn {
    fileprivate var label: String {
        switch self {
        case .off: "Off"
        case .dip: "Dip"
        case .restartRamp: "Restart Ramp"
        }
    }

    fileprivate var summary: String {
        switch self {
        case .off: "Keeps the current speed when turning."
        case .dip: "Briefly slows down while turning, then recovers."
        case .restartRamp: "Drops to the base speed and accelerates again."
        }
    }
}

#Preview {
    ExperimentSettings()
}
#endif
