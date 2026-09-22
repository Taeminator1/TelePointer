import AppKit

@MainActor
public enum FrontmostApp {
    public static var bundleID: String? {
        NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    }

    public static func observe(_ onChange: @escaping @MainActor (String?) -> Void) {
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { notification in
            let activated = notification.userInfo?[NSWorkspace.applicationUserInfoKey]
                as? NSRunningApplication
            let activatedBundleID = activated?.bundleIdentifier

            MainActor.assumeIsolated { onChange(activatedBundleID ?? bundleID) }
        }

        onChange(bundleID)
    }
}
