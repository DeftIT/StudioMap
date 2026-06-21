import SwiftUI

struct TreeView: View {
    let studio: Studio
    @EnvironmentObject var appState: AppState

    private let nodeW: CGFloat = 150
    private let nodeH: CGFloat = 64
    private let padding: CGFloat = 40

    private var arrangedDevices: [Device] {
        guard !studio.devices.isEmpty else { return [] }
        return AutoArrangeEngine.arrange(devices: studio.devices, connections: studio.connections)
    }

    private func positions(for arranged: [Device]) -> [UUID: CGPoint] {
        guard !arranged.isEmpty else { return [:] }
        let minX = arranged.map { $0.positionX }.min() ?? 0
        let minY = arranged.map { $0.positionY }.min() ?? 0
        var result: [UUID: CGPoint] = [:]
        for d in arranged {
            result[d.id] = CGPoint(
                x: CGFloat(d.positionX - minX) + padding,
                y: CGFloat(d.positionY - minY) + padding
            )
        }
        return result
    }

    var body: some View {
        let arranged = arrangedDevices
        let pos = positions(for: arranged)

        let maxX = pos.values.map { $0.x }.max() ?? 0
        let maxY = pos.values.map { $0.y }.max() ?? 0
        let canvasW = max(maxX + nodeW + padding, 400)
        let canvasH = max(maxY + nodeH + padding, 300)

        if studio.devices.isEmpty {
            ContentUnavailableView(
                "No Devices",
                systemImage: "list.bullet.indent",
                description: Text("Add devices to see the signal flow tree.")
            )
            .background(Color(red: 0.07, green: 0.07, blue: 0.09))
        } else {
            ScrollView([.horizontal, .vertical]) {
                ZStack {
                    // Edge drawing layer
                    Canvas { ctx, _ in
                        for conn in studio.connections {
                            guard let fromPt = pos[conn.fromDeviceId],
                                  let toPt = pos[conn.toDeviceId]
                            else { continue }

                            let fromBottom = CGPoint(x: fromPt.x + nodeW / 2, y: fromPt.y + nodeH)
                            let toTop      = CGPoint(x: toPt.x + nodeW / 2,   y: toPt.y)
                            let midY       = (fromBottom.y + toTop.y) / 2

                            var path = Path()
                            path.move(to: fromBottom)
                            path.addLine(to: CGPoint(x: fromBottom.x, y: midY))
                            path.addLine(to: CGPoint(x: toTop.x, y: midY))
                            path.addLine(to: toTop)

                            let color = conn.connectionType.color.opacity(0.8)
                            let dash: [CGFloat] = conn.connectionType == .bluetoothMidi ? [8, 5] : []
                            ctx.stroke(path, with: .color(color),
                                       style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: dash))

                            // Arrowhead pointing into destination node
                            let arrowTip = toTop
                            let arrowSize: CGFloat = 6
                            let angle: CGFloat = .pi / 2
                            let a1 = angle + .pi * 0.75
                            let a2 = angle - .pi * 0.75
                            var arrow = Path()
                            arrow.move(to: arrowTip)
                            arrow.addLine(to: CGPoint(x: arrowTip.x + arrowSize * cos(a1),
                                                      y: arrowTip.y + arrowSize * sin(a1)))
                            arrow.addLine(to: CGPoint(x: arrowTip.x + arrowSize * cos(a2),
                                                      y: arrowTip.y + arrowSize * sin(a2)))
                            arrow.closeSubpath()
                            ctx.fill(arrow, with: .color(color))
                        }
                    }
                    .frame(width: canvasW, height: canvasH)

                    // Node cards
                    ForEach(arranged) { device in
                        if let pt = pos[device.id] {
                            TreeNodeView(device: device)
                                .frame(width: nodeW, height: nodeH)
                                .position(x: pt.x + nodeW / 2, y: pt.y + nodeH / 2)
                                .onTapGesture {
                                    appState.activeSheet = .deviceDetail(device)
                                }
                        }
                    }
                }
                .frame(width: canvasW, height: canvasH)
            }
            .background(Color(red: 0.07, green: 0.07, blue: 0.09))
        }
    }
}

private struct TreeNodeView: View {
    let device: Device

    var body: some View {
        HStack(spacing: 0) {
            device.resolvedColor()
                .frame(width: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            HStack(spacing: 8) {
                Image(systemName: device.category.symbolName)
                    .font(.system(size: 16))
                    .foregroundStyle(device.resolvedColor())
                    .frame(width: 22)

                VStack(alignment: .leading, spacing: 2) {
                    Text(device.displayName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    Text(device.categoryLabel)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 8)

            Spacer(minLength: 0)
        }
        .background(Color(white: 0.18))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(white: 0.3), lineWidth: 0.5))
    }
}
