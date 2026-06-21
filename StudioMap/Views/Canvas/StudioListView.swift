import SwiftUI

struct StudioListView: View {
    let studio: Studio
    @EnvironmentObject var appState: AppState

    var body: some View {
        List {
            Section("Devices (\(studio.devices.count))") {
                if studio.devices.isEmpty {
                    Text("No devices yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(studio.devices) { device in
                        Button(action: { appState.activeSheet = .deviceDetail(device) }) {
                            HStack(spacing: 12) {
                                Image(systemName: device.category.symbolName)
                                    .foregroundStyle(device.resolvedColor())
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(device.displayName)
                                        .foregroundStyle(.primary)
                                    Text(device.categoryLabel)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Section("Connections (\(studio.connections.count))") {
                if studio.connections.isEmpty {
                    Text("No connections yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(studio.connections) { conn in
                        Button(action: { appState.activeSheet = .editConnection(conn) }) {
                            connectionRow(conn)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if !studio.signalPaths.isEmpty {
                Section("Signal Paths (\(studio.signalPaths.count))") {
                    ForEach(studio.signalPaths) { path in
                        Button(action: {
                            appState.activeSheet = .signalPaths
                        }) {
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(Color(hex: path.colorHex) ?? .orange)
                                    .frame(width: 12, height: 12)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(path.name.isEmpty ? "Unnamed Path" : path.name)
                                        .foregroundStyle(.primary)
                                    Text("\(path.connectionIds.count) connection\(path.connectionIds.count == 1 ? "" : "s")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(red: 0.07, green: 0.07, blue: 0.09))
    }

    private func connectionRow(_ conn: Connection) -> some View {
        let from = studio.devices.first { $0.id == conn.fromDeviceId }?.displayName ?? "?"
        let to   = studio.devices.first { $0.id == conn.toDeviceId }?.displayName   ?? "?"
        let arrow = conn.connectionType.isBidirectional ? "↔" : "→"

        return HStack(spacing: 10) {
            Circle()
                .fill(conn.connectionType.color)
                .frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(from) \(arrow) \(to)")
                    .foregroundStyle(.primary)
                HStack(spacing: 8) {
                    Text(conn.connectionType.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if !conn.channelMap.isEmpty {
                        Text("·")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(conn.channelMap)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
