import Foundation

final class PersistenceManager {
    static let shared = PersistenceManager()
    private init() {}

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return e
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    func ensureDirectories() {
        [DocumentsDirectory.manualsDirectoryURL, DocumentsDirectory.exportDirectoryURL].forEach {
            try? FileManager.default.createDirectory(at: $0, withIntermediateDirectories: true)
        }
    }

    func loadStudios() -> [Studio] {
        let url = DocumentsDirectory.studiosFileURL
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let studios = try? decoder.decode([Studio].self, from: data)
        else { return [] }
        return studios
    }

    func saveStudios(_ studios: [Studio]) {
        guard let data = try? encoder.encode(studios) else { return }
        try? data.write(to: DocumentsDirectory.studiosFileURL, options: .atomic)
    }

    // MARK: - Export / Import

    func exportURL(for studios: [Studio]) -> URL? {
        guard let data = try? encoder.encode(studios) else { return nil }
        let url = DocumentsDirectory.exportDirectoryURL
            .appendingPathComponent("StudioMap-Export-\(dateStamp()).json")
        try? data.write(to: url, options: .atomic)
        return url
    }

    func importStudios(from url: URL) -> [Studio]? {
        guard url.startAccessingSecurityScopedResource() else { return nil }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let data = try? Data(contentsOf: url),
              let studios = try? decoder.decode([Studio].self, from: data)
        else { return nil }
        return studios
    }

    // MARK: - PDF Manuals

    func savePDF(data: Data, forDeviceId id: UUID) -> String {
        let deviceDir = DocumentsDirectory.manualsDirectoryURL.appendingPathComponent(id.uuidString)
        try? FileManager.default.createDirectory(at: deviceDir, withIntermediateDirectories: true)
        let fileURL = deviceDir.appendingPathComponent("manual.pdf")
        try? data.write(to: fileURL, options: .atomic)
        return "Manuals/\(id.uuidString)/manual.pdf"
    }

    func pdfURL(relativePath: String) -> URL {
        DocumentsDirectory.url.appendingPathComponent(relativePath)
    }

    private func dateStamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd-HHmmss"
        return f.string(from: Date())
    }
}
