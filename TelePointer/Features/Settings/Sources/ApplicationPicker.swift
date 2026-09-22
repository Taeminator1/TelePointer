import AppKit
import ShortcutException
import UniformTypeIdentifiers

@MainActor
enum ApplicationPicker {
    static func chooseApp() -> ExcludedApp? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.application]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.directoryURL = URL(filePath: "/Applications")
        panel.prompt = "Add"

        NSApp.activate()

        guard panel.runModal() == .OK, let url = panel.url else { return nil }

        guard let app = ExcludedApp(appURL: url) else {
            report(url)
            return nil
        }

        return app
    }

    private static func report(_ url: URL) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Couldn’t add “\(url.deletingPathExtension().lastPathComponent)”."
        alert.informativeText = "The app doesn’t have a bundle identifier."
        alert.runModal()
    }
}
