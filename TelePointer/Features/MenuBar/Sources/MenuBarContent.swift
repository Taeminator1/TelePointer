import LaunchAtLogin
import PointerCore
import SwiftUI

public struct MenuBarContent: View {
    public init() {}

    public var body: some View {
        Button("Move Pointer") {
            PointerMover.moveToScreenCenter()
        }

        Button("Open at Login") {
            LoginItem.toggle()
        }

        Divider()

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
