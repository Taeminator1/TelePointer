import Foundation
import Testing
@testable import ShortcutException

struct ExcludedAppTests {
    @Test("bundle ID는 소문자로 맞춘다")
    func normalizesBundleID() {
        #expect(ExcludedApp(bundleID: "com.Microsoft.VSCode", name: "Code").bundleID == "com.microsoft.vscode")
    }

    @Test("디코딩한 bundle ID도 소문자로 맞춘다")
    func normalizesDecodedBundleID() throws {
        let json = Data(#"{"bundleID": "com.Apple.Xcode", "name": "Xcode"}"#.utf8)

        #expect(try JSONDecoder().decode(ExcludedApp.self, from: json).bundleID == "com.apple.xcode")
    }

    @Test("표시 이름을 먼저 쓴다")
    func prefersDisplayName() {
        let app = ExcludedApp(
            info: [
                "CFBundleIdentifier": "com.apple.dt.Xcode",
                "CFBundleDisplayName": "Xcode",
                "CFBundleName": "Xcode-Beta",
            ],
            fileName: "Xcode 26"
        )

        #expect(app?.name == "Xcode")
    }

    @Test("표시 이름이 없으면 번들 이름을 쓴다")
    func fallsBackToBundleName() {
        let app = ExcludedApp(
            info: ["CFBundleIdentifier": "com.apple.dt.Xcode", "CFBundleName": "Xcode-Beta"],
            fileName: "Xcode 26"
        )

        #expect(app?.name == "Xcode-Beta")
    }

    @Test("이름이 모두 비어 있으면 파일 이름을 쓴다")
    func fallsBackToFileName() {
        let app = ExcludedApp(
            info: ["CFBundleIdentifier": "com.apple.dt.Xcode", "CFBundleDisplayName": ""],
            fileName: "Xcode 26"
        )

        #expect(app?.name == "Xcode 26")
    }

    @Test("bundle ID가 없으면 만들지 않는다")
    func rejectsMissingBundleID() {
        #expect(ExcludedApp(info: ["CFBundleName": "Xcode"], fileName: "Xcode") == nil)
        #expect(ExcludedApp(info: ["CFBundleIdentifier": ""], fileName: "Xcode") == nil)
    }
}
