import SwiftUI

struct MenuBarContent: View {
    var body: some View {
        Button("Move Pointer") {
            // TODO: 커서를 현재 화면 정중앙으로 이동
        }

        Button("Open at Login") {
            // TODO: 로그인 항목 등록/해제 토글
        }

        Divider()

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
