import SwiftUI

extension View {
    @ViewBuilder
    func softScrollEdgeEffect(for edges: Edge.Set) -> some View {
        if #available(macOS 26, *) {
            scrollEdgeEffectStyle(.soft, for: edges)
        } else {
            self
        }
    }
}
