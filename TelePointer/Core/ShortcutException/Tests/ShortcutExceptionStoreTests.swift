import Foundation
import Testing
@testable import ShortcutException

@MainActor
struct ShortcutExceptionStoreTests {
    private let defaults = UserDefaults(suiteName: "ShortcutExceptionStoreTests")!

    private let code = ExcludedApp(bundleID: "com.microsoft.VSCode", name: "Code")
    private let xcode = ExcludedApp(bundleID: "com.apple.dt.Xcode", name: "Xcode")

    init() {
        defaults.removePersistentDomain(forName: "ShortcutExceptionStoreTests")
    }

    @Test("추가한 앱을 돌려준다")
    func addsApp() {
        let store = ShortcutExceptionStore(defaults: defaults)

        store.add(code, for: "movePointerLeft")

        #expect(store.apps(for: "movePointerLeft") == [code])
        #expect(store.apps(for: "movePointerRight").isEmpty)
    }

    @Test("같은 앱을 두 번 담지 않는다")
    func ignoresDuplicate() {
        let store = ShortcutExceptionStore(defaults: defaults)

        store.add(code, for: "movePointerLeft")
        store.add(ExcludedApp(bundleID: "com.microsoft.vscode", name: "Visual Studio Code"), for: "movePointerLeft")

        #expect(store.apps(for: "movePointerLeft") == [code])
    }

    @Test("앱 목록은 이름 순으로 정렬한다")
    func sortsByName() {
        let store = ShortcutExceptionStore(defaults: defaults)

        store.add(xcode, for: "movePointerLeft")
        store.add(code, for: "movePointerLeft")

        #expect(store.apps(for: "movePointerLeft") == [code, xcode])
    }

    @Test("지운 앱은 사라지고 마지막 앱을 지우면 항목도 사라진다")
    func removesApp() {
        let store = ShortcutExceptionStore(defaults: defaults)

        store.add(code, for: "movePointerLeft")
        store.add(xcode, for: "movePointerLeft")

        store.remove(bundleID: "com.Microsoft.VSCode", for: "movePointerLeft")

        #expect(store.apps(for: "movePointerLeft") == [xcode])

        store.remove(bundleID: xcode.bundleID, for: "movePointerLeft")

        #expect(store.all.isEmpty)
    }

    @Test("추가한 예외가 다음 실행에도 남는다")
    func persistsAcrossInstances() {
        ShortcutExceptionStore(defaults: defaults).add(code, for: "movePointerLeft")

        #expect(ShortcutExceptionStore(defaults: defaults).apps(for: "movePointerLeft") == [code])
    }

    @Test("저장된 값이 깨져 있으면 비어 있는 채로 시작한다")
    func toleratesBrokenStorage() {
        defaults.set(Data("not json".utf8), forKey: "shortcutExceptions")

        #expect(ShortcutExceptionStore(defaults: defaults).all.isEmpty)
    }

    @Test("빈 목록은 담지 않는다")
    func dropsEmptyLists() {
        let store = ShortcutExceptionStore(defaults: defaults)

        store.all = ["movePointerLeft": [], "movePointerRight": [code]]

        #expect(store.all == ["movePointerRight": [code]])
    }
}
