import MenuBar
import Settings
import SwiftUI

@main
struct TelePointerApp: App {
    init() {
        PointerShortcut.registerHandler()
    }

    var body: some Scene {
        MenuBarExtra("TelePointer", systemImage: "cursorarrow.rays") {
            MenuBarContent()
        }
        .menuBarExtraStyle(.menu)

        Window("Keyboard Shortcuts", id: ShortcutSettings.windowID) {
            ShortcutSettings()
                .fillsHiddenTitleBar()
        }
        .settingsWindow()

        Window("Pointer Speed", id: SpeedSettings.windowID) {
            SpeedSettings()
                .fillsHiddenTitleBar()
        }
        .settingsWindow()
    }
}

extension Scene {
    /// 설정 창 두 개가 공유하는 창 성질 — 타이틀 바 없음, 내용 크기 고정, 다른 앱 위에 떠 있음
    fileprivate func settingsWindow() -> some Scene {
        windowStyle(.hiddenTitleBar)
            .windowResizability(.contentSize)
            .windowLevel(.floating)
            .defaultLaunchBehavior(.suppressed)
            .restorationBehavior(.disabled)
    }
}
