import SwiftUI

extension View {
    @ViewBuilder
    func restoreDefaultsBar(action: @escaping () -> Void) -> some View {
        if #available(macOS 26, *) {
            safeAreaBar(edge: .bottom) {
                RestoreDefaultsButton(action: action)
            }
            .softScrollEdgeEffect(for: .bottom)
        } else {
            safeAreaInset(edge: .bottom) {
                RestoreDefaultsButton(action: action)
            }
        }
    }
}

private struct RestoreDefaultsButton: View {
    let action: () -> Void

    var body: some View {
        HStack {
            Spacer()

            Button("Restore Defaults", action: action)
        }
        .padding(16)
    }
}
