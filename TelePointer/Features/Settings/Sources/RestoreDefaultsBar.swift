import SwiftUI

extension View {
    func restoreDefaultsBar(action: @escaping () -> Void) -> some View {
        bottomButtonBar("Restore Defaults", action: action)
    }

    @ViewBuilder
    func bottomButtonBar(_ title: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        if #available(macOS 26, *) {
            safeAreaBar(edge: .bottom) {
                BottomButton(title: title, action: action)
            }
            .softScrollEdgeEffect(for: .bottom)
        } else {
            safeAreaInset(edge: .bottom) {
                BottomButton(title: title, action: action)
            }
        }
    }
}

private struct BottomButton: View {
    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        HStack {
            Spacer()

            Button(title, action: action)
        }
        .padding(16)
    }
}
