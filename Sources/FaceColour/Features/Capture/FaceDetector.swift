import UIKit
import Vision

enum FaceDetectionError: LocalizedError {
    case noImageData

    var errorDescription: String? {
        switch self {
        case .noImageData: return "Couldn't read that image. Try another photo."
        }
    }
}

/// Thin wrapper over Vision's face-landmark detection.
///
/// Input is expected to be an upright (`.up`) image — see `UIImage.normalizedUp()`.
/// Output coordinates are in image pixels with a top-left origin (see `DetectedFace`).
struct FaceDetector {
    func detectFaces(in image: UIImage) async throws -> [DetectedFace] {
        guard let cgImage = image.cgImage else { throw FaceDetectionError.noImageData }
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        // Vision's perform() is synchronous; run it off the main actor.
        return try await Task.detached(priority: .userInitiated) {
            let request = VNDetectFaceLandmarksRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
            try handler.perform([request])

            let observations = (request.results as? [VNFaceObservation]) ?? []
            return observations.map { obs in
                Self.makeFace(from: obs, imageWidth: width, imageHeight: height)
            }
        }.value
    }

    /// Converts a Vision observation (normalized, bottom-left origin) into a
    /// `DetectedFace` in pixel space with a top-left origin.
    private static func makeFace(from obs: VNFaceObservation,
                                 imageWidth width: CGFloat,
                                 imageHeight height: CGFloat) -> DetectedFace {
        let bb = obs.boundingBox
        let box = CGRect(
            x: bb.minX * width,
            y: (1 - bb.maxY) * height,
            width: bb.width * width,
            height: bb.height * height
        )

        var points: [CGPoint] = []
        if let all = obs.landmarks?.allPoints {
            let imageSize = CGSize(width: width, height: height)
            points = all.pointsInImage(imageSize: imageSize).map { p in
                CGPoint(x: p.x, y: height - p.y) // flip to top-left origin
            }
        }

        return DetectedFace(boundingBox: box, landmarks: points)
    }
}
