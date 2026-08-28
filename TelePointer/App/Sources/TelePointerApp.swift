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
    fileprivate func settingsWindow() -> some Scene {
        windowStyle(.hiddenTitleBar)
            .windowResizability(.contentSize)
            .windowLevel(.floating)
            .defaultLaunchBehavior(.suppressed)
            .restorationBehavior(.disabled)
    }
}
