import AppKit
import KeyboardShortcuts
import PointerCore
import SwiftUI

public struct ShortcutSettings: View {
    public static let windowID = "shortcutSettings"

    private static let recorderWidth: CGFloat = 120
    private static let shortcutColumnWidth: CGFloat = 360
    private static let speedColumnWidth: CGFloat = 400

    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                column(width: Self.shortcutColumnWidth) {
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

                column(width: Self.speedColumnWidth) {
                    Section("Speed") {
                        SpeedSection(settings: .shared)
                    }
                }
            }

            Divider()

            HStack {
                Button("Restore Defaults") {
                    KeyboardShortcuts.reset(pointerShortcutNames)
                    SpeedSettings.shared.reset()
                }

                Spacer()

                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(16)
        }
        .frame(width: Self.shortcutColumnWidth + Self.speedColumnWidth)
        .onWindowAttach { window in
            window.isMovableByWindowBackground = true
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
        }
        .onWindowClose { NSApp.hide(nil) }
    }

    private func column(
        width: CGFloat,
        @ViewBuilder content: () -> some View
    ) -> some View {
        Form(content: content)
            .formStyle(.grouped)
            .scrollDisabled(true)
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: width)
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
