import PointerCore
import SwiftUI

struct AccessibilityPermissionItem: View {
    var body: some View {
        if !AccessibilityPermission.isGranted {
            Button("Enable Click…") {
                AccessibilityPermission.openSystemSettings()
            }
        }
    }
}
