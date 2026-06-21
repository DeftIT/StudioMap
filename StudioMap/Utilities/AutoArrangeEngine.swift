import Foundation

struct AutoArrangeEngine {
    static let tierHeight: Double = 180
    static let nodeSpacingX: Double = 210
    static let canvasOriginY: Double = -350

    static func arrange(devices: [Device], connections: [Connection]) -> [Device] {
        guard !devices.isEmpty else { return [] }

        var inDegree: [UUID: Int] = [:]
        var neighbors: [UUID: [UUID]] = [:]
        for d in devices {
            inDegree[d.id] = 0
            neighbors[d.id] = []
        }
        for conn in connections {
            guard neighbors[conn.fromDeviceId] != nil,
                  inDegree[conn.toDeviceId] != nil else { continue }
            neighbors[conn.fromDeviceId]!.append(conn.toDeviceId)
            inDegree[conn.toDeviceId]! += 1
        }

        // Assign tier as longest path from any source via BFS
        var tier: [UUID: Int] = [:]
        for device in devices {
            // Fall back to category tier for disconnected devices
            tier[device.id] = device.category.signalTier
        }

        var queue: [UUID] = devices
            .filter { inDegree[$0.id] == 0 }
            .map { $0.id }

        var visited = Set<UUID>()
        var bfsQueue = queue

        while !bfsQueue.isEmpty {
            let current = bfsQueue.removeFirst()
            guard !visited.contains(current) else { continue }
            visited.insert(current)
            let currentTier = tier[current] ?? 0
            for neighbor in neighbors[current, default: []] {
                let newTier = currentTier + 1
                if newTier > (tier[neighbor] ?? 0) {
                    tier[neighbor] = newTier
                }
                inDegree[neighbor, default: 1] -= 1
                if inDegree[neighbor, default: 0] <= 0 {
                    bfsQueue.append(neighbor)
                }
            }
        }

        // Group by tier
        var tierGroups: [Int: [Device]] = [:]
        for device in devices {
            let t = tier[device.id] ?? device.category.signalTier
            tierGroups[t, default: []].append(device)
        }

        // Position within each tier
        var updated: [Device] = []
        for (tierIndex, devicesInTier) in tierGroups.sorted(by: { $0.key < $1.key }) {
            let y = canvasOriginY + Double(tierIndex) * tierHeight
            let totalWidth = Double(devicesInTier.count - 1) * nodeSpacingX
            let startX = -totalWidth / 2
            for (i, device) in devicesInTier.enumerated() {
                var d = device
                d.positionX = startX + Double(i) * nodeSpacingX
                d.positionY = y
                updated.append(d)
            }
        }
        return updated
    }
}
