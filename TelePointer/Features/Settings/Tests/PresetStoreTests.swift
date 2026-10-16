import Foundation
import PointerCore
import ShortcutException
import Testing
@testable import Settings

@MainActor
struct PresetStoreTests {
    private let defaults = UserDefaults(suiteName: "PresetStoreTests")!

    init() {
        defaults.removePersistentDomain(forName: "PresetStoreTests")
    }

    private func makeStore(speed: SpeedStore? = nil) -> PresetStore {
        PresetStore(
            defaults: defaults,
            speed: speed ?? SpeedStore(defaults: defaults),
            exceptions: ShortcutExceptionStore(defaults: defaults),
            experiments: ExperimentStore(defaults: defaults)
        )
    }

    @Test("처음에는 preset이 없다")
    func startsEmpty() {
        #expect(makeStore().presets.isEmpty)
    }

    @Test("추가한 preset은 지금 설정을 담고 맨 뒤에 붙는다")
    func addsCurrentSettings() {
        let speed = SpeedStore(defaults: defaults)
        let store = makeStore(speed: speed)

        store.add()
        speed.steadySpeed = 200
        store.add()

        #expect(store.presets.count == 2)
        #expect(store.presets[0].settings.speed?.steady == SteadySpeed.default)
        #expect(store.presets[1].settings.speed?.steady == 200)
    }

    @Test("preset 순서를 바꾼다")
    func movesPreset() {
        let store = makeStore()
        store.add()
        store.add()
        let ids = store.presets.map(\.id)

        store.move(fromOffsets: [1], toOffset: 0)

        #expect(store.presets.map(\.id) == ids.reversed())
    }

    @Test("고른 preset만 삭제한다")
    func removesPresets() {
        let store = makeStore()
        store.add()
        store.add()
        store.add()
        let kept = store.presets[1]

        store.remove([store.presets[0].id, store.presets[2].id])

        #expect(store.presets == [kept])
    }

    @Test("preset에 별명을 붙인다")
    func renamesPreset() {
        let store = makeStore()
        store.add()

        store.rename(store.presets[0].id, to: "  Gaming  ")

        #expect(store.presets[0].name == "Gaming")
    }

    @Test("빈 별명은 받지 않는다")
    func ignoresBlankName() {
        let store = makeStore()
        store.add()
        let name = store.presets[0].name

        store.rename(store.presets[0].id, to: "   ")

        #expect(store.presets[0].name == name)
    }

    @Test("추가한 preset은 다시 열어도 남아 있다")
    func persistsPresets() {
        let store = makeStore()
        store.add()

        #expect(makeStore().presets == store.presets)
    }
}
