import AppKit
import SwiftUI

public struct ShortcutSettings: View {
    public static let windowID = "shortcutSettings"

    public init() {}

    public var body: some View {
        // TODO: Recorder · 방향키 십자 배치 · 초기화 · 완료 버튼
        Text("Keyboard Shortcuts")
            .padding(40)
            .onWindowClose { NSApp.hide(nil) }
    }
}
