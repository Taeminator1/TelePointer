import AppKit
import SwiftUI

extension View {
    /// `.hiddenTitleBar` 창이 예약해두는 타이틀 바 높이를 콘텐츠로 채운다
    @MainActor
    public func fillsHiddenTitleBar() -> some View {
        padding(.top, -NSWindow.frameRect(forContentRect: .zero, styleMask: .titled).height)
    }

    /// 설정 창이 공유하는 창 다루기 — 배경으로 옮길 수 있게 하고, 신호등 버튼 셋을 감추고,
    /// 초기 포커스를 풀어준다
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
                    // AppKit은 창이 처음 key가 될 때 key view loop의 첫 컨트롤을 잡는다.
                    // 설정 창은 아무것도 선택되지 않은 채로 열려야 하므로 그때 한 번만 풀어준다 —
                    // 이후 Tab이나 클릭으로 잡는 포커스는 건드리지 않는다
                    guard ClearedInitialFocus.shared.insert(window) else { return }

                    window.makeFirstResponder(nil)
                },
                onClose: { window in
                    // 다시 열면 초기 포커스도 다시 풀어야 한다
                    ClearedInitialFocus.shared.remove(window)
                }
            )
        )
    }
}

/// 초기 포커스를 이미 푼 창 — 옵서버는 창이 key가 될 때마다 부르지만 처음 한 번만 풀어야 한다
@MainActor
private final class ClearedInitialFocus {
    static let shared = ClearedInitialFocus()

    private var identifiers: Set<ObjectIdentifier> = []

    /// 처음 넣는 창이면 true
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
