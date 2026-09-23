import PointerCore
import SwiftUI

struct AccessibilityPermissionItem: View {
    var body: some View {
        if !AccessibilityPermission.isGranted {
            Button {
                AccessibilityPermission.openSystemSettings()
            } label: {
                Label("Enable Click…", systemImage: "accessibility")
            }
        }
    }
}
