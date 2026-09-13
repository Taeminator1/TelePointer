import SwiftUI

public struct AppSettings: View {
    public static let windowID = "appSettings"

    private static let windowWidth: CGFloat = 568
    private static let sidebarWidth: CGFloat = 160

    @State private var selection: SettingsPane = .general

    public init() {}

    public var body: some View {
        NavigationSplitView {
            List(SettingsPane.allCases, id: \.self, selection: $selection) { pane in
                Label(pane.title, systemImage: pane.systemImage)
            }
            .toolbar(removing: .sidebarToggle)
            .sidebarCollapseDisabled()
            .navigationSplitViewColumnWidth(
                min: Self.sidebarWidth,
                ideal: Self.sidebarWidth,
                max: Self.sidebarWidth
            )
        } detail: {
            Group {
                switch selection {
                case .general:
                    GeneralSettings()
                case .shortcuts:
                    ShortcutSettings()
                case .speed:
                    SpeedSettings()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .scrollEdgeEffectStyle(.soft, for: .top)
            .navigationTitle(selection.title)
        }
        .toolbar {
            ToolbarSpacer(.flexible)
        }
        .frame(width: Self.windowWidth)
    }
}

private enum SettingsPane: CaseIterable {
    case general
    case shortcuts
    case speed

    var title: String {
        switch self {
        case .general: "General"
        case .shortcuts: "Shortcuts"
        case .speed: "Pointer Speed"
        }
    }

    var systemImage: String {
        switch self {
        case .general: "gearshape"
        case .shortcuts: "keyboard"
        case .speed: "cursorarrow.motionlines"
        }
    }
}

#Preview {
    AppSettings()
}
