import UIKit
import Observation

/// Observable store of saved analyses, backed by `HistoryArchive` + thumbnail files.
@Observable
@MainActor
final class HistoryStore {
    private(set) var records: [AnalysisRecord] = []
    private let archive: HistoryArchive

    init(directory: URL = HistoryArchive.defaultDirectory) {
        archive = HistoryArchive(directory: directory)
        records = archive.load()
    }

    func add(_ record: AnalysisRecord, thumbnail: UIImage?) {
        var stored = record
        if let thumbnail, let name = saveThumbnail(thumbnail, id: record.id) {
            stored.thumbnailFileName = name
        }
        records.insert(stored, at: 0)
        try? archive.save(records)
    }

    func delete(_ record: AnalysisRecord) {
        records.removeAll { $0.id == record.id }
        if let name = record.thumbnailFileName {
            try? FileManager.default.removeItem(at: archive.directory.appendingPathComponent(name))
        }
        try? archive.save(records)
    }

    func thumbnail(for record: AnalysisRecord) -> UIImage? {
        guard let name = record.thumbnailFileName else { return nil }
        return UIImage(contentsOfFile: archive.directory.appendingPathComponent(name).path)
    }

    private func saveThumbnail(_ image: UIImage, id: UUID) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        let name = "\(id.uuidString).jpg"
        try? FileManager.default.createDirectory(at: archive.directory, withIntermediateDirectories: true)
        try? data.write(to: archive.directory.appendingPathComponent(name), options: .atomic)
        return name
    }
}
