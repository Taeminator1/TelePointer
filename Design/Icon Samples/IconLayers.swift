// Icon Composer 레이어 소스 생성기.
//
// 같은 기하에서 SVG(임포트용)와 합성 PNG(대조용)를 함께 뽑는다.
// Apple 지침에 따라 SVG에는 배경 · 그라디언트 · 그림자 · 불투명도를 담지 않는다.

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let canvas: CGFloat = 1024
let s = canvas
let box = CGRect(x: 0, y: 0, width: canvas, height: canvas)

// MARK: - Path

enum Seg {
    case move(CGPoint)
    case line(CGPoint)
    case curve(CGPoint, CGPoint, CGPoint)
    case close
}

enum Style {
    case fillRounded(radius: CGFloat)
    case strokeRound(width: CGFloat)
}

struct Shape {
    let segs: [Seg]
    let style: Style
}

func polygon(_ points: [CGPoint], radius: CGFloat) -> Shape {
    var segs: [Seg] = [.move(points[0])]
    segs.append(contentsOf: points.dropFirst().map { Seg.line($0) })
    segs.append(.close)
    return Shape(segs: segs, style: .fillRounded(radius: radius))
}

func polyline(_ points: [CGPoint], width: CGFloat) -> Shape {
    var segs: [Seg] = [.move(points[0])]
    segs.append(contentsOf: points.dropFirst().map { Seg.line($0) })
    return Shape(segs: segs, style: .strokeRound(width: width))
}

// MARK: - Cursor

let cursorUnit: [CGPoint] = [
    CGPoint(x: 0.000, y: 0.000),
    CGPoint(x: 0.000, y: 0.896),
    CGPoint(x: 0.229, y: 0.675),
    CGPoint(x: 0.396, y: 1.000),
    CGPoint(x: 0.542, y: 0.929),
    CGPoint(x: 0.375, y: 0.608),
    CGPoint(x: 0.688, y: 0.608),
]

let cursorAspect: CGFloat = 0.688

func cursor(tip: CGPoint, height: CGFloat, radius: CGFloat) -> Shape {
    polygon(
        cursorUnit.map { CGPoint(x: tip.x + $0.x * height, y: tip.y + $0.y * height) },
        radius: radius
    )
}

enum Side { case up, down, left, right }

func chevron(center: CGPoint, size: CGFloat, thickness: CGFloat, side: Side) -> Shape {
    let across = size
    let along = size * 0.58
    let points: [CGPoint]
    switch side {
    case .up:
        points = [
            CGPoint(x: center.x - across / 2, y: center.y + along / 2),
            CGPoint(x: center.x, y: center.y - along / 2),
            CGPoint(x: center.x + across / 2, y: center.y + along / 2),
        ]
    case .down:
        points = [
            CGPoint(x: center.x - across / 2, y: center.y - along / 2),
            CGPoint(x: center.x, y: center.y + along / 2),
            CGPoint(x: center.x + across / 2, y: center.y - along / 2),
        ]
    case .left:
        points = [
            CGPoint(x: center.x + along / 2, y: center.y - across / 2),
            CGPoint(x: center.x - along / 2, y: center.y),
            CGPoint(x: center.x + along / 2, y: center.y + across / 2),
        ]
    case .right:
        points = [
            CGPoint(x: center.x - along / 2, y: center.y - across / 2),
            CGPoint(x: center.x + along / 2, y: center.y),
            CGPoint(x: center.x - along / 2, y: center.y + across / 2),
        ]
    }
    return polyline(points, width: thickness)
}

// MARK: - Spec

struct Layer {
    let group: String
    let name: String
    /// Icon Composer 의 Color > Opacity 에 넣을 값. 소스에는 담지 않는다.
    let opacity: Int
    let shapes: [Shape]
}

struct IconSpec {
    let id: String
    let title: String
    let background: (UInt32, UInt32)
    let layers: [Layer]
}

// MARK: - A. 커서 + 십자 방향

let crosshair: IconSpec = {
    let c = CGPoint(x: box.midX, y: box.midY)
    let distance = s * 0.375
    let chevrons: [Shape] = [
        chevron(center: CGPoint(x: c.x, y: c.y - distance), size: s * 0.2, thickness: s * 0.055, side: .up),
        chevron(center: CGPoint(x: c.x, y: c.y + distance), size: s * 0.2, thickness: s * 0.055, side: .down),
        chevron(center: CGPoint(x: c.x - distance, y: c.y), size: s * 0.2, thickness: s * 0.055, side: .left),
        chevron(center: CGPoint(x: c.x + distance, y: c.y), size: s * 0.2, thickness: s * 0.055, side: .right),
    ]
    let height = s * 0.38
    let tip = CGPoint(x: c.x - height * cursorAspect * 0.44, y: c.y - height * 0.44)
    return IconSpec(
        id: "A-crosshair",
        title: "커서 + 십자 방향",
        background: (0x6E8CFF, 0x2A34C4),
        layers: [
            Layer(group: "1-Directions", name: "1-chevrons", opacity: 66, shapes: chevrons),
            Layer(
                group: "2-Cursor",
                name: "1-cursor",
                opacity: 100,
                shapes: [cursor(tip: tip, height: height, radius: s * 0.016)]
            ),
        ]
    )
}()

// MARK: - B. 속도 곡선

let speedRamp: IconSpec = {
    let g = box.insetBy(dx: s * 0.225, dy: s * 0.225)
    let axis = polyline(
        [
            CGPoint(x: g.minX, y: g.minY - s * 0.03),
            CGPoint(x: g.minX, y: g.maxY),
            CGPoint(x: g.maxX + s * 0.03, y: g.maxY),
        ],
        width: s * 0.024
    )
    let curve = Shape(
        segs: [
            .move(CGPoint(x: g.minX, y: g.maxY)),
            .curve(
                CGPoint(x: g.minX + g.width / 3, y: g.maxY),
                CGPoint(x: g.minX + g.width * 2 / 3, y: g.maxY - g.height / 3),
                CGPoint(x: g.maxX, y: g.minY)
            ),
        ],
        style: .strokeRound(width: s * 0.082)
    )
    let height = s * 0.28
    let tip = CGPoint(x: g.maxX - s * 0.012, y: g.minY - s * 0.005)
    return IconSpec(
        id: "B-speed-ramp",
        title: "속도 곡선",
        background: (0x2C4C9E, 0x0B1233),
        layers: [
            Layer(group: "1-Graph", name: "1-axis", opacity: 32, shapes: [axis]),
            Layer(group: "1-Graph", name: "2-curve", opacity: 100, shapes: [curve]),
            Layer(
                group: "2-Cursor",
                name: "1-cursor",
                opacity: 100,
                shapes: [cursor(tip: tip, height: height, radius: s * 0.014)]
            ),
        ]
    )
}()

// MARK: - C. 잔상

let warpTrail: IconSpec = {
    let height = s * 0.48
    let base = CGPoint(x: box.midX - height * cursorAspect * 0.28, y: box.midY - height * 0.54)
    let radius = s * 0.018
    func ghost(back: CGFloat, scale: CGFloat) -> Shape {
        cursor(
            tip: CGPoint(x: base.x + s * back, y: base.y + s * back),
            height: height * scale,
            radius: radius
        )
    }
    return IconSpec(
        id: "C-warp-trail",
        title: "잔상",
        background: (0xB158FF, 0x4C1FBE),
        layers: [
            Layer(group: "1-Trail", name: "1-ghost-far", opacity: 22, shapes: [ghost(back: 0.255, scale: 0.72)]),
            Layer(group: "1-Trail", name: "2-ghost-near", opacity: 42, shapes: [ghost(back: 0.13, scale: 0.86)]),
            Layer(
                group: "2-Cursor",
                name: "1-cursor",
                opacity: 100,
                shapes: [cursor(tip: base, height: height, radius: radius)]
            ),
        ]
    )
}()

// MARK: - F. 속도선

let speedLines: IconSpec = {
    let height = s * 0.44
    let tip = CGPoint(x: box.minX + s * 0.285, y: box.minY + s * 0.185)
    let d = CGPoint(x: 0.7071, y: 0.7071)
    let n = CGPoint(x: 0.7071, y: -0.7071)
    let anchor = CGPoint(x: tip.x + d.x * s * 0.5, y: tip.y + d.y * s * 0.5)
    let width = s * 0.056

    func streak(offset: CGFloat, start: CGFloat, length: CGFloat) -> Shape {
        let from = CGPoint(
            x: anchor.x + n.x * offset * s + d.x * start * s,
            y: anchor.y + n.y * offset * s + d.y * start * s
        )
        let to = CGPoint(x: from.x + d.x * length * s, y: from.y + d.y * length * s)
        return polyline([from, to], width: width)
    }

    return IconSpec(
        id: "F-speed-lines",
        title: "속도선",
        background: (0x3D7BFF, 0x1B2E86),
        layers: [
            Layer(
                group: "1-Trail",
                name: "1-streak-outer",
                opacity: 50,
                shapes: [
                    streak(offset: 0.115, start: 0.035, length: 0.135),
                    streak(offset: -0.115, start: 0.035, length: 0.135),
                ]
            ),
            Layer(
                group: "1-Trail",
                name: "2-streak-center",
                opacity: 95,
                shapes: [streak(offset: 0, start: 0, length: 0.215)]
            ),
            Layer(
                group: "2-Cursor",
                name: "1-cursor",
                opacity: 100,
                shapes: [cursor(tip: tip, height: height, radius: s * 0.018)]
            ),
        ]
    )
}()

let specs = [crosshair, speedRamp, warpTrail, speedLines]

// MARK: - SVG 출력

func svgPath(_ shape: Shape) -> String {
    func f(_ value: CGFloat) -> String {
        let rounded = (value * 100).rounded() / 100
        return rounded == rounded.rounded() ? String(Int(rounded)) : String(format: "%.2f", rounded)
    }
    var d: [String] = []
    for seg in shape.segs {
        switch seg {
        case let .move(p): d.append("M\(f(p.x)) \(f(p.y))")
        case let .line(p): d.append("L\(f(p.x)) \(f(p.y))")
        case let .curve(c1, c2, p):
            d.append("C\(f(c1.x)) \(f(c1.y)) \(f(c2.x)) \(f(c2.y)) \(f(p.x)) \(f(p.y))")
        case .close: d.append("Z")
        }
    }
    let attrs: String
    switch shape.style {
    case let .fillRounded(radius):
        attrs = ##"fill="#FFFFFF" stroke="#FFFFFF" stroke-width="\##(f(radius * 2))" "##
            + ##"stroke-linejoin="round" stroke-linecap="round""##
    case let .strokeRound(width):
        attrs = ##"fill="none" stroke="#FFFFFF" stroke-width="\##(f(width))" "##
            + ##"stroke-linejoin="round" stroke-linecap="round""##
    }
    return #"  <path d="\#(d.joined(separator: " "))" \#(attrs)/>"#
}

func svgDocument(_ shapes: [Shape]) -> String {
    let header = #"<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" "#
        + #"viewBox="0 0 1024 1024">"#
    return ([header] + shapes.map(svgPath) + ["</svg>", ""]).joined(separator: "\n")
}

// MARK: - 대조용 PNG

func srgb(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(
        srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
        green: CGFloat((hex >> 8) & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: alpha
    )
}

func addShape(_ ctx: CGContext, _ shape: Shape) {
    let path = CGMutablePath()
    for seg in shape.segs {
        switch seg {
        case let .move(p): path.move(to: p)
        case let .line(p): path.addLine(to: p)
        case let .curve(c1, c2, p): path.addCurve(to: p, control1: c1, control2: c2)
        case .close: path.closeSubpath()
        }
    }
    ctx.setLineJoin(.round)
    ctx.setLineCap(.round)
    ctx.addPath(path)
    switch shape.style {
    case let .fillRounded(radius):
        ctx.setLineWidth(radius * 2)
        ctx.drawPath(using: .fillStroke)
    case let .strokeRound(width):
        ctx.setLineWidth(width)
        ctx.strokePath()
    }
}

func composite(_ spec: IconSpec, px: Int, mask: Bool) -> CGImage {
    let space = CGColorSpace(name: CGColorSpace.sRGB)!
    let ctx = CGContext(
        data: nil,
        width: px,
        height: px,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: space,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    ctx.interpolationQuality = .high
    let scale = CGFloat(px) / canvas
    ctx.scaleBy(x: scale, y: scale)
    ctx.translateBy(x: 0, y: canvas)
    ctx.scaleBy(x: 1, y: -1)

    let shape = mask
        ? CGPath(roundedRect: box, cornerWidth: canvas * 0.2255, cornerHeight: canvas * 0.2255, transform: nil)
        : CGPath(rect: box, transform: nil)
    ctx.saveGState()
    ctx.addPath(shape)
    ctx.clip()

    let gradient = CGGradient(
        colorsSpace: space,
        colors: [srgb(spec.background.0), srgb(spec.background.1)] as CFArray,
        locations: [0, 1]
    )!
    ctx.drawLinearGradient(
        gradient,
        start: CGPoint(x: box.minX, y: box.minY),
        end: CGPoint(x: box.maxX, y: box.maxY),
        options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
    )

    for layer in spec.layers {
        ctx.saveGState()
        let alpha = CGFloat(layer.opacity) / 100
        ctx.setFillColor(srgb(0xFFFFFF, alpha))
        ctx.setStrokeColor(srgb(0xFFFFFF, alpha))
        for shape in layer.shapes { addShape(ctx, shape) }
        ctx.restoreGState()
    }
    ctx.restoreGState()
    return ctx.makeImage()!
}

func writePNG(_ image: CGImage, to path: String) {
    let dest = CGImageDestinationCreateWithURL(
        URL(fileURLWithPath: path) as CFURL,
        UTType.png.identifier as CFString,
        1,
        nil
    )!
    CGImageDestinationAddImage(dest, image, nil)
    CGImageDestinationFinalize(dest)
}

// MARK: - 실행

let root = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "IconComposer"
let fm = FileManager.default

for spec in specs {
    var groups: [String] = []
    for layer in spec.layers {
        let dir = "\(root)/\(spec.id)/\(layer.group)"
        try! fm.createDirectory(atPath: dir, withIntermediateDirectories: true)
        try! svgDocument(layer.shapes).write(toFile: "\(dir)/\(layer.name).svg", atomically: true, encoding: .utf8)
        if !groups.contains(layer.group) { groups.append(layer.group) }
    }
    let checkDir = "\(root)/_check"
    try! fm.createDirectory(atPath: checkDir, withIntermediateDirectories: true)
    writePNG(composite(spec, px: 512, mask: true), to: "\(checkDir)/\(spec.id).png")

    let layerList = spec.layers.map { "\($0.group)/\($0.name) @\($0.opacity)%" }.joined(separator: ", ")
    print("\(spec.id)  groups=\(groups.count)  \(layerList)")
}
