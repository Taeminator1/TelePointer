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

        Window("Settings", id: AppSettings.windowID) {
            AppSettings()
        }
        .settingsWindow()

        Window("Keyboard Shortcuts", id: ShortcutSettings.windowID) {
            ShortcutSettings()
                .fillsHiddenTitleBar()
        }
        .settingsWindow()
        .windowLevel(.floating)

        Window("Pointer Speed", id: SpeedSettings.windowID) {
            SpeedSettings()
                .fillsHiddenTitleBar()
        }
        .settingsWindow()
        .windowLevel(.floating)
    }
}

extension Scene {
    fileprivate func settingsWindow() -> some Scene {
        windowStyle(.hiddenTitleBar)
            .windowResizability(.contentSize)
            .defaultLaunchBehavior(.suppressed)
            .restorationBehavior(.disabled)
    }
}
