import AppKit
import KeyboardShortcuts
import ShortcutException
import SwiftUI

public struct ShortcutSettings: View {
    private static let recorderWidth: CGFloat = 120
    private static let directionPickerWidth: CGFloat = 180

    private let exceptions: ShortcutExceptionStore

    @State private var directionMode: DirectionMode = .accelerating

    public init(exceptions: ShortcutExceptionStore = .shared) {
        self.exceptions = exceptions
    }

    public var body: some View {
        Form {
            Section("Screen") {
                row("Move Pointer", name: .movePointer)
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
                row("Left", name: .clickPointerLeft)
                row("Right", name: .clickPointerRight)
            }
        }
        .formStyle(.grouped)
        .restoreDefaultsBar {
            KeyboardShortcuts.reset(pointerShortcutNames)
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

    private func row(_ title: LocalizedStringKey, name: KeyboardShortcuts.Name) -> some View {
        LabeledContent(title) {
            recorder(for: name)
        }
    }

    private func recorder(for name: KeyboardShortcuts.Name) -> some View {
        HStack(spacing: 4) {
            KeyboardShortcuts.Recorder(for: name)
                .frame(width: Self.recorderWidth)

            ShortcutExceptionButton(name: name, store: exceptions)
        }
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
