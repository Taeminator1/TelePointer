import AppKit
import KeyboardShortcuts
import SwiftUI

public struct ShortcutSettings: View {
    private static let recorderWidth: CGFloat = 120
    private static let directionPickerWidth: CGFloat = 180

    @State private var directionMode: DirectionMode = .accelerating

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            Form {
                Section("Screen") {
                    KeyboardShortcuts.Recorder("Move Pointer", name: .movePointer)
                }

                Section {
                    directionCross
                } header: {
                    HStack {
                        Text("Direction")

                        Spacer()

                        Picker("Direction", selection: $directionMode) {
                            ForEach(DirectionMode.allCases, id: \.self) { mode in
                                Text(mode.title)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .frame(width: Self.directionPickerWidth)
                    }
                }

                Section("Click & Drag") {
                    KeyboardShortcuts.Recorder("Left", name: .clickPointerLeft)
                    KeyboardShortcuts.Recorder("Right", name: .clickPointerRight)
                }
            }
            .formStyle(.grouped)

            HStack {
                Spacer()
                
                Button("Restore Defaults") {
                    KeyboardShortcuts.reset(pointerShortcutNames)
                }
            }
            .padding(16)
        }
        .frame(width: 400)
    }

    @ViewBuilder
    private var directionCross: some View {
        switch directionMode {
        case .accelerating:
            directionCross(
                up: .movePointerUp,
                left: .movePointerLeft,
                down: .movePointerDown,
                right: .movePointerRight
            )
        case .steady:
            directionCross(
                up: .movePointerUpSteadily,
                left: .movePointerLeftSteadily,
                down: .movePointerDownSteadily,
                right: .movePointerRightSteadily
            )
        }
    }

    private func directionCross(
        up: KeyboardShortcuts.Name,
        left: KeyboardShortcuts.Name,
        down: KeyboardShortcuts.Name,
        right: KeyboardShortcuts.Name
    ) -> some View {
        Grid(horizontalSpacing: 8, verticalSpacing: 8) {
            GridRow {
                recorder(for: up)
                    .gridCellColumns(3)
            }

            GridRow {
                recorder(for: left)

                Image(systemName: "cursorarrow")
                    .foregroundStyle(.secondary)

                recorder(for: right)
            }

            GridRow {
                recorder(for: down)
                    .gridCellColumns(3)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func recorder(for name: KeyboardShortcuts.Name) -> some View {
        KeyboardShortcuts.Recorder(for: name)
            .frame(width: Self.recorderWidth)
    }
}

private enum DirectionMode: CaseIterable {
    case accelerating
    case steady

    var title: String {
        switch self {
        case .accelerating: "Accelerating"
        case .steady: "Steady"
        }
    }
}

#Preview {
    ShortcutSettings()
}
