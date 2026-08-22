import AppKit
import KeyboardShortcuts
import SwiftUI

public struct ShortcutSettings: View {
    public static let windowID = "shortcutSettings"

    public init() {}

    public var body: some View {
        // TODO: 방향키 십자 배치 · 초기화 · 완료 버튼
        Form {
            Section("Screen") {
                KeyboardShortcuts.Recorder("Move Pointer", name: .movePointer)
            }

            Section("Direction") {
                KeyboardShortcuts.Recorder("Up", name: .movePointerUp)
                KeyboardShortcuts.Recorder("Left", name: .movePointerLeft)
                KeyboardShortcuts.Recorder("Down", name: .movePointerDown)
                KeyboardShortcuts.Recorder("Right", name: .movePointerRight)
            }

            Section("Click & Drag") {
                KeyboardShortcuts.Recorder("Left", name: .clickPointerLeft)
                KeyboardShortcuts.Recorder("Right", name: .clickPointerRight)
            }
        }
        .formStyle(.grouped)
        .frame(width: 380)
        .onWindowClose { NSApp.hide(nil) }
    }
}
