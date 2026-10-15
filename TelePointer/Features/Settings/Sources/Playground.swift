#if DEBUG
import PointerCore
import SwiftUI

public struct Playground: View {
    public static let windowID = "playground"

    private static let palette: [Color?] = [
        nil, .black, .red, .orange, .yellow, .green, .mint, .blue, .purple, .brown,
    ]
    private static let keyOrder = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
    private static let gridSpacing: CGFloat = 20

    @State private var strokes: [Stroke] = []
    @State private var hovering = false
    @State private var colorIndex = 1
    @State private var showsGrid = true

    public init() {}

    public var body: some View {
        Canvas { context, size in
            if showsGrid {
                context.stroke(gridPath(in: size), with: .color(.black.opacity(0.08)), lineWidth: 1)
            }

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
                shortcutRow("g", "grid")
                shortcutRow("c", "clear")
                shortcutRow("0–9", "change color")

                HStack(spacing: 4) {
                    ForEach(Self.keyOrder, id: \.self) { index in
                        colorDot(index)
                            .opacity(index == colorIndex ? 1 : 0.25)
                            .shadow(
                                color: .black.opacity(index == colorIndex ? 0.35 : 0),
                                radius: 1.5,
                                y: 1
                            )
                    }
                }
                .padding(.top, 4)
            }
            .fixedSize()
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
                    .keyboardShortcut("c", modifiers: [])

                Button("Grid") { showsGrid.toggle() }
                    .keyboardShortcut("g", modifiers: [])

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

    private func gridPath(in size: CGSize) -> Path {
        var path = Path()

        for x in stride(from: 0, through: size.width, by: Self.gridSpacing) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
        }

        for y in stride(from: 0, through: size.height, by: Self.gridSpacing) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
        }

        return path
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

    private func shortcutRow(_ key: LocalizedStringKey, _ description: LocalizedStringKey) -> some View {
        HStack {
            Text(key).bold()
            Spacer()
            Text(description)
        }
    }

    @ViewBuilder
    private func colorDot(_ index: Int) -> some View {
        if let color = Self.palette[index] {
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
    @Bindable private var experiments = ExperimentStore.shared

    var body: some View {
        Form {
            Toggle("Smooth Turning", isOn: $experiments.smoothTurning)
        }
        .formStyle(.grouped)
        .bottomButtonBar("Open Playground") {
            openWindow(id: Playground.windowID)
        }
        .frame(width: 400)
    }
}

#Preview {
    Playground()
}
#endif
