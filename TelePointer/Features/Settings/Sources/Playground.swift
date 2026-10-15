import SwiftUI

public struct Playground: View {
    public static let windowID = "playground"

    @State private var strokes: [[CGPoint]] = []
    @State private var hovering = false

    public init() {}

    public var body: some View {
        Canvas { context, _ in
            for stroke in strokes {
                var path = Path()
                path.addLines(stroke)
                context.stroke(path, with: .color(.black), lineWidth: 2)
            }
        }
        .onContinuousHover(coordinateSpace: .local) { phase in
            switch phase {
            case .active(let location):
                if !hovering {
                    strokes.append([])
                    hovering = true
                }
                strokes[strokes.count - 1].append(location)
            case .ended:
                hovering = false
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Text("Press esc to clear")
                .font(.callout)
                .foregroundStyle(.black.opacity(0.3))
                .padding(12)
                .allowsHitTesting(false)
        }
        .background(Color.white.ignoresSafeArea())
        .background {
            Button("Clear", action: clear)
                .keyboardShortcut(.cancelAction)
                .opacity(0)
        }
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        .onDisappear(perform: clear)
        .frame(minWidth: 600, minHeight: 400)
    }

    private func clear() {
        strokes.removeAll()
        hovering = false
    }
}

struct PlaygroundSettings: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Form {
            Button("Open Playground") {
                openWindow(id: Playground.windowID)
            }
        }
        .formStyle(.grouped)
        .frame(width: 400)
    }
}

#Preview {
    Playground()
}
