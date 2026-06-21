import Foundation

enum DocumentsDirectory {
    static var url: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static var studiosFileURL: URL {
        url.appendingPathComponent("studios.json")
    }

    static var manualsDirectoryURL: URL {
        url.appendingPathComponent("Manuals", isDirectory: true)
    }

    static var exportDirectoryURL: URL {
        url.appendingPathComponent("Exports", isDirectory: true)
    }
}
