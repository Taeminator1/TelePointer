import CoreGraphics
import Testing
@testable import PointerCore

struct ScreenGeometryTests {

    @Test("주 디스플레이 단독")
    func primaryScreenOnly() {
        let point = warpPoint(
            centerOf: CGRect(x: 0, y: 0, width: 1920, height: 1080),
            primaryScreenHeight: 1080
        )

        #expect(point == CGPoint(x: 960, y: 540))
    }

    @Test("주 디스플레이 위쪽에 붙은 보조 화면")
    func screenAbovePrimary() {
        let point = warpPoint(
            centerOf: CGRect(x: 0, y: 1080, width: 1920, height: 1080),
            primaryScreenHeight: 1080
        )

        #expect(point == CGPoint(x: 960, y: -540))
    }

    @Test("주 디스플레이 아래쪽에 붙은 보조 화면")
    func screenBelowPrimary() {
        let point = warpPoint(
            centerOf: CGRect(x: 0, y: -1080, width: 1920, height: 1080),
            primaryScreenHeight: 1080
        )

        #expect(point == CGPoint(x: 960, y: 1620))
    }

    @Test("주 화면보다 높이가 큰 보조 화면")
    func tallerSecondaryScreen() {
        let point = warpPoint(
            centerOf: CGRect(x: 1920, y: -540, width: 2560, height: 1440),
            primaryScreenHeight: 1080
        )

        #expect(point == CGPoint(x: 3200, y: 900))
    }
}

struct WarpFrameTests {

    @Test("주 디스플레이 단독")
    func primaryScreenOnly() {
        let frame = warpFrame(
            of: CGRect(x: 0, y: 0, width: 1920, height: 1080),
            primaryScreenHeight: 1080
        )

        #expect(frame == CGRect(x: 0, y: 0, width: 1920, height: 1080))
    }

    @Test("주 디스플레이 위쪽에 붙은 보조 화면")
    func screenAbovePrimary() {
        let frame = warpFrame(
            of: CGRect(x: 0, y: 1080, width: 1920, height: 1080),
            primaryScreenHeight: 1080
        )

        #expect(frame == CGRect(x: 0, y: -1080, width: 1920, height: 1080))
    }

    @Test("주 디스플레이 아래쪽에 붙은 보조 화면")
    func screenBelowPrimary() {
        let frame = warpFrame(
            of: CGRect(x: 0, y: -1080, width: 1920, height: 1080),
            primaryScreenHeight: 1080
        )

        #expect(frame == CGRect(x: 0, y: 1080, width: 1920, height: 1080))
    }

    @Test("주 화면보다 높이가 큰 보조 화면")
    func tallerSecondaryScreen() {
        let frame = warpFrame(
            of: CGRect(x: 1920, y: -540, width: 2560, height: 1440),
            primaryScreenHeight: 1080
        )

        #expect(frame == CGRect(x: 1920, y: 180, width: 2560, height: 1440))
    }
}

struct ClampedTests {
    private let primary = CGRect(x: 0, y: 0, width: 1920, height: 1080)

    @Test("화면 안의 좌표는 그대로 둔다")
    func pointInsideScreen() {
        #expect(clamped(CGPoint(x: 100, y: 200), to: [primary]) == CGPoint(x: 100, y: 200))
    }

    @Test("화면 목록이 비면 그대로 둔다")
    func noScreens() {
        #expect(clamped(CGPoint(x: -500, y: -500), to: []) == CGPoint(x: -500, y: -500))
    }

    @Test("오른쪽 아래로 벗어나면 가장자리 안쪽으로 당긴다")
    func beyondBottomRight() {
        #expect(clamped(CGPoint(x: 2000, y: 1200), to: [primary]) == CGPoint(x: 1919, y: 1079))
    }

    @Test("왼쪽 위로 벗어나면 원점으로 당긴다")
    func beyondTopLeft() {
        #expect(clamped(CGPoint(x: -50, y: -50), to: [primary]) == CGPoint(x: 0, y: 0))
    }

    @Test("맞닿은 화면 안이면 경계를 그대로 넘어간다")
    func crossesIntoAdjacentScreen() {
        let right = CGRect(x: 1920, y: 0, width: 1920, height: 1080)

        #expect(clamped(CGPoint(x: 2000, y: 500), to: [primary, right]) == CGPoint(x: 2000, y: 500))
    }

    @Test("세로가 어긋난 인접 화면으로는 넘어가지 않는다")
    func doesNotCrossMisalignedScreen() {
        let lower = CGRect(x: 1920, y: 600, width: 1920, height: 1080)

        #expect(clamped(CGPoint(x: 1930, y: 300), to: [primary, lower]) == CGPoint(x: 1919, y: 300))
    }

    @Test("떨어진 화면들 사이에서는 가까운 쪽에 붙는다")
    func snapsToNearestScreen() {
        let distant = CGRect(x: 2400, y: 0, width: 1920, height: 1080)

        #expect(clamped(CGPoint(x: 2300, y: 500), to: [primary, distant]) == CGPoint(x: 2400, y: 500))
    }
}
