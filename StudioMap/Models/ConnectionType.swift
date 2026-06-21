import SwiftUI

enum ConnectionType: String, Codable, CaseIterable, Identifiable {
    case analog         = "Analog"
    case digital        = "Digital"
    case midi           = "MIDI"
    case computer       = "Computer"
    case bluetoothMidi  = "Bluetooth MIDI"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .analog:          return Color(red: 0.25, green: 0.55, blue: 1.0)
        case .digital:         return Color(red: 0.2,  green: 0.85, blue: 0.4)
        case .midi:            return Color(red: 0.75, green: 0.35, blue: 1.0)
        case .computer:        return Color(red: 1.0,  green: 0.55, blue: 0.1)
        case .bluetoothMidi:   return Color(red: 0.2,  green: 0.8,  blue: 0.8)
        }
    }

    var isBidirectional: Bool { self == .computer || self == .bluetoothMidi }

    var legendDescription: String {
        switch self {
        case .analog:        return "Analog I/O, XLR, TRS, 3.5mm, headphone outputs"
        case .digital:       return "ADAT, MADI, S/PDIF, AES/EBU, Word Clock"
        case .midi:          return "MIDI 5-pin DIN in/out connections"
        case .computer:      return "USB, Thunderbolt, Ethernet (two-way)"
        case .bluetoothMidi: return "Bluetooth MIDI (wireless, two-way)"
        }
    }
}
