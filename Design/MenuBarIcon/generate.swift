import AppKit
import CoreImage

let side: CGFloat = 18
let radius: CGFloat = 7.9, ring: CGFloat = 1.1
let symbolSize: CGFloat = 10
let gap: CGFloat = 1.2
let master: CGFloat = 32

func bitmap(_ px: Int, _ draw: (CGContext) -> Void) -> CGImage {
    let ctx = CGContext(data: nil, width: px, height: px, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.interpolationQuality = .high
    draw(ctx)
    return ctx.makeImage()!
}

let px = Int(side * master)
let c = CGPoint(x: side / 2 * master, y: side / 2 * master)

let symbol = bitmap(px) { ctx in
    let config = NSImage.SymbolConfiguration(pointSize: symbolSize * master, weight: .regular)
    let sym = NSImage(systemSymbolName: "pointer.arrow", accessibilityDescription: nil)!.withSymbolConfiguration(config)!
    let s = sym.size
    NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
    sym.draw(in: CGRect(x: c.x - s.width / 2, y: c.y - s.height / 2, width: s.width, height: s.height))
    NSGraphicsContext.current = nil
}

let ci = CIContext()
let dilated = CIImage(cgImage: symbol).applyingFilter("CIMorphologyMaximum", parameters: [kCIInputRadiusKey: gap * master])
let halo = ci.createCGImage(dilated, from: CGRect(x: 0, y: 0, width: px, height: px))!

let full = CGRect(x: 0, y: 0, width: px, height: px)
let composed = bitmap(px) { ctx in
    ctx.setStrokeColor(.black)
    ctx.setLineWidth(ring * master)
    ctx.strokeEllipse(in: CGRect(x: c.x - radius * master, y: c.y - radius * master, width: 2 * radius * master, height: 2 * radius * master))
    ctx.setBlendMode(.destinationOut)
    ctx.draw(halo, in: full)
    ctx.setBlendMode(.normal)
    ctx.draw(symbol, in: full)
}

func write(_ image: CGImage, scale: CGFloat, to name: String) {
    let n = Int(side * scale)
    let out = bitmap(n) { $0.draw(image, in: CGRect(x: 0, y: 0, width: n, height: n)) }
    let rep = NSBitmapImageRep(cgImage: out)
    rep.size = NSSize(width: side, height: side)
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: name))
}

write(composed, scale: 1, to: "MenuBarIcon.png")
write(composed, scale: 2, to: "MenuBarIcon@2x.png")
write(composed, scale: 3, to: "MenuBarIcon@3x.png")
