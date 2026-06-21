import SwiftUI

struct ConnectionLinesView: View {
    let studio: Studio
    let canvasVM: CanvasViewModel
    let containerSize: CGSize
    var highlightedPathId: UUID? = nil

    private var highlightedConnectionIds: Set<UUID> {
        guard let pathId = highlightedPathId,
              let path = studio.signalPaths.first(where: { $0.id == pathId })
        else { return [] }
        return Set(path.connectionIds)
    }

    var body: some View {
        Canvas { ctx, _ in
            let highlighted = highlightedConnectionIds
            for connection in studio.connections {
                guard
                    let fromDevice = studio.devices.first(where: { $0.id == connection.fromDeviceId }),
                    let toDevice   = studio.devices.first(where: { $0.id == connection.toDeviceId })
                else { continue }

                let fromCanvas = ConnectionRouter.anchorPoint(
                    forDevice: fromDevice,
                    towardPoint: toDevice.position
                )
                let toCanvas = ConnectionRouter.anchorPoint(
                    forDevice: toDevice,
                    towardPoint: fromDevice.position
                )

                let fromPt = canvasVM.toScreenSpace(fromCanvas, containerSize: containerSize)
                let toPt   = canvasVM.toScreenSpace(toCanvas,   containerSize: containerSize)
                let isHighlighted = highlighted.contains(connection.id)

                drawConnection(ctx: ctx, from: fromPt, to: toPt,
                               connection: connection, isHighlighted: isHighlighted)
            }
        }
        .allowsHitTesting(false)
    }

    private func drawConnection(
        ctx: GraphicsContext,
        from: CGPoint,
        to: CGPoint,
        connection: Connection,
        isHighlighted: Bool
    ) {
        let scale = canvasVM.viewport.scale
        let thickness = connection.lineThickness * scale
        let color = connection.connectionType.color.opacity(0.9)
        let isBluetooth = connection.connectionType == .bluetoothMidi
        let dash: [CGFloat] = isBluetooth ? [max(8 * scale, 4), max(5 * scale, 3)] : []

        // Cubic bezier path
        let dx = to.x - from.x
        let controlOffset = max(abs(dx) * 0.45, 50 * scale)
        var path = Path()
        path.move(to: from)
        path.addCurve(
            to: to,
            control1: CGPoint(x: from.x + controlOffset, y: from.y),
            control2: CGPoint(x: to.x - controlOffset, y: to.y)
        )

        // Glow underneath for highlighted signal paths
        if isHighlighted {
            ctx.stroke(path, with: .color(.white.opacity(0.35)),
                       style: StrokeStyle(lineWidth: thickness + 8 * scale, lineCap: .round))
        }

        ctx.stroke(path, with: .color(color),
                   style: StrokeStyle(lineWidth: thickness, lineCap: .round, dash: dash))

        // Arrowhead(s)
        let arrowSize = max(8 * scale, 5)
        if connection.connectionType.isBidirectional {
            drawArrowhead(ctx: ctx, tip: from, base: to, color: color, size: arrowSize)
            drawArrowhead(ctx: ctx, tip: to, base: from, color: color, size: arrowSize)
        } else {
            drawArrowhead(ctx: ctx, tip: to, base: from, color: color, size: arrowSize)
        }

        // Port labels near endpoints
        if !connection.fromPortLabel.isEmpty || !connection.toPortLabel.isEmpty {
            drawPortLabel(ctx: ctx, text: connection.fromPortLabel, near: from, toward: to, scale: scale)
            drawPortLabel(ctx: ctx, text: connection.toPortLabel, near: to, toward: from, scale: scale)
        }

        // Connection label at midpoint
        let mid = CGPoint(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2)
        if !connection.label.isEmpty {
            let labelY = mid.y - 14 * scale
            ctx.draw(
                Text(connection.label)
                    .font(.system(size: max(10 * scale, 7)))
                    .foregroundColor(.white.opacity(0.85)),
                at: CGPoint(x: mid.x, y: labelY)
            )
        }

        // Channel map label below main label
        if !connection.channelMap.isEmpty {
            let mapOffset: CGFloat = connection.label.isEmpty ? -12 * scale : -2 * scale
            ctx.draw(
                Text(connection.channelMap)
                    .font(.system(size: max(9 * scale, 6)))
                    .foregroundColor(Color(red: 0.7, green: 0.85, blue: 1.0).opacity(0.8)),
                at: CGPoint(x: mid.x, y: mid.y + mapOffset)
            )
        }
    }

    private func drawArrowhead(ctx: GraphicsContext, tip: CGPoint, base: CGPoint, color: Color, size: CGFloat) {
        let angle = atan2(tip.y - base.y, tip.x - base.x)
        let a1 = angle + .pi * 0.75
        let a2 = angle - .pi * 0.75
        var path = Path()
        path.move(to: tip)
        path.addLine(to: CGPoint(x: tip.x + size * cos(a1), y: tip.y + size * sin(a1)))
        path.addLine(to: CGPoint(x: tip.x + size * cos(a2), y: tip.y + size * sin(a2)))
        path.closeSubpath()
        ctx.fill(path, with: .color(color))
    }

    private func drawPortLabel(ctx: GraphicsContext, text: String, near: CGPoint, toward: CGPoint, scale: CGFloat) {
        guard !text.isEmpty else { return }
        let t = 0.15
        let pt = CGPoint(
            x: near.x + (toward.x - near.x) * t,
            y: near.y + (toward.y - near.y) * t - 10 * scale
        )
        ctx.draw(
            Text(text)
                .font(.system(size: max(9 * scale, 6)))
                .foregroundColor(Color(white: 0.7)),
            at: pt
        )
    }
}
