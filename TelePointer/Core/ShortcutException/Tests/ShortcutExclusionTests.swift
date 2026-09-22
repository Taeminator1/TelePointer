import Testing
@testable import ShortcutException

struct ShortcutExclusionTests {
    private let code = ExcludedApp(bundleID: "com.microsoft.VSCode", name: "Code")
    private let xcode = ExcludedApp(bundleID: "com.apple.dt.Xcode", name: "Xcode")

    @Test("예외가 없으면 아무것도 제외하지 않는다")
    func excludesNothingWithoutExceptions() {
        #expect(excludedShortcutNames(in: [:], forApp: "com.microsoft.vscode").isEmpty)
    }

    @Test("앞 앱을 담은 단축키만 제외한다")
    func excludesNamesContainingApp() {
        let exceptions = [
            "movePointerLeft": [code, xcode],
            "movePointerRight": [code],
            "movePointer": [xcode],
        ]

        #expect(
            excludedShortcutNames(in: exceptions, forApp: "com.microsoft.vscode")
                == ["movePointerLeft", "movePointerRight"]
        )
    }

    @Test("목록에 없는 앱은 제외하지 않는다")
    func keepsUnlistedApp() {
        let exceptions = ["movePointerLeft": [code]]

        #expect(excludedShortcutNames(in: exceptions, forApp: "com.apple.finder").isEmpty)
    }

    @Test("bundle ID 대소문자는 가린다")
    func ignoresBundleIDCase() {
        let exceptions = ["movePointerLeft": [code]]

        #expect(
            excludedShortcutNames(in: exceptions, forApp: "com.Microsoft.VSCode")
                == ["movePointerLeft"]
        )
    }

    @Test("앞 앱을 알 수 없으면 제외하지 않는다")
    func excludesNothingWithoutApp() {
        let exceptions = ["movePointerLeft": [code]]

        #expect(excludedShortcutNames(in: exceptions, forApp: nil).isEmpty)
        #expect(excludedShortcutNames(in: exceptions, forApp: "").isEmpty)
    }
}
