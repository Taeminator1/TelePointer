import CoreGraphics
import Testing
@testable import PointerCore

struct NormalizedVectorTests {

    @Test("방향이 없으면 영벡터")
    func noDirections() {
        #expect(normalizedVector(of: []) == .zero)
    }

    @Test("위쪽은 warp 좌표에서 y가 줄어드는 방향")
    func singleDirection() {
        #expect(normalizedVector(of: [.up]) == CGVector(dx: 0, dy: -1))
        #expect(normalizedVector(of: [.right]) == CGVector(dx: 1, dy: 0))
    }

    @Test("반대 방향은 상쇄되어 영벡터")
    func oppositeDirectionsCancel() {
        #expect(normalizedVector(of: [.up, .down]) == .zero)
        #expect(normalizedVector(of: [.left, .right]) == .zero)
    }

    @Test("대각선도 길이가 1이라 직선과 속도가 같다")
    func diagonalIsNormalized() {
        let vector = normalizedVector(of: [.up, .right])
        let length = (vector.dx * vector.dx + vector.dy * vector.dy).squareRoot()

        #expect(abs(length - 1) < 1e-12)
        #expect(vector.dx > 0)
        #expect(vector.dy < 0)
    }

    @Test("상쇄되고 남은 방향만 반영한다")
    func remainingDirectionAfterCancel() {
        #expect(normalizedVector(of: [.up, .down, .left]) == CGVector(dx: -1, dy: 0))
    }
}
