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
    private(set) var skinResult: SkinToneResult?
    private(set) var samplePatches: [CGRect] = []
    private(set) var season: Season?
    private(set) var seasonGuide: SeasonGuide?

    private let detector = FaceDetector()
    private let sampler = SkinSampler()
    private let analyzer = SkinToneAnalyzer()
    private let guideBook = SeasonGuideLoader.loadBundled()

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
        skinResult = nil
        samplePatches = []
        season = nil
        seasonGuide = nil
        state = .detecting

        do {
            let detected = try await detector.detectFaces(in: upright)
            // Guard against a newer image having been set while we were detecting.
            guard image === upright else { return }
            faces = detected

            // Analyze skin tone on the largest (primary) face.
            if let primary = detected.max(by: { $0.boundingBox.area < $1.boundingBox.area }) {
                let output = sampler.sample(image: upright, face: primary)
                samplePatches = output.patches
                skinResult = analyzer.analyze(samples: output.samples)

                if let skin = skinResult {
                    let s = Season.classify(undertone: skin.undertone,
                                            depth: skin.fitzpatrick,
                                            hueAngle: skin.hueAngle)
                    season = s
                    seasonGuide = guideBook?[s]
                }
            }

            state = detected.isEmpty ? .noFace : .detected(faceCount: detected.count)
        } catch {
            guard image === upright else { return }
            state = .failed(error.localizedDescription)
        }
    }

    func reset() {
        image = nil
        faces = []
        skinResult = nil
        samplePatches = []
        season = nil
        seasonGuide = nil
        state = .empty
    }
}
