import UIKit
import Observation

@Observable
@MainActor
final class CaptureViewModel {
    enum State: Equatable {
        case empty
        case detecting
        case detected(faceCount: Int)
        case noFace
        case failed(String)
    }

    private(set) var image: UIImage?
    private(set) var faces: [DetectedFace] = []
    private(set) var state: State = .empty

    private let detector = FaceDetector()

    /// Pixel size of the current (normalized) image, used by the overlay to map
    /// detection coordinates onto the on-screen image.
    var imagePixelSize: CGSize {
        guard let cg = image?.cgImage else { return .zero }
        return CGSize(width: cg.width, height: cg.height)
    }

    func setImage(_ newImage: UIImage) async {
        let upright = newImage.normalizedUp()
        image = upright
        faces = []
        state = .detecting

        do {
            let detected = try await detector.detectFaces(in: upright)
            // Guard against a newer image having been set while we were detecting.
            guard image === upright else { return }
            faces = detected
            state = detected.isEmpty ? .noFace : .detected(faceCount: detected.count)
        } catch {
            guard image === upright else { return }
            state = .failed(error.localizedDescription)
        }
    }

    func reset() {
        image = nil
        faces = []
        state = .empty
    }
}
