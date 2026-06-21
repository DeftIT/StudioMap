import Foundation

struct Studio: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var createdAt: Date = Date()
    var devices: [Device] = []
    var connections: [Connection] = []

    // Persisted viewport state
    var viewportOffsetX: Double = 0
    var viewportOffsetY: Double = 0
    var viewportScale: Double = 1.0
}
