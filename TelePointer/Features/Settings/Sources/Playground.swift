#if DEBUG
import SwiftUI

public struct Playground: View {
    public static let windowID = "playground"

    private static let palette: [Color?] = [
        nil, .black, .red, .orange, .yellow, .green, .mint, .blue, .purple, .pink,
    ]

    @State private var strokes: [Stroke] = []
    @State private var hovering = false
    @State private var colorIndex = 1

    public init() {}

    public var body: some View {
        Canvas { context, _ in
            for stroke in strokes {
                var path = Path()
                path.addLines(stroke.points)
                context.stroke(path, with: .color(stroke.color), lineWidth: 2)
            }
        }
        .onContinuousHover(coordinateSpace: .local) { phase in
            switch phase {
            case .active(let location):
                guard let color = Self.palette[colorIndex] else { return }

                if !hovering {
                    strokes.append(Stroke(color: color))
                    hovering = true
                }
                strokes[strokes.count - 1].points.append(location)
            case .ended:
                hovering = false
            }
        }
        .overlay(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("**0–9** change color")

                    HStack(spacing: 2) {
                        Text("(")
                        colorIndicator
                        Text(", \(colorIndex))")
                    }
                }

                Text("**esc** clear")
            }
            .font(.callout)
            .foregroundStyle(.black.opacity(0.6))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .floatingPanel()
            .padding(16)
            .allowsHitTesting(false)
        }
        .background(Color.white.ignoresSafeArea())
        .background {
            Group {
                Button("Clear", action: clear)
                    .keyboardShortcut(.cancelAction)

                ForEach(Self.palette.indices, id: \.self) { index in
                    Button("Color \(index)") { selectColor(index) }
                        .keyboardShortcut(KeyEquivalent(Character("\(index)")), modifiers: [])
                }
            }
            .opacity(0)
        }
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        .onDisappear(perform: clear)
        .frame(minWidth: 600, minHeight: 400)
    }

    private func selectColor(_ index: Int) {
        guard index != colorIndex else { return }

        colorIndex = index

        guard hovering, let last = strokes.last?.points.last else { return }

        guard let color = Self.palette[index] else {
            hovering = false
            return
        }

        strokes.append(Stroke(color: color, points: [last]))
    }

    @ViewBuilder
    private var colorIndicator: some View {
        if let color = Self.palette[colorIndex] {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
        } else {
            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                .frame(width: 10, height: 10)
        }
    }

    private func clear() {
        strokes.removeAll()
        hovering = false
    }
}

private struct Stroke {
    var color: Color
    var points: [CGPoint] = []
}

extension View {
    @ViewBuilder
    fileprivate func floatingPanel() -> some View {
        if #available(macOS 26, *) {
            glassEffect(.regular, in: .rect(cornerRadius: 12))
        } else {
            background(.white, in: .rect(cornerRadius: 12))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        }
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
#endif
