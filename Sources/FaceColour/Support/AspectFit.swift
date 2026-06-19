import CoreGraphics

/// Geometry helper for `.scaledToFit()`-style layout.
///
/// Given a content size (e.g. an image's pixel dimensions) and a container size,
/// returns the rect the content occupies when aspect-fit and centered. Used to
/// map image-space coordinates onto an on-screen, letterboxed image view.
enum AspectFit {
    static func rect(content: CGSize, in container: CGSize) -> CGRect {
        guard content.width > 0, content.height > 0,
              container.width > 0, container.height > 0 else { return .zero }

        let scale = min(container.width / content.width,
                        container.height / content.height)
        let size = CGSize(width: content.width * scale,
                          height: content.height * scale)
        let origin = CGPoint(x: (container.width - size.width) / 2,
                             y: (container.height - size.height) / 2)
        return CGRect(origin: origin, size: size)
    }
}
