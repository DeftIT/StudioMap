import CoreGraphics

struct Connection: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var fromDeviceId: UUID
    var toDeviceId: UUID
    var connectionType: ConnectionType = .analog
    var channelCount: Int = 2
    var label: String = ""
    var notes: String = ""

    // Optional port-to-port specification
    var fromPortId: UUID? = nil   // references Port.id in fromDevice.customPorts
    var toPortId: UUID? = nil     // references Port.id in toDevice.customPorts
    var fromPortLabel: String = "" // free-text fallback (e.g. "3.5mm jack", "Out 1")
    var toPortLabel: String = ""   // free-text fallback (e.g. "1/4\" input")
    var channelMap: String = ""    // e.g. "Out 3+4 → In 1+2", "USB Ch 1+2 only"

    var lineThickness: CGFloat {
        switch channelCount {
        case 1...2:  return 2.0
        case 3...8:  return 4.0
        default:     return 7.0
        }
    }

    var thicknessLabel: String {
        switch channelCount {
        case 1...2:  return "Thin (1–2 channels)"
        case 3...8:  return "Medium (3–8 channels)"
        default:     return "Thick (9+ channels)"
        }
    }
}
