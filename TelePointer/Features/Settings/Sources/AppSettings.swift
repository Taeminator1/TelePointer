import SwiftUI

public struct AppSettings: View {
    public static let windowID = "appSettings"

    private static let sidebarWidth: CGFloat = 180

    public init() {}

    public var body: some View {
        NavigationSplitView {
            Color.clear
                .toolbar(removing: .sidebarToggle)
                .navigationSplitViewColumnWidth(
                    min: Self.sidebarWidth,
                    ideal: Self.sidebarWidth,
                    max: Self.sidebarWidth
                )
        } detail: {
            Color.clear
                .frame(width: 400, height: 300)
        }
        .toolbar {
            ToolbarSpacer(.flexible)
        }
    }
}

#Preview {
    AppSettings()
}
