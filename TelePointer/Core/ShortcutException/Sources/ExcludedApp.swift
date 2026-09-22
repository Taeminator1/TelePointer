import Foundation

public struct ExcludedApp: Codable, Equatable, Identifiable, Sendable {
    public let bundleID: String
    public let name: String

    public var id: String { bundleID }

    public init(bundleID: String, name: String) {
        self.bundleID = bundleID.lowercased()
        self.name = name
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.init(
            bundleID: try container.decode(String.self, forKey: .bundleID),
            name: try container.decode(String.self, forKey: .name)
        )
    }
}

extension ExcludedApp {
    public init?(appURL: URL) {
        guard let bundle = Bundle(url: appURL) else { return nil }

        let info = (bundle.infoDictionary ?? [:])
            .merging(bundle.localizedInfoDictionary ?? [:]) { _, localized in localized }

        self.init(info: info, fileName: appURL.deletingPathExtension().lastPathComponent)
    }

    init?(info: [String: Any], fileName: String) {
        guard let bundleID = info.nonEmptyString("CFBundleIdentifier") else { return nil }

        self.init(
            bundleID: bundleID,
            name: info.nonEmptyString("CFBundleDisplayName")
                ?? info.nonEmptyString("CFBundleName")
                ?? fileName
        )
    }
}

extension [String: Any] {
    fileprivate func nonEmptyString(_ key: String) -> String? {
        guard let value = self[key] as? String, !value.isEmpty else { return nil }

        return value
    }
}
