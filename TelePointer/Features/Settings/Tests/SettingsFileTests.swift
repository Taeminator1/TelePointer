import AppKit
import Foundation
import KeyboardShortcuts
import PointerCore
import ShortcutException
import Testing
@testable import Settings

@MainActor
struct SettingsFileTests {
    private let defaults = UserDefaults(suiteName: "SettingsFileTests")!

    private let code = ExcludedApp(bundleID: "com.microsoft.vscode", name: "Code")
    private let xcode = ExcludedApp(bundleID: "com.apple.dt.xcode", name: "Xcode")

    init() {
        defaults.removePersistentDomain(forName: "SettingsFileTests")
    }

    @Test("내보낸 파일을 다시 읽으면 같다")
    func roundTrip() throws {
        let file = SettingsFile(
            shortcuts: [
                "movePointer": KeyboardShortcuts.Shortcut(.c, modifiers: [.control, .option]),
                "movePointerUp": nil,
            ],
            exceptions: ["movePointerLeft": [code, xcode]],
            speed: SettingsFile.Speed(curve: .default, steady: 120)
        )

        #expect(try SettingsFile.decoded(from: file.encoded()) == file)
    }

    @Test("내보낸 파일은 단축키 이름을 모두 담는다")
    func exportsEveryShortcutName() {
        let exceptions = ShortcutExceptionStore(defaults: defaults)
        exceptions.add(code, for: "movePointerLeft")

        let file = SettingsFile.current(
            speed: SpeedStore(defaults: defaults),
            exceptions: exceptions
        )

        #expect(file.shortcuts?.count == pointerShortcutNames.count)
        #expect(file.exceptions == ["movePointerLeft": [code]])
        #expect(file.speed?.curve == .default)
        #expect(file.speed?.steady == SteadySpeed.default)
    }

    @Test("지운 단축키는 지워진 채로 왕복한다")
    func keepsClearedShortcut() throws {
        let file = SettingsFile(shortcuts: ["movePointer": nil], speed: nil)

        let decoded = try SettingsFile.decoded(from: file.encoded())

        #expect(try #require(decoded.shortcuts?["movePointer"]) == nil)
    }

    @Test("JSON이 아니면 읽지 않는다")
    func rejectsGarbage() {
        #expect(throws: SettingsFile.Failure.unreadable) {
            try SettingsFile.decoded(from: Data("not json".utf8))
        }
    }

    @Test("아는 항목이 하나도 없으면 설정 파일이 아니다")
    func rejectsUnrelatedJSON() {
        #expect(throws: SettingsFile.Failure.unrecognized) {
            try SettingsFile.decoded(from: Data(#"{"name": "unrelated"}"#.utf8))
        }

        #expect(throws: SettingsFile.Failure.unrecognized) {
            try SettingsFile.decoded(from: Data(#"{"shortcuts": {"unknownName": null}}"#.utf8))
        }
    }

    @Test("일부 항목만 든 파일은 나머지가 비어 있다")
    func acceptsPartialFile() throws {
        let file = try SettingsFile.decoded(from: Data(#"{"speed": {"steady": 120}}"#.utf8))

        #expect(file.shortcuts == nil)
        #expect(file.exceptions == nil)
        #expect(file.speed?.curve == nil)
        #expect(file.speed?.steady == 120)
    }

    @Test("빠진 항목은 적용해도 그대로 남는다")
    func leavesMissingValuesAlone() {
        let store = SpeedStore(defaults: defaults)
        store.steadySpeed = 200

        let exceptions = ShortcutExceptionStore(defaults: defaults)
        exceptions.add(code, for: "movePointerLeft")

        SettingsFile(shortcuts: nil, speed: SettingsFile.Speed(curve: .default, steady: nil))
            .apply(speed: store, exceptions: exceptions)

        #expect(store.steadySpeed == 200)
        #expect(exceptions.apps(for: "movePointerLeft") == [code])
    }

    @Test("허용 범위를 벗어난 값은 적용할 때 조인다")
    func clampsOnApply() {
        let store = SpeedStore(defaults: defaults)

        SettingsFile(
            shortcuts: nil,
            speed: SettingsFile.Speed(
                curve: SpeedCurve(base: -100, peak: 99_999, rampDuration: 10),
                steady: 99_999
            )
        )
        .apply(speed: store, exceptions: ShortcutExceptionStore(defaults: defaults))

        #expect(store.curve.base == SpeedCurve.baseRange.lowerBound)
        #expect(store.curve.peak == SpeedCurve.peakRange.upperBound)
        #expect(store.steadySpeed == SteadySpeed.range.upperBound)
    }

    @Test("예외만 든 파일도 설정 파일로 읽는다")
    func acceptsExceptionsOnlyFile() throws {
        let json = #"{"exceptions": {"movePointer": [{"bundleID": "com.apple.dt.xcode", "name": "Xcode"}]}}"#

        let file = try SettingsFile.decoded(from: Data(json.utf8))

        #expect(file.exceptions == ["movePointer": [xcode]])
    }

    @Test("모르는 단축키 이름의 예외는 설정 파일로 보지 않는다")
    func rejectsUnknownExceptionName() {
        #expect(throws: SettingsFile.Failure.unrecognized) {
            try SettingsFile.decoded(
                from: Data(#"{"exceptions": {"unknownName": [{"bundleID": "a", "name": "A"}]}}"#.utf8)
            )
        }
    }

    @Test("예외는 단축키별로 덮어쓰고 나머지는 남긴다")
    func mergesExceptionsByName() {
        let exceptions = ShortcutExceptionStore(defaults: defaults)
        exceptions.add(code, for: "movePointer")
        exceptions.add(code, for: "movePointerLeft")

        SettingsFile(exceptions: ["movePointer": [xcode]])
            .apply(speed: SpeedStore(defaults: defaults), exceptions: exceptions)

        #expect(exceptions.apps(for: "movePointer") == [xcode])
        #expect(exceptions.apps(for: "movePointerLeft") == [code])
    }

    @Test("빈 목록을 담은 예외는 그 단축키를 지운다")
    func clearsExceptionWithEmptyList() {
        let exceptions = ShortcutExceptionStore(defaults: defaults)
        exceptions.add(code, for: "movePointer")

        SettingsFile(exceptions: ["movePointer": []])
            .apply(speed: SpeedStore(defaults: defaults), exceptions: exceptions)

        #expect(exceptions.all.isEmpty)
    }
}
