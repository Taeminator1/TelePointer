#if DEBUG
import PointerCore
import SwiftUI

public struct Playground: View {
    public static let windowID = "playground"

    private static let ink = Color(nsColor: NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? .white : .black
    })
    private static let palette: [Color?] = [
        nil, ink, .red, .orange, .yellow, .green, .mint, .blue, .purple, .brown,
    ]
    private static let keyOrder = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
    private static let gridSpacing: CGFloat = 10
    private static let gridScales: [Int?] = [4, 8, 16, 32, nil]

    @State private var strokes: [Stroke] = []
    @State private var hovering = false
    @State private var colorIndex = 1
    @State private var hiddenColors: Set<Int> = []
    @State private var gridScaleIndex = 0

    public init() {}

    public var body: some View {
        Canvas { context, size in
            if let gridScale {
                context.stroke(gridPath(in: size, scale: gridScale), with: .color(.primary.opacity(0.08)), lineWidth: 1)
            }

            for stroke in strokes where !hiddenColors.contains(stroke.colorIndex) {
                guard let color = Self.palette[stroke.colorIndex] else { continue }

                var path = Path()
                path.addLines(stroke.points)
                context.stroke(path, with: .color(color), lineWidth: 2)
            }
        }
        .onContinuousHover(coordinateSpace: .local) { phase in
            switch phase {
            case .active(let location):
                guard canDraw else { return }

                if !hovering {
                    strokes.append(Stroke(colorIndex: colorIndex))
                    hovering = true
                }
                strokes[strokes.count - 1].points.append(location)
            case .ended:
                hovering = false
            }
        }
        .overlay(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 4) {
                shortcutRow("g", gridScale.map { "grid ×\($0)" } ?? "grid off")
                shortcutRow("c", "clear")
                shortcutRow("0–9", "change color")

                HStack(spacing: 6) {
                    let drawnColors = Set(strokes.map(\.colorIndex))

                    ForEach(Self.keyOrder, id: \.self) { index in
                        colorDot(index)
                            .opacity(isShown(index, drawnColors: drawnColors) ? 1 : 0.25)
                            .overlay {
                                if index == colorIndex {
                                    Circle()
                                        .strokeBorder(Self.palette[index] ?? .secondary, lineWidth: 1)
                                        .padding(-3)
                                }
                            }
                    }
                }
                .padding(.top, 4)
            }
            .fixedSize()
            .font(.callout)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .floatingPanel()
            .padding(16)
            .allowsHitTesting(false)
        }
        .background(Color(nsColor: .textBackgroundColor).ignoresSafeArea())
        .background {
            Group {
                Button("Clear", action: clear)
                    .keyboardShortcut("c", modifiers: [])

                Button("Grid") { gridScaleIndex = (gridScaleIndex + 1) % Self.gridScales.count }
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

    private var gridScale: Int? {
        Self.gridScales[gridScaleIndex]
    }

    private func gridPath(in size: CGSize, scale: Int) -> Path {
        let spacing = Self.gridSpacing * CGFloat(scale)
        var path = Path()

        for x in stride(from: 0, through: size.width, by: spacing) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
        }

        for y in stride(from: 0, through: size.height, by: spacing) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
        }

        return path
    }

    private var canDraw: Bool {
        Self.palette[colorIndex] != nil
    }

    private func isShown(_ index: Int, drawnColors: Set<Int>) -> Bool {
        guard index != 0 else { return true }

        return !hiddenColors.contains(index) && (index == colorIndex || drawnColors.contains(index))
    }

    private func selectColor(_ index: Int) {
        if index == colorIndex {
            guard index != 0 else { return }

            hiddenColors.insert(index)
            colorIndex = 0
        } else {
            colorIndex = index
            hiddenColors.remove(index)
        }

        guard hovering else { return }

        guard canDraw, let last = strokes.last?.points.last else {
            hovering = false
            return
        }

        strokes.append(Stroke(colorIndex: colorIndex, points: [last]))
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
    var colorIndex: Int
    var points: [CGPoint] = []
}

extension View {
    @ViewBuilder
    fileprivate func floatingPanel() -> some View {
        if #available(macOS 26, *) {
            glassEffect(.regular, in: .rect(cornerRadius: 12))
        } else {
            background(.background, in: .rect(cornerRadius: 12))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        }
    }
}

struct PlaygroundSettings: View {
    @Environment(\.openWindow) private var openWindow
    @Bindable private var experiments = ExperimentStore.shared

    var body: some View {
        Form {
            Picker("Smooth Turning", selection: $experiments.smoothTurning) {
                ForEach(SmoothTurning.allCases, id: \.self) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            Picker("Slow on Turn", selection: $experiments.slowOnTurn) {
                ForEach(SlowOnTurn.allCases, id: \.self) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            Toggle("No Hold Limit", isOn: $experiments.noHoldLimit)
        }
        .formStyle(.grouped)
        .bottomButtonBar("Open Playground") {
            openWindow(id: Playground.windowID)
        }
        .frame(width: 400)
    }
}

extension SmoothTurning {
    fileprivate var label: String {
        switch self {
        case .off: "Off"
        case .headingBlend: "Heading Blend"
        case .overshootReturn: "Overshoot Return"
        }
    }
}

extension SlowOnTurn {
    fileprivate var label: String {
        switch self {
        case .off: "Off"
        case .dip: "Dip"
        case .restartRamp: "Restart Ramp"
        }
    }
}

#Preview {
    Playground()
}
#endif
