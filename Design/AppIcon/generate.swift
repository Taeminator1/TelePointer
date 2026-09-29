import Foundation

let canvas: Double = 1024
let glyphSize: Double = 740
let count = 3
let step = Point(150, 30)

struct Point {
    var x, y: Double
    init(_ x: Double, _ y: Double) { self.x = x; self.y = y }
    static func + (a: Point, b: Point) -> Point { Point(a.x + b.x, a.y + b.y) }
    static func - (a: Point, b: Point) -> Point { Point(a.x - b.x, a.y - b.y) }
    static func * (a: Point, s: Double) -> Point { Point(a.x * s, a.y * s) }
    var length: Double { (x * x + y * y).squareRoot() }
    var unit: Point { self * (1 / length) }
}

let tailDirection = Point(0.4, 0.92).unit
let tailNormal = Point(tailDirection.y, -tailDirection.x)
let notchLeft = Point(95, 290)
let tailEndLeft = notchLeft + tailDirection * 190
let tailEndRight = tailEndLeft + tailNormal * 72
let notchRight = tailEndRight - tailDirection * 178

let outline: [(point: Point, radius: Double)] = [
    (Point(0, 0), 30),
    (Point(282, 282), 24),
    (notchRight, 10),
    (tailEndRight, 36),
    (tailEndLeft, 36),
    (notchLeft, 10),
    (Point(0, 380), 24),
]

struct Corner {
    var start, end, center: Point
    var radius: Double
    var clockwise: Bool
}

let corners: [Corner] = outline.indices.map { i in
    let n = outline.count
    let (vertex, radius) = outline[i]
    let prev = outline[(i + n - 1) % n].point
    let next = outline[(i + 1) % n].point
    let toPrev = (prev - vertex).unit, toNext = (next - vertex).unit
    let angle = acos(toPrev.x * toNext.x + toPrev.y * toNext.y)
    let bisector = (toPrev + toNext).unit
    let cross = (vertex - prev).x * (next - vertex).y - (vertex - prev).y * (next - vertex).x
    return Corner(
        start: vertex + toPrev * (radius / tan(angle / 2)),
        end: vertex + toNext * (radius / tan(angle / 2)),
        center: vertex + bisector * (radius / sin(angle / 2)),
        radius: radius,
        clockwise: cross > 0
    )
}

let arcPoints = corners.flatMap { corner in
    let from = atan2(corner.start.y - corner.center.y, corner.start.x - corner.center.x)
    let to = atan2(corner.end.y - corner.center.y, corner.end.x - corner.center.x)
    let sweep = remainder(to - from, 2 * .pi)
    return (0...32).map { k in
        let a = from + sweep * Double(k) / 32
        return corner.center + Point(cos(a), sin(a)) * corner.radius
    }
}

let xs = arcPoints.map(\.x), ys = arcPoints.map(\.y)
let shape = (min: Point(xs.min()!, ys.min()!), max: Point(xs.max()!, ys.max()!))
let whole = (min: shape.min, max: shape.max + step * Double(count - 1))
let size = whole.max - whole.min
let scale = glyphSize / max(size.x, size.y)
let origin = Point(canvas / 2, canvas / 2) - (whole.min + size * 0.5) * scale

func format(_ v: Double) -> String { String(format: "%.2f", v) }
func format(_ p: Point) -> String { "\(format(p.x)) \(format(p.y))" }

func path(offset: Point) -> String {
    let map = { (p: Point) in origin + (p + offset) * scale }
    let d = corners.enumerated().map { i, corner in
        (i == 0 ? "M" : "L") + format(map(corner.start))
            + "A\(format(corner.radius * scale)) \(format(corner.radius * scale)) 0 0 \(corner.clockwise ? 1 : 0) \(format(map(corner.end)))"
    }
    return d.joined() + "Z"
}

for i in 0..<count {
    let svg = """
    <svg xmlns="http://www.w3.org/2000/svg" width="\(Int(canvas))" height="\(Int(canvas))" viewBox="0 0 \(Int(canvas)) \(Int(canvas))">
      <path d="\(path(offset: step * Double(i)))" fill="#000000"/>
    </svg>

    """
    try! svg.write(toFile: "Pointer\(i + 1).svg", atomically: true, encoding: .utf8)
}
