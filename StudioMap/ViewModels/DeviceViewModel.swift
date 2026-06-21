import Foundation

@MainActor
final class DeviceViewModel: ObservableObject {
    @Published var device: Device
    let isNew: Bool

    init(device: Device? = nil) {
        if let existing = device {
            self.device = existing
            self.isNew = false
        } else {
            self.device = Device()
            self.isNew = true
        }
    }

    // Pre-fill from a template (e.g. AUv3 picker) but treat as a new device
    init(template: Device) {
        self.device = template
        self.isNew = true
    }
}
