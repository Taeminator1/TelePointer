import AppKit
import SwiftUI

extension View {
    @MainActor
    public func fillsHiddenTitleBar() -> some View {
        padding(.top, -NSWindow.frameRect(forContentRect: .zero, styleMask: .titled).height)
    }

    func settingsWindowChrome() -> some View {
        background(
            WindowBridge(
                onAttach: { window in
                    window.isMovableByWindowBackground = true

                    for button in [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton] {
                        window.standardWindowButton(button)?.isHidden = true
                    }
                },
                onBecomeKey: { window in
                    guard ClearedInitialFocus.shared.insert(window) else { return }

                    DispatchQueue.main.async {
                        window.makeFirstResponder(nil)
                    }
                },
                onClose: { window in
                    ClearedInitialFocus.shared.remove(window)
                }
            )
        )
    }
}

@MainActor
private final class ClearedInitialFocus {
    static let shared = ClearedInitialFocus()

    private var identifiers: Set<ObjectIdentifier> = []

    func insert(_ window: NSWindow) -> Bool {
        identifiers.insert(ObjectIdentifier(window)).inserted
    }

    func remove(_ window: NSWindow) {
        identifiers.remove(ObjectIdentifier(window))
    }
}

private struct WindowBridge: NSViewRepresentable {
    let onAttach: (@MainActor @Sendable (NSWindow) -> Void)?
    let onBecomeKey: (@MainActor @Sendable (NSWindow) -> Void)?
    let onClose: (@MainActor @Sendable (NSWindow) -> Void)?

    func makeNSView(context: Context) -> NSView {
        BridgeView(onAttach: onAttach, onBecomeKey: onBecomeKey, onClose: onClose)
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private final class BridgeView: NSView {
    private let onAttach: (@MainActor @Sendable (NSWindow) -> Void)?
    private let onBecomeKey: (@MainActor @Sendable (NSWindow) -> Void)?
    private let onClose: (@MainActor @Sendable (NSWindow) -> Void)?
    private var observers: [any NSObjectProtocol] = []

    init(
        onAttach: (@MainActor @Sendable (NSWindow) -> Void)?,
        onBecomeKey: (@MainActor @Sendable (NSWindow) -> Void)?,
        onClose: (@MainActor @Sendable (NSWindow) -> Void)?
    ) {
        self.onAttach = onAttach
        self.onBecomeKey = onBecomeKey
        self.onClose = onClose
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        observers.removeAll()

        guard let window else { return }

        onAttach?(window)

        observe(NSWindow.didBecomeKeyNotification, of: window, with: onBecomeKey)
        observe(NSWindow.willCloseNotification, of: window, with: onClose)
    }

    private func observe(
        _ name: Notification.Name,
        of window: NSWindow,
        with action: (@MainActor @Sendable (NSWindow) -> Void)?
    ) {
        guard let action else { return }

        observers.append(
            NotificationCenter.default.addObserver(forName: name, object: window, queue: .main) { notification in
                guard let window = notification.object as? NSWindow else { return }

                MainActor.assumeIsolated { action(window) }
            }
        )
    }
}
