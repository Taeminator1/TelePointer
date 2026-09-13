import AppKit
import Foundation
import PointerCore
import UniformTypeIdentifiers

@MainActor
public enum SettingsTransfer {
    private static let fileName = "TelePointer Settings.json"

    public static func exportToFile(speed store: SpeedStore = .shared) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = fileName
        panel.canCreateDirectories = true

        guard let url = url(from: panel) else { return }

        do {
            try SettingsFile.current(speed: store).encoded().write(to: url)
        } catch {
            report("Couldn’t export settings.", error)
        }
    }

    public static func importFromFile(speed store: SpeedStore = .shared) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        guard let url = url(from: panel) else { return }

        do {
            try SettingsFile.decoded(from: Data(contentsOf: url)).apply(speed: store)
        } catch {
            report("Couldn’t import settings.", error)
        }
    }

    private static func url(from panel: NSSavePanel) -> URL? {
        NSApp.activate()

        guard panel.runModal() == .OK else { return nil }

        return panel.url
    }

    private static func report(_ title: String, _ error: any Error) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = title
        alert.informativeText = description(of: error)
        alert.runModal()
    }

    private static func description(of error: any Error) -> String {
        guard let failure = error as? SettingsFile.Failure else {
            return error.localizedDescription
        }

        return switch failure {
        case .unreadable: "The file isn’t valid JSON."
        case .unrecognized: "The file doesn’t contain any TelePointer settings."
        }
    }
}
