import Foundation

@MainActor
public enum LoginItem {
    public static var isEnabled: Bool {
        // TODO: SMAppService.mainApp.status 조회
        false
    }

    public static func toggle() {
        // TODO: SMAppService.mainApp 등록/해제, .requiresApproval 처리
    }
}
