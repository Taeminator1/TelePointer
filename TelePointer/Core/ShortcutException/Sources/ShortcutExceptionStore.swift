import Foundation
import Observation

@MainActor
@Observable
public final class ShortcutExceptionStore {
    public static let shared = ShortcutExceptionStore()

    nonisolated public static let didChangeNotification = Notification.Name(
        "ShortcutExceptionStoreDidChange"
    )

    private static let exceptionsKey = "shortcutExceptions"

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var storage: [String: [ExcludedApp]]

    public var all: [String: [ExcludedApp]] {
        get {
            access(keyPath: \.all)
            return storage
        }
        set {
            let exceptions = newValue.filter { !$0.value.isEmpty }

            withMutation(keyPath: \.all) { storage = exceptions }
            save(exceptions)

            NotificationCenter.default.post(name: Self.didChangeNotification, object: nil)
        }
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        storage = Self.load(from: defaults)
    }

    public func apps(for name: String) -> [ExcludedApp] {
        all[name] ?? []
    }

    public func add(_ app: ExcludedApp, for name: String) {
        var apps = apps(for: name)

        guard !apps.contains(where: { $0.bundleID == app.bundleID }) else { return }

        apps.append(app)
        all[name] = apps.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    public func remove(bundleID: String, for name: String) {
        all[name] = apps(for: name).filter { $0.bundleID != bundleID.lowercased() }
    }

    private static func load(from defaults: UserDefaults) -> [String: [ExcludedApp]] {
        guard
            let data = defaults.data(forKey: exceptionsKey),
            let exceptions = try? JSONDecoder().decode([String: [ExcludedApp]].self, from: data)
        else { return [:] }

        return exceptions.filter { !$0.value.isEmpty }
    }

    private func save(_ exceptions: [String: [ExcludedApp]]) {
        guard let data = try? JSONEncoder().encode(exceptions) else { return }

        defaults.set(data, forKey: Self.exceptionsKey)
    }
}
