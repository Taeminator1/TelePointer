import AppKit
import SwiftUI

extension View {
    func sidebarCollapseDisabled() -> some View {
        background(SidebarCollapseLock())
    }
}

private struct SidebarCollapseLock: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        LockView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private final class LockView: NSView {
    private weak var item: NSSplitViewItem?
    private var observation: NSKeyValueObservation?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        observation = nil
        item = window == nil ? nil : enclosingSplitViewItem

        guard let item else { return }

        lockCollapse()

        observation = item.observe(\.canCollapse) { [weak self] _, _ in
            MainActor.assumeIsolated {
                self?.lockCollapse()
            }
        }
    }

    private func lockCollapse() {
        guard let item, item.canCollapse else { return }

        item.canCollapse = false
    }

    private var enclosingSplitViewItem: NSSplitViewItem? {
        var view = superview

        while let current = view {
            if let controller = (current as? NSSplitView)?.delegate as? NSSplitViewController {
                return controller.splitViewItems.first { isDescendant(of: $0.viewController.view) }
            }

            view = current.superview
        }

        return nil
    }
}
