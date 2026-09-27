import AppKit
import CoreImage

let side: CGFloat = 18
let master: CGFloat = 32
let gap: CGFloat = 0.9
let count = 3
let frontSize: CGFloat = 13
let ratio: CGFloat = 1
let frontStep = CGVector(dx: 3.95, dy: -0.8)

let pointers: [(size: CGFloat, tip: CGPoint)] = {
    var result: [(size: CGFloat, tip: CGPoint)] = []
    var tip = CGPoint.zero
    for i in 0..<count {
        let shrink = pow(ratio, CGFloat(count - 1 - i))
        if i > 0 {
            tip.x += frontStep.dx / shrink
            tip.y += frontStep.dy / shrink
        }
        result.append((frontSize / shrink, tip))
    }
    return result
}()

let px = Int(side * master)
let workPx = px * 2
let full = CGRect(x: 0, y: 0, width: workPx, height: workPx)

func bitmap(_ px: Int, _ draw: (CGContext) -> Void) -> CGImage {
    let ctx = CGContext(data: nil, width: px, height: px, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.interpolationQuality = .high
    draw(ctx)
    return ctx.makeImage()!
}

func pointer(size: CGFloat, tip: CGPoint) -> CGImage {
    let config = NSImage.SymbolConfiguration(pointSize: size * master, weight: .regular)
    let sym = NSImage(systemSymbolName: "pointer.arrow", accessibilityDescription: nil)!.withSymbolConfiguration(config)!
    let drawn = bitmap(workPx) { ctx in
        NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
        sym.draw(in: CGRect(origin: .zero, size: sym.size))
        NSGraphicsContext.current = nil
    }
    let symbolTip = topmostPixel(drawn)
    let target = CGPoint(x: px.cgFloat / 2 + tip.x * master, y: px.cgFloat / 2 - tip.y * master)
    return bitmap(workPx) { ctx in
        ctx.draw(drawn, in: full.offsetBy(dx: target.x - symbolTip.x, dy: symbolTip.y - target.y))
    }
}

func topmostPixel(_ image: CGImage) -> CGPoint {
    let data = image.dataProvider!.data! as Data
    let bpr = image.bytesPerRow
    for y in 0..<image.height {
        for x in 0..<image.width where data[y * bpr + x * 4 + 3] > 0 {
            return CGPoint(x: x, y: y)
        }
    }
    fatalError("empty image")
}

extension Int { var cgFloat: CGFloat { CGFloat(self) } }

let ci = CIContext()
let layers = pointers.map { pointer(size: $0.size, tip: $0.tip) }
let halos = layers.map { layer in
    ci.createCGImage(CIImage(cgImage: layer).applyingFilter("CIMorphologyMaximum", parameters: [kCIInputRadiusKey: gap * master]), from: full)!
}

func alphaBox(_ image: CGImage) -> CGRect {
    let data = image.dataProvider!.data! as Data
    let bpr = image.bytesPerRow
    var minX = image.width, maxX = 0, minY = image.height, maxY = 0
    for y in 0..<image.height {
        for x in 0..<image.width where data[y * bpr + x * 4 + 3] > 0 {
            minX = min(minX, x); maxX = max(maxX, x); minY = min(minY, y); maxY = max(maxY, y)
        }
    }
    return CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
}

let composed = bitmap(workPx) { ctx in
    for (layer, halo) in zip(layers, halos) {
        ctx.setBlendMode(.destinationOut)
        ctx.draw(halo, in: full)
        ctx.setBlendMode(.normal)
        ctx.draw(layer, in: full)
    }
}

let box = alphaBox(composed)

precondition(box.width <= px.cgFloat && box.height <= px.cgFloat, "\(box.size) exceeds \(px)")

let centered = bitmap(px) { ctx in
    let offsetX = px.cgFloat / 2 - box.midX
    let offsetY = px.cgFloat / 2 - (workPx.cgFloat - box.midY)
    ctx.draw(composed, in: full.offsetBy(dx: offsetX, dy: offsetY))
}

func write(_ image: CGImage, scale: CGFloat, to name: String) {
    let n = Int(side * scale)
    let out = bitmap(n) { $0.draw(image, in: CGRect(x: 0, y: 0, width: n, height: n)) }
    let rep = NSBitmapImageRep(cgImage: out)
    rep.size = NSSize(width: side, height: side)
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: name))
}

write(centered, scale: 1, to: "MenuBarIcon.png")
write(centered, scale: 2, to: "MenuBarIcon@2x.png")
write(centered, scale: 3, to: "MenuBarIcon@3x.png")
