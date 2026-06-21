import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var studios: [Studio] = []
    @Published var selectedStudioId: UUID? = nil
    @Published var activeSheet: ActiveSheet? = nil
    @Published var exportURL: URL? = nil
    @Published var highlightedPathId: UUID? = nil

    init() {
        PersistenceManager.shared.ensureDirectories()
        studios = PersistenceManager.shared.loadStudios()
        selectedStudioId = studios.first?.id
    }

    // MARK: - Convenience

    var selectedStudio: Studio? {
        studios.first { $0.id == selectedStudioId }
    }

    // MARK: - Studio CRUD

    func addStudio(name: String) {
        let s = Studio(name: name)
        studios.append(s)
        selectedStudioId = s.id
        save()
    }

    func deleteStudio(id: UUID) {
        studios.removeAll { $0.id == id }
        if selectedStudioId == id { selectedStudioId = studios.first?.id }
        save()
    }

    func renameStudio(id: UUID, newName: String) {
        guard let idx = studioIndex(id) else { return }
        studios[idx].name = newName
        save()
    }

    // MARK: - Device CRUD

    func addDevice(_ device: Device, toStudioId sid: UUID) {
        guard let idx = studioIndex(sid) else { return }
        studios[idx].devices.append(device)
        save()
    }

    func updateDevice(_ device: Device, inStudioId sid: UUID) {
        guard let si = studioIndex(sid),
              let di = studios[si].devices.firstIndex(where: { $0.id == device.id })
        else { return }
        studios[si].devices[di] = device
        save()
    }

    func deleteDevice(id: UUID, fromStudioId sid: UUID) {
        guard let si = studioIndex(sid) else { return }
        studios[si].devices.removeAll { $0.id == id }
        studios[si].connections.removeAll { $0.fromDeviceId == id || $0.toDeviceId == id }
        save()
    }

    func cloneDevice(id: UUID, inStudioId sid: UUID) {
        guard let si = studioIndex(sid),
              var clone = studios[si].devices.first(where: { $0.id == id })
        else { return }
        clone.id = UUID()
        clone.nickname = clone.nickname.isEmpty ? clone.displayName + " (Copy)" : clone.nickname + " (Copy)"
        clone.positionX += 30
        clone.positionY += 30
        studios[si].devices.append(clone)
        save()
    }

    func moveDevice(id: UUID, fromStudio: UUID, toStudio: UUID) {
        guard let fromIdx = studioIndex(fromStudio),
              let toIdx = studioIndex(toStudio),
              let devIdx = studios[fromIdx].devices.firstIndex(where: { $0.id == id })
        else { return }
        let device = studios[fromIdx].devices.remove(at: devIdx)
        studios[toIdx].devices.append(device)
        studios[fromIdx].connections.removeAll { $0.fromDeviceId == id || $0.toDeviceId == id }
        save()
    }

    // MARK: - Connection CRUD

    func addConnection(_ connection: Connection, toStudioId sid: UUID) {
        guard let idx = studioIndex(sid) else { return }
        studios[idx].connections.append(connection)
        save()
    }

    func updateConnection(_ connection: Connection, inStudioId sid: UUID) {
        guard let si = studioIndex(sid),
              let ci = studios[si].connections.firstIndex(where: { $0.id == connection.id })
        else { return }
        studios[si].connections[ci] = connection
        save()
    }

    func deleteConnection(id: UUID, fromStudioId sid: UUID) {
        guard let si = studioIndex(sid) else { return }
        studios[si].connections.removeAll { $0.id == id }
        for pi in studios[si].signalPaths.indices {
            studios[si].signalPaths[pi].connectionIds.removeAll { $0 == id }
        }
        save()
    }

    // MARK: - Signal Path CRUD

    func addSignalPath(_ path: SignalPath, toStudioId sid: UUID) {
        guard let idx = studioIndex(sid) else { return }
        studios[idx].signalPaths.append(path)
        save()
    }

    func updateSignalPath(_ path: SignalPath, inStudioId sid: UUID) {
        guard let si = studioIndex(sid),
              let pi = studios[si].signalPaths.firstIndex(where: { $0.id == path.id })
        else { return }
        studios[si].signalPaths[pi] = path
        save()
    }

    func deleteSignalPath(id: UUID, fromStudioId sid: UUID) {
        guard let si = studioIndex(sid) else { return }
        studios[si].signalPaths.removeAll { $0.id == id }
        if highlightedPathId == id { highlightedPathId = nil }
        save()
    }

    // MARK: - Viewport Persistence

    func saveViewport(_ viewport: CanvasViewport, forStudio sid: UUID) {
        guard let idx = studioIndex(sid) else { return }
        studios[idx].viewportOffsetX = viewport.offset.width
        studios[idx].viewportOffsetY = viewport.offset.height
        studios[idx].viewportScale = viewport.scale
        save()
    }

    func savedViewport(forStudio sid: UUID) -> CanvasViewport {
        guard let s = studios.first(where: { $0.id == sid }) else { return .default }
        return CanvasViewport(
            offset: CGSize(width: s.viewportOffsetX, height: s.viewportOffsetY),
            scale: s.viewportScale
        )
    }

    // MARK: - Export / Import

    func exportJSON() {
        exportURL = PersistenceManager.shared.exportURL(for: studios)
    }

    func importJSON(from url: URL) {
        guard let imported = PersistenceManager.shared.importStudios(from: url) else { return }
        studios = imported
        selectedStudioId = studios.first?.id
        save()
    }

    // MARK: - Private

    private func studioIndex(_ id: UUID) -> Int? {
        studios.firstIndex(where: { $0.id == id })
    }

    private func save() {
        PersistenceManager.shared.saveStudios(studios)
    }
}

// MARK: - ActiveSheet

enum ActiveSheet: Identifiable {
    case addDevice
    case editDevice(Device)
    case deviceDetail(Device)
    case addConnection(fromDeviceId: UUID, toDeviceId: UUID)
    case editConnection(Connection)
    case connectionLegend
    case addStudio
    case connectionMatrix
    case signalPaths
    case editSignalPath(SignalPath)
    case addAUv3

    var id: String {
        switch self {
        case .addDevice:                           return "addDevice"
        case .editDevice(let d):                   return "editDevice-\(d.id)"
        case .deviceDetail(let d):                 return "deviceDetail-\(d.id)"
        case .addConnection(let f, let t):         return "addConn-\(f)-\(t)"
        case .editConnection(let c):               return "editConn-\(c.id)"
        case .connectionLegend:                    return "legend"
        case .addStudio:                           return "addStudio"
        case .connectionMatrix:                    return "matrix"
        case .signalPaths:                         return "signalPaths"
        case .editSignalPath(let p):               return "editSignalPath-\(p.id)"
        case .addAUv3:                             return "addAUv3"
        }
    }
}
