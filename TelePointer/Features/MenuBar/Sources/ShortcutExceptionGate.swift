import AppKit
import KeyboardShortcuts
import Settings
import ShortcutException

@MainActor
public enum ShortcutExceptionGate {
    public static func start(exceptions store: ShortcutExceptionStore = .shared) {
        NotificationCenter.default.addObserver(
            forName: ShortcutExceptionStore.didChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            MainActor.assumeIsolated { apply(store, activeApp: FrontmostApp.bundleID) }
        }

        FrontmostApp.observe { apply(store, activeApp: $0) }
    }

    private static func apply(_ store: ShortcutExceptionStore, activeApp bundleID: String?) {
        let excluded = excludedShortcutNames(in: store.all, forApp: bundleID)
        let ignored = pointerShortcutNames.filter { excluded.contains($0.rawValue) }

        if !ignored.isEmpty {
            PointerShortcut.releaseHeld()
        }

        KeyboardShortcuts.disable(ignored)
        KeyboardShortcuts.enable(pointerShortcutNames.filter { !excluded.contains($0.rawValue) })
    }
}
