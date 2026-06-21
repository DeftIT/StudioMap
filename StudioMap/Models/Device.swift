import SwiftUI

struct Device: Identifiable, Codable, Equatable {
    // MARK: - Identity
    var id: UUID = UUID()
    var nickname: String = ""
    var manufacturer: String = ""
    var productID: String = ""
    var category: DeviceCategory = .other
    // Free-text sub-type shown beneath the category (e.g. "Guitar", "Drum Pad", "iPhone 15")
    var customSubtype: String = ""
    var serialNumber: String = ""
    var location: String = ""
    var customColorHex: String? = nil

    // MARK: - Links
    var supportPageURL: String = ""
    var downloadsPageURL: String = ""
    var pdfManualPath: String = ""

    // MARK: - Analog I/O
    var analogInputCount: Int = 0
    var analogOutputCount: Int = 0

    // MARK: - Digital I/O
    var sampleRate: Int = 44100
    var adatInputPorts: Int = 0
    var adatOutputPorts: Int = 0
    var madiInputPorts: Int = 0
    var madiOutputPorts: Int = 0
    var midiInputPorts: Int = 0
    var midiOutputPorts: Int = 0
    var hasAESEBU: Bool = false
    var hasDante: Bool = false
    var hasMIDIoverUSB: Bool = false
    var hasSPDIF: Bool = false
    var hasWordClock: Bool = false

    // MARK: - Computer I/O
    var firewireCount: Int = 0
    var thunderboltCount: Int = 0
    var usbCount: Int = 0
    var usbCCount: Int = 0
    var ethernetCount: Int = 0

    // MARK: - Named Ports (optional, for port-to-port connection labelling)
    var customPorts: [Port] = []

    // MARK: - Asset Inventory
    var purchasePrice: Double? = nil
    var purchaseDate: Date? = nil
    var purchaseLocation: String = ""
    var warrantyExpires: Date? = nil
    var insurancePolicy: String = ""
    var currentValue: Double? = nil
    var notes: String = ""

    // MARK: - Canvas State (stored as Doubles since CGPoint/CGSize are not Codable)
    var positionX: Double = 0
    var positionY: Double = 0
    var width: Double = 160
    var height: Double = 72

    // MARK: - Computed
    var displayName: String {
        if !nickname.isEmpty { return nickname }
        let parts = [manufacturer, productID].filter { !$0.isEmpty }
        return parts.isEmpty ? "Unnamed Device" : parts.joined(separator: " ")
    }

    // Shows customSubtype if set, otherwise category name
    var categoryLabel: String {
        customSubtype.isEmpty ? category.rawValue : "\(category.rawValue) · \(customSubtype)"
    }

    var position: CGPoint {
        get { CGPoint(x: positionX, y: positionY) }
        set { positionX = newValue.x; positionY = newValue.y }
    }

    var size: CGSize {
        get { CGSize(width: width, height: height) }
        set { width = newValue.width; height = newValue.height }
    }

    func resolvedColor() -> Color {
        if let hex = customColorHex, let color = Color(hex: hex) { return color }
        return category.defaultColor
    }
}
