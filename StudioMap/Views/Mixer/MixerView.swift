import SwiftUI

struct MixerView: View {
    let studio: Studio
    @EnvironmentObject var appState: AppState

    private let tierNames: [Int: String] = [
        0: "Sources",
        1: "Instruments / Inputs",
        2: "Interfaces",
        3: "Mixing",
        4: "Processing",
        5: "Monitoring Amps",
        6: "Outputs"
    ]

    private var tiers: [(tier: Int, devices: [Device])] {
        var groups: [Int: [Device]] = [:]
        for device in studio.devices {
            let t = device.category.signalTier
            groups[t, default: []].append(device)
        }
        return groups.sorted { $0.key < $1.key }.map { (tier: $0.key, devices: $0.value) }
    }

    var body: some View {
        if studio.devices.isEmpty {
            ContentUnavailableView(
                "No Devices",
                systemImage: "slider.horizontal.3",
                description: Text("Add devices to see the mixer view.")
            )
            .background(Color(red: 0.07, green: 0.07, blue: 0.09))
        } else {
            ScrollView([.horizontal, .vertical]) {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                    ForEach(tiers, id: \.tier) { row in
                        Section {
                            HStack(alignment: .top, spacing: 1) {
                                ForEach(row.devices) { device in
                                    MixerStripView(device: device, studio: studio)
                                        .frame(width: 130)
                                }
                            }
                        } header: {
                            Text(tierNames[row.tier] ?? "Tier \(row.tier)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.95))
                        }

                        Divider()
                            .background(Color(white: 0.2))
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color(red: 0.07, green: 0.07, blue: 0.09))
        }
    }
}

private struct MixerStripView: View {
    let device: Device
    let studio: Studio
    @EnvironmentObject var appState: AppState

    private var connections: [Connection] {
        studio.connections.filter { $0.fromDeviceId == device.id || $0.toDeviceId == device.id }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Color accent bar
            device.resolvedColor()
                .frame(height: 8)

            VStack(alignment: .center, spacing: 8) {
                // Category icon
                Image(systemName: device.category.symbolName)
                    .font(.system(size: 26))
                    .foregroundStyle(device.resolvedColor())
                    .frame(height: 34)
                    .padding(.top, 10)

                // Device name
                Text(device.displayName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 6)
                    .frame(maxWidth: .infinity)

                // Category label
                Text(device.categoryLabel)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .padding(.horizontal, 4)

                Divider()
                    .background(Color(white: 0.28))
                    .padding(.horizontal, 8)

                // Connection badges
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(connections) { conn in
                        connectionBadge(conn)
                    }
                    if connections.isEmpty {
                        Text("No connections")
                            .font(.system(size: 9))
                            .foregroundStyle(Color(white: 0.4))
                            .padding(.horizontal, 8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.bottom, 10)
            }
        }
        .background(Color(white: 0.14))
        .overlay(
            Rectangle()
                .frame(width: 0.5)
                .foregroundStyle(Color(white: 0.25)),
            alignment: .trailing
        )
        .contentShape(Rectangle())
        .onTapGesture {
            appState.activeSheet = .deviceDetail(device)
        }
    }

    private func connectionBadge(_ conn: Connection) -> some View {
        let isFrom = conn.fromDeviceId == device.id
        let otherId = isFrom ? conn.toDeviceId : conn.fromDeviceId
        let otherName = studio.devices.first { $0.id == otherId }?.displayName ?? "?"
        let arrow = isFrom ? "→" : "←"

        return Button(action: { appState.activeSheet = .editConnection(conn) }) {
            HStack(spacing: 4) {
                Circle()
                    .fill(conn.connectionType.color)
                    .frame(width: 7, height: 7)
                Text("\(arrow) \(otherName)")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}
