import AppKit
import ApplicationServices

@MainActor
public enum AccessibilityPermission {
    public static let isGranted = AXIsProcessTrusted()

    public static func openSystemSettings() {
        guard let url = URL(
            string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        ) else { return }

        NSWorkspace.shared.open(url)
    }
}
