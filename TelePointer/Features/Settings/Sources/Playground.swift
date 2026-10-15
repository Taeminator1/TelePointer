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
        .background(Color.white.ignoresSafeArea())
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        .onDisappear {
            strokes.removeAll()
            hovering = false
        }
        .frame(minWidth: 600, minHeight: 400)
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
