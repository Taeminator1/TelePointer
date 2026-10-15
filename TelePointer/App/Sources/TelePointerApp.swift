import MenuBar
import Settings
import SwiftUI

@main
struct TelePointerApp: App {
    init() {
        PointerShortcut.registerHandler()
        ShortcutExceptionGate.start()
    }

    var body: some Scene {
        MenuBarExtra("TelePointer", image: "MenuBarIcon") {
            MenuBarContent()
        }
        .menuBarExtraStyle(.menu)

        Window("Settings", id: AppSettings.windowID) {
            AppSettings()
        }
        .settingsWindow()

        #if DEBUG
        Window("Playground", id: Playground.windowID) {
            Playground()
        }
        .defaultLaunchBehavior(.suppressed)
        .restorationBehavior(.disabled)
        #endif
    }
}

extension Scene {
    fileprivate func settingsWindow() -> some Scene {
        windowResizability(.contentSize)
            .defaultLaunchBehavior(.suppressed)
            .restorationBehavior(.disabled)
    }
}
