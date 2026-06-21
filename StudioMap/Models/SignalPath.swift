import Foundation

struct SignalPath: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String = ""
    var description: String = ""
    var connectionIds: [UUID] = []
    var colorHex: String = "#FF6600"
}
