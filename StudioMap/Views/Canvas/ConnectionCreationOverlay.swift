import SwiftUI

struct ConnectionCreationOverlay: View {
    let studio: Studio
    @ObservedObject var canvasVM: CanvasViewModel
    let containerSize: CGSize

    var body: some View {
        ZStack {
            // Transparent full-screen drag tracker
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            canvasVM.updateConnectionDrag(to: value.location)
                        }
                        .onEnded { value in
                            // If finger ends over a device, the card's tap will handle it.
                            // If not, cancel.
                            let hit = canvasVM.device(
                                at: value.location,
                                in: studio.devices,
                                containerSize: containerSize
                            )
                            if hit == nil || hit?.id == canvasVM.connectionSourceDeviceId {
                                canvasVM.cancelConnectionCreation()
                            }
                        }
                )

            // Dashed preview line
            if let sourceId = canvasVM.connectionSourceDeviceId,
               let sourceDevice = studio.devices.first(where: { $0.id == sourceId }),
               let dragPt = canvasVM.connectionDragPoint {

                Canvas { ctx, _ in
                    let from = canvasVM.toScreenSpace(sourceDevice.position, containerSize: containerSize)
                    var path = Path()
                    path.move(to: from)
                    path.addLine(to: dragPt)
                    ctx.stroke(
                        path,
                        with: .color(.white.opacity(0.6)),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [8, 5])
                    )
                }
                .allowsHitTesting(false)
            }

            // Cancel hint
            VStack {
                HStack {
                    Spacer()
                    Label("Tap a device to connect · Tap canvas to cancel", systemImage: "link")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        .padding()
                }
                Spacer()
            }
        }
    }
}
