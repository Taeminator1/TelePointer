import AppKit
import SwiftUI

extension View {
    func onWindowClose(_ action: @escaping @MainActor @Sendable () -> Void) -> some View {
        background(WindowCloseObserver(action: action))
    }
}

private struct WindowCloseObserver: NSViewRepresentable {
    let action: @MainActor @Sendable () -> Void

    func makeNSView(context: Context) -> NSView {
        ObservingView(action: action)
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private final class ObservingView: NSView {
    private let action: @MainActor @Sendable () -> Void
    private var observer: (any NSObjectProtocol)?

    init(action: @escaping @MainActor @Sendable () -> Void) {
        self.action = action
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
        }

        observer = window.map { window in
            NotificationCenter.default.addObserver(
                forName: NSWindow.willCloseNotification,
                object: window,
                queue: .main
            ) { [action] _ in
                MainActor.assumeIsolated(action)
            }
        }
    }
}
