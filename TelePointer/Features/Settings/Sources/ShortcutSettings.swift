import AppKit
import KeyboardShortcuts
import SwiftUI

public struct ShortcutSettings: View {
    public static let windowID = "shortcutSettings"

    private static let recorderWidth: CGFloat = 120

    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            Form {
                Section("Screen") {
                    KeyboardShortcuts.Recorder("Move Pointer", name: .movePointer)
                }

                Section("Direction") {
                    directionCross
                }

                Section("Click & Drag") {
                    KeyboardShortcuts.Recorder("Left", name: .clickPointerLeft)
                    KeyboardShortcuts.Recorder("Right", name: .clickPointerRight)
                }
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            .fixedSize(horizontal: false, vertical: true)

            Divider()

            HStack {
                Button("Restore Defaults") {
                    KeyboardShortcuts.reset(pointerShortcutNames)
                }

                Spacer()

                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(16)
        }
        .frame(width: 380)
        .settingsWindowChrome()
    }

    private var directionCross: some View {
        Grid(horizontalSpacing: 8, verticalSpacing: 8) {
            GridRow {
                recorder(for: .movePointerUp)
                    .gridCellColumns(3)
            }

            GridRow {
                recorder(for: .movePointerLeft)

                Image(systemName: "cursorarrow")
                    .foregroundStyle(.secondary)

                recorder(for: .movePointerRight)
            }

            GridRow {
                recorder(for: .movePointerDown)
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

#Preview {
    ShortcutSettings()
}
