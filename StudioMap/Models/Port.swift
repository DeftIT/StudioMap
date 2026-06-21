import Foundation

// Connector/jack type for a physical port
enum ConnectorType: String, Codable, CaseIterable, Identifiable {
    case xlr          = "XLR"
    case quarterInch  = "1/4\" (TRS/TS)"
    case miniJack     = "3.5mm"
    case rca          = "RCA"
    case speakon      = "Speakon"
    case midi5pin     = "MIDI 5-pin DIN"
    case usb          = "USB-A"
    case usbC         = "USB-C"
    case thunderbolt  = "Thunderbolt"
    case firewire     = "FireWire"
    case adat         = "ADAT (Optical/TOSLINK)"
    case spdifCoax    = "S/PDIF (Coaxial RCA)"
    case spdifOptical = "S/PDIF (Optical)"
    case aesEbu       = "AES/EBU (XLR Digital)"
    case ethercon     = "EtherCON / Ethernet"
    case bluetooth    = "Bluetooth"
    case wordClock    = "Word Clock (BNC)"
    case other        = "Other"

    var id: String { rawValue }

    // Which connection type this connector typically carries
    var defaultConnectionType: ConnectionType {
        switch self {
        case .xlr, .quarterInch, .miniJack, .rca, .speakon:
            return .analog
        case .midi5pin:
            return .midi
        case .usb, .usbC, .thunderbolt, .firewire, .ethercon:
            return .computer
        case .bluetooth:
            return .bluetoothMidi
        case .adat, .spdifCoax, .spdifOptical, .aesEbu, .wordClock:
            return .digital
        case .other:
            return .analog
        }
    }
}

enum PortDirection: String, Codable, CaseIterable, Identifiable {
    case input  = "Input"
    case output = "Output"
    case bidirectional = "In/Out"

    var id: String { rawValue }
}

struct Port: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String           // e.g. "Kick In", "Main Out L", "Expression"
    var connectorType: ConnectorType
    var direction: PortDirection
    var signalType: ConnectionType

    // Optional: group label for multi-port sets (e.g. "Analog In", "ADAT")
    var group: String = ""
}
