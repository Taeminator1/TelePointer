public func excludedShortcutNames(
    in exceptions: [String: [ExcludedApp]],
    forApp bundleID: String?
) -> Set<String> {
    guard let bundleID = bundleID?.lowercased(), !bundleID.isEmpty else { return [] }

    return Set(
        exceptions
            .filter { $0.value.contains { $0.bundleID == bundleID } }
            .keys
    )
}
