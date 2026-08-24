import CoreGraphics
import Testing
@testable import PointerCore

private let left = CGRect(x: 0, y: 0, width: 1920, height: 1080)
private let right = CGRect(x: 1920, y: 0, width: 1920, height: 1080)

struct OrderedLeftToRightTests {

    @Test("배열 순서와 무관하게 왼쪽 화면이 앞에 온다")
    func sortsByOriginX() {
        #expect(orderedLeftToRight([right, left]) == [left, right])
    }

    @Test("x가 같으면 아래쪽 화면이 앞에 온다")
    func breaksTieByOriginY() {
        let above = CGRect(x: 0, y: 1080, width: 1920, height: 1080)

        #expect(orderedLeftToRight([above, left]) == [left, above])
    }

    @Test("화면이 없으면 빈 목록")
    func noScreens() {
        #expect(orderedLeftToRight([]).isEmpty)
    }
}

struct TargetFrameTests {

    private func target(_ cursor: CGPoint, _ screenFrames: [CGRect]) -> CGRect? {
        targetFrame(for: cursor, among: screenFrames)
    }

    @Test("화면이 없으면 갈 곳도 없다")
    func noScreens() {
        #expect(target(CGPoint(x: 100, y: 100), []) == nil)
    }

    @Test("커서 위치와 무관하게 다음 화면으로")
    func advancesToNextScreen() {
        #expect(target(CGPoint(x: 100, y: 100), [left, right]) == right)
        #expect(target(CGPoint(x: 960, y: 540), [left, right]) == right)
    }

    @Test("마지막 화면에서는 첫 화면으로 돌아온다")
    func wrapsAround() {
        #expect(target(CGPoint(x: 2000, y: 100), [left, right]) == left)
        #expect(target(CGPoint(x: 2880, y: 540), [left, right]) == left)
    }

    @Test("화면이 하나면 언제나 그 화면")
    func singleScreenStays() {
        #expect(target(CGPoint(x: 960, y: 540), [left]) == left)
        #expect(target(CGPoint(x: 0, y: 0), [left]) == left)
    }

    @Test("배열 순서가 아니라 화면 배치를 따라 넘어간다")
    func followsScreenLayout() {
        #expect(target(CGPoint(x: 2880, y: 540), [right, left]) == left)
    }

    @Test("어느 화면에도 없으면 가장 가까운 화면의 다음 화면으로")
    func fallsBackToNearestScreen() {
        let distant = CGRect(x: 4000, y: 0, width: 1920, height: 1080)

        #expect(target(CGPoint(x: 3900, y: 540), [left, distant]) == left)
        #expect(target(CGPoint(x: 960, y: 1080), [left, distant]) == distant)
    }
}
