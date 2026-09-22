import SwiftUI

extension View {
    func restoreDefaultsBar(action: @escaping () -> Void) -> some View {
        safeAreaBar(edge: .bottom) {
            HStack {
                Spacer()

                Button("Restore Defaults", action: action)
            }
            .padding(16)
        }
        .scrollEdgeEffectStyle(.soft, for: .bottom)
    }
}
