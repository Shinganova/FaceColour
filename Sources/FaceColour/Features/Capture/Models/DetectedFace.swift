import CoreGraphics
import Foundation

/// A face found in an image.
///
/// All coordinates are in **image pixel space** with a **top-left origin**
/// (i.e. already converted out of Vision's normalized, bottom-left space).
struct DetectedFace: Identifiable {
    let id = UUID()

    /// Face bounding box, in image pixels, top-left origin.
    let boundingBox: CGRect

    /// Landmark points (eyes, nose, mouth, contour, …), in image pixels, top-left origin.
    /// May be empty if landmark detection produced no points.
    let landmarks: [CGPoint]
}
