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
    }
}

extension Scene {
    fileprivate func settingsWindow() -> some Scene {
        windowResizability(.contentSize)
            .defaultLaunchBehavior(.suppressed)
            .restorationBehavior(.disabled)
    }
}
