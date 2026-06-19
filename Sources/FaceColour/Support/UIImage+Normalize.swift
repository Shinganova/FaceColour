import UIKit

extension UIImage {
    /// Returns a copy redrawn with `.up` orientation so downstream pixel math
    /// (Vision detection, skin sampling) never has to account for EXIF rotation.
    func normalizedUp() -> UIImage {
        guard imageOrientation != .up else { return self }
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = true
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
