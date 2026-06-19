import UIKit

/// Pulls skin pixel samples out of an image for a detected face.
///
/// Patches are placed geometrically from the face bounding box (two cheeks +
/// forehead) — robust and landmark-label-free. Landmark-guided patches are a
/// possible future refinement. Coordinates are image pixels, top-left origin,
/// matching `DetectedFace` (image is expected upright — see `UIImage.normalizedUp()`).
struct SkinSampler {
    struct Output {
        let samples: [RGBColor]
        /// Sampled regions, image-pixel coordinates — for the on-screen overlay.
        let patches: [CGRect]
    }

    /// Each patch is downscaled to at most `resolution`×`resolution` before reading,
    /// to bound work regardless of source image size.
    func sample(image: UIImage, face: DetectedFace, resolution: Int = 24) -> Output {
        guard let cg = image.cgImage else { return Output(samples: [], patches: []) }

        let box = face.boundingBox
        let w = box.width, h = box.height
        let side = w * 0.16

        func patch(cx: CGFloat, cy: CGFloat) -> CGRect {
            CGRect(x: cx - side / 2, y: cy - side / 2, width: side, height: side)
        }

        let candidates = [
            patch(cx: box.midX, cy: box.minY + h * 0.18),          // forehead
            patch(cx: box.minX + w * 0.27, cy: box.minY + h * 0.62), // left cheek
            patch(cx: box.minX + w * 0.73, cy: box.minY + h * 0.62), // right cheek
        ]

        let bounds = CGRect(x: 0, y: 0, width: cg.width, height: cg.height)
        let rects = candidates
            .map { $0.integral.intersection(bounds) }
            .filter { $0.width >= 2 && $0.height >= 2 }

        var samples: [RGBColor] = []
        for rect in rects {
            samples.append(contentsOf: Self.readPixels(in: rect, of: cg, resolution: resolution))
        }
        return Output(samples: samples, patches: rects)
    }

    /// Crops to `rect`, scales into a small RGBA8 buffer, and reads back samples.
    private static func readPixels(in rect: CGRect, of cg: CGImage, resolution: Int) -> [RGBColor] {
        guard let cropped = cg.cropping(to: rect) else { return [] }
        let outW = min(resolution, cropped.width)
        let outH = min(resolution, cropped.height)
        guard outW > 0, outH > 0 else { return [] }

        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * outW
        var data = [UInt8](repeating: 0, count: bytesPerRow * outH)

        guard let ctx = CGContext(
            data: &data,
            width: outW,
            height: outH,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return [] }

        ctx.interpolationQuality = .medium
        ctx.draw(cropped, in: CGRect(x: 0, y: 0, width: outW, height: outH))

        var result: [RGBColor] = []
        result.reserveCapacity(outW * outH)
        var i = 0
        while i + 3 < data.count {
            if data[i + 3] > 0 { // skip fully transparent
                result.append(RGBColor(r8: data[i], g8: data[i + 1], b8: data[i + 2]))
            }
            i += bytesPerPixel
        }
        return result
    }
}
