import SwiftUI

/// Draws detected face bounding boxes and landmark dots on top of an aspect-fit
/// image. Maps image-pixel coordinates into the on-screen letterboxed image rect.
struct FaceOverlayView: View {
    /// Pixel size of the displayed image.
    let imageSize: CGSize
    /// Faces in image-pixel coordinates, top-left origin.
    let faces: [DetectedFace]
    /// Sampled skin patches in image-pixel coordinates, top-left origin.
    var patches: [CGRect] = []

    var body: some View {
        GeometryReader { geo in
            let fitted = AspectFit.rect(content: imageSize, in: geo.size)
            let scale = imageSize.width > 0 ? fitted.width / imageSize.width : 0

            ForEach(Array(patches.enumerated()), id: \.offset) { _, patch in
                let r = CGRect(
                    x: fitted.minX + patch.minX * scale,
                    y: fitted.minY + patch.minY * scale,
                    width: patch.width * scale,
                    height: patch.height * scale
                )
                Rectangle()
                    .strokeBorder(Color.white.opacity(0.9), lineWidth: 1.5)
                    .frame(width: r.width, height: r.height)
                    .position(x: r.midX, y: r.midY)
            }

            ForEach(faces) { face in
                let box = CGRect(
                    x: fitted.minX + face.boundingBox.minX * scale,
                    y: fitted.minY + face.boundingBox.minY * scale,
                    width: face.boundingBox.width * scale,
                    height: face.boundingBox.height * scale
                )

                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, lineWidth: 2)
                    .frame(width: box.width, height: box.height)
                    .position(x: box.midX, y: box.midY)

                ForEach(Array(face.landmarks.enumerated()), id: \.offset) { _, point in
                    Circle()
                        .fill(Color.accentColor.opacity(0.85))
                        .frame(width: 2.5, height: 2.5)
                        .position(
                            x: fitted.minX + point.x * scale,
                            y: fitted.minY + point.y * scale
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }
}
