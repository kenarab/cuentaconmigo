// Renders the CuentaConmigo app icon (1024x1024 PNG) with CoreGraphics.
// Usage: swift design/icon/render-icon.swift <output.png>
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let size = 1024.0
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon-1024.png"
let space = CGColorSpace(name: CGColorSpace.sRGB)!
func rgb(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(colorSpace: space, components: [CGFloat((hex >> 16) & 0xFF) / 255,
        CGFloat((hex >> 8) & 0xFF) / 255, CGFloat(hex & 0xFF) / 255, a])!
}
let ctx = CGContext(data: nil, width: Int(size), height: Int(size), bitsPerComponent: 8,
                    bytesPerRow: 0, space: space,
                    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
// Flip to top-left origin.
ctx.translateBy(x: 0, y: size); ctx.scaleBy(x: 1, y: -1)

// Background: celeste (top) to deep blue (bottom). National, non-partisan colors.
let bg = CGGradient(colorsSpace: space, colors: [rgb(0x7CB9E8), rgb(0x1D4F91)] as CFArray,
                    locations: [0, 1])!
ctx.drawLinearGradient(bg, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: size), options: [])

// Four tally strokes that are also people: a head and a body each.
let white = rgb(0xFFFFFF)
let xs: [CGFloat] = [344, 464, 584, 704]
let bodyW: CGFloat = 76, headR: CGFloat = 46
let bodyTop: CGFloat = 392, bodyBottom: CGFloat = 772, headY: CGFloat = 318
ctx.setShadow(offset: CGSize(width: 0, height: 10), blur: 24, color: rgb(0x0B2545, 0.35))
ctx.setFillColor(white)
for x in xs {
    ctx.addPath(CGPath(roundedRect: CGRect(x: x - bodyW / 2, y: bodyTop, width: bodyW,
                                           height: bodyBottom - bodyTop),
                       cornerWidth: bodyW / 2, cornerHeight: bodyW / 2, transform: nil))
    ctx.addEllipse(in: CGRect(x: x - headR, y: headY - headR, width: headR * 2, height: headR * 2))
}
ctx.fillPath()

// The fifth tally mark: the diagonal that closes the count ("conmigo"), Sol de Mayo gold.
ctx.setStrokeColor(rgb(0xF6B40E))
ctx.setLineWidth(84)
ctx.setLineCap(.round)
ctx.move(to: CGPoint(x: 262, y: 712))
ctx.addLine(to: CGPoint(x: 786, y: 452))
ctx.strokePath()

let image = ctx.makeImage()!
let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: out) as CFURL,
                                           UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, image, nil)
guard CGImageDestinationFinalize(dest) else { fatalError("could not write \(out)") }
print("wrote \(out)")
