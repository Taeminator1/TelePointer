import AppKit
import SwiftUI

extension View {
    /// `.hiddenTitleBar` 창이 예약해두는 타이틀 바 높이를 콘텐츠로 채운다
    @MainActor
    public func fillsHiddenTitleBar() -> some View {
        padding(.top, -NSWindow.frameRect(forContentRect: .zero, styleMask: .titled).height)
    }

    func onWindowAttach(_ action: @escaping @MainActor @Sendable (NSWindow) -> Void) -> some View {
        background(WindowBridge(onAttach: action, onClose: nil))
    }

    func onWindowClose(_ action: @escaping @MainActor @Sendable () -> Void) -> some View {
        background(WindowBridge(onAttach: nil, onClose: action))
    }
}

private struct WindowBridge: NSViewRepresentable {
    let onAttach: (@MainActor @Sendable (NSWindow) -> Void)?
    let onClose: (@MainActor @Sendable () -> Void)?

    func makeNSView(context: Context) -> NSView {
        BridgeView(onAttach: onAttach, onClose: onClose)
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private final class BridgeView: NSView {
    private let onAttach: (@MainActor @Sendable (NSWindow) -> Void)?
    private let onClose: (@MainActor @Sendable () -> Void)?
    private var observer: (any NSObjectProtocol)?

    init(
        onAttach: (@MainActor @Sendable (NSWindow) -> Void)?,
        onClose: (@MainActor @Sendable () -> Void)?
    ) {
        self.onAttach = onAttach
        self.onClose = onClose
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        if let observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }

        guard let window else { return }

        onAttach?(window)

        guard let onClose else { return }

        observer = NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: window,
            queue: .main
        ) { _ in
            MainActor.assumeIsolated(onClose)
        }
    }
}
