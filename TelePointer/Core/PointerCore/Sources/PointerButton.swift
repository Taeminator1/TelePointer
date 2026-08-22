import CoreGraphics

public enum PointerButton {
    case left
    case right

    var cgButton: CGMouseButton {
        switch self {
        case .left: .left
        case .right: .right
        }
    }

    var downType: CGEventType {
        switch self {
        case .left: .leftMouseDown
        case .right: .rightMouseDown
        }
    }

    var upType: CGEventType {
        switch self {
        case .left: .leftMouseUp
        case .right: .rightMouseUp
        }
    }

    var draggedType: CGEventType {
        switch self {
        case .left: .leftMouseDragged
        case .right: .rightMouseDragged
        }
    }
}
