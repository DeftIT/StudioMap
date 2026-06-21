import SwiftUI

struct ConnectionMatrixView: View {
    let studio: Studio
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    private let cellSize: CGFloat = 46
    private let labelWidth: CGFloat = 110
    private let headerHeight: CGFloat = 80

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomLeading) {
                ScrollView([.horizontal, .vertical]) {
                    VStack(spacing: 0) {
                        // Column header row
                        HStack(spacing: 0) {
                            // Corner cell
                            Text("From \\ To")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                                .frame(width: labelWidth, height: headerHeight)
                                .background(Color(white: 0.12))

                            ForEach(studio.devices) { device in
                                VStack(spacing: 4) {
                                    Circle()
                                        .fill(device.resolvedColor())
                                        .frame(width: 8, height: 8)
                                    Text(device.displayName)
                                        .font(.system(size: 9, weight: .medium))
                                        .lineLimit(3)
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(.white)
                                }
                                .frame(width: cellSize, height: headerHeight)
                                .padding(.top, 4)
                                .background(Color(white: 0.15))
                                .border(Color(white: 0.25), width: 0.5)
                            }
                        }

                        // Data rows
                        ForEach(studio.devices) { rowDevice in
                            HStack(spacing: 0) {
                                // Row label
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(rowDevice.resolvedColor())
                                        .frame(width: 6, height: 6)
                                    Text(rowDevice.displayName)
                                        .font(.system(size: 9, weight: .medium))
                                        .lineLimit(2)
                                        .foregroundStyle(.white)
                                }
                                .frame(width: labelWidth, height: cellSize, alignment: .leading)
                                .padding(.horizontal, 6)
                                .background(Color(white: 0.14))
                                .border(Color(white: 0.25), width: 0.5)

                                // Cells
                                ForEach(studio.devices) { colDevice in
                                    matrixCell(from: rowDevice, to: colDevice)
                                }
                            }
                        }
                    }
                }
                .background(Color(white: 0.1))

                // Legend at bottom
                legendBar
            }
            .navigationTitle("Connection Matrix")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func matrixCell(from: Device, to: Device) -> some View {
        let outgoing = studio.connections.filter {
            $0.fromDeviceId == from.id && $0.toDeviceId == to.id
        }
        let incoming = studio.connections.filter {
            $0.fromDeviceId == to.id && $0.toDeviceId == from.id
        }
        let isSelf = from.id == to.id
        let totalCount = outgoing.count + incoming.count

        ZStack {
            if isSelf {
                Color(white: 0.08)
                    .frame(width: cellSize, height: cellSize)
            } else if totalCount == 0 {
                Color(white: 0.16)
                    .frame(width: cellSize, height: cellSize)
            } else if outgoing.count > 0 && incoming.count > 0 {
                // Bidirectional: split cell diagonally
                let primary = outgoing.first!.connectionType.color
                let secondary = incoming.first!.connectionType.color
                ZStack {
                    primary.frame(width: cellSize, height: cellSize)
                    Triangle()
                        .fill(secondary)
                        .frame(width: cellSize, height: cellSize)
                }
                .frame(width: cellSize, height: cellSize)
            } else {
                let conn = (outgoing + incoming).first!
                conn.connectionType.color.opacity(0.75)
                    .frame(width: cellSize, height: cellSize)
            }

            // Count badge
            if totalCount > 1 {
                Text("\(totalCount)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: cellSize, height: cellSize)
        .border(Color(white: 0.25), width: 0.5)
        .contentShape(Rectangle())
        .onTapGesture {
            guard !isSelf else { return }
            if let conn = outgoing.first ?? incoming.first {
                appState.activeSheet = .editConnection(conn)
            } else {
                appState.activeSheet = .addConnection(fromDeviceId: from.id, toDeviceId: to.id)
            }
        }
    }

    private var legendBar: some View {
        HStack(spacing: 16) {
            ForEach(ConnectionType.allCases) { type in
                HStack(spacing: 4) {
                    Circle().fill(type.color).frame(width: 10, height: 10)
                    Text(type.rawValue).font(.caption2).foregroundStyle(.white)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(12)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
