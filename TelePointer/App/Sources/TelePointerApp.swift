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
        }
        .windowResizability(.contentSize)
        .defaultLaunchBehavior(.suppressed)
        .restorationBehavior(.disabled)
    }
}
