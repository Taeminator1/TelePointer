import ServiceManagement

@MainActor
public enum LoginItem {
    public enum State {
        case enabled
        case disabled
        case requiresApproval
    }

    public static var state: State {
        switch SMAppService.mainApp.status {
            case .enabled:
                    .enabled
            case .requiresApproval:
                    .requiresApproval
            case .notRegistered, .notFound:
                    .disabled
            @unknown default:
                    .disabled
        }
    }

    public static func setEnabled(_ isEnabled: Bool) throws {
        if isEnabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    }

    public static func openSystemSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
}
