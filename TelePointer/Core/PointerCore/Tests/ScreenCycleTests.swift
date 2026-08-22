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

struct IsCenteredTests {

    @Test("정중앙")
    func exactCenter() {
        #expect(isCentered(CGPoint(x: 960, y: 540), in: left, tolerance: 2))
    }

    @Test("허용 오차 안이면 중앙으로 본다")
    func withinTolerance() {
        #expect(isCentered(CGPoint(x: 961, y: 539), in: left, tolerance: 2))
        #expect(isCentered(CGPoint(x: 962, y: 542), in: left, tolerance: 2))
    }

    @Test("허용 오차를 넘으면 중앙이 아니다")
    func beyondTolerance() {
        #expect(!isCentered(CGPoint(x: 963, y: 540), in: left, tolerance: 2))
    }

    @Test("한 축만 벗어나도 중앙이 아니다")
    func singleAxisOff() {
        #expect(!isCentered(CGPoint(x: 960, y: 0), in: left, tolerance: 2))
    }
}

struct TargetFrameTests {

    private func target(_ cursor: CGPoint, _ screenFrames: [CGRect]) -> CGRect? {
        targetFrame(for: cursor, among: screenFrames, centerTolerance: 2)
    }

    @Test("화면이 없으면 갈 곳도 없다")
    func noScreens() {
        #expect(target(CGPoint(x: 100, y: 100), []) == nil)
    }

    @Test("중앙이 아니면 커서가 있는 화면의 중앙으로")
    func centersCurrentScreen() {
        #expect(target(CGPoint(x: 100, y: 100), [left, right]) == left)
        #expect(target(CGPoint(x: 2000, y: 100), [left, right]) == right)
    }

    @Test("이미 중앙이면 다음 화면으로")
    func advancesToNextScreen() {
        #expect(target(CGPoint(x: 960, y: 540), [left, right]) == right)
    }

    @Test("마지막 화면에서는 첫 화면으로 돌아온다")
    func wrapsAround() {
        #expect(target(CGPoint(x: 2880, y: 540), [left, right]) == left)
    }

    @Test("화면이 하나면 중앙에 있어도 그 화면")
    func singleScreenStays() {
        #expect(target(CGPoint(x: 960, y: 540), [left]) == left)
        #expect(target(CGPoint(x: 0, y: 0), [left]) == left)
    }

    @Test("허용 오차 안의 어긋남은 중앙으로 보고 넘어간다")
    func toleratesRoundTripError() {
        #expect(target(CGPoint(x: 959, y: 541), [left, right]) == right)
    }

    @Test("배열 순서가 아니라 화면 배치를 따라 넘어간다")
    func followsScreenLayout() {
        #expect(target(CGPoint(x: 960, y: 540), [right, left]) == right)
    }

    @Test("어느 화면에도 없으면 가장 가까운 화면의 중앙으로")
    func fallsBackToNearestScreen() {
        let distant = CGRect(x: 4000, y: 0, width: 1920, height: 1080)

        #expect(target(CGPoint(x: 3900, y: 540), [left, distant]) == distant)
        #expect(target(CGPoint(x: 960, y: 1080), [left, distant]) == left)
    }
}
