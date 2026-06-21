import SwiftUI

struct DeviceCardView: View {
    let device: Device
    @EnvironmentObject var canvasVM: CanvasViewModel

    private let cornerRadius: CGFloat = 10

    var body: some View {
        let scale = canvasVM.viewport.scale
        let cardW = device.width * scale
        let cardH = device.height * scale
        let isSource = canvasVM.connectionSourceDeviceId == device.id
        let isDragging = canvasVM.draggingDeviceId == device.id

        ZStack(alignment: .leading) {
            // Card background
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color(white: 0.18))

            // Left color accent bar
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(device.resolvedColor())
                .frame(width: max(5 * scale, 4))
                .clipShape(
                    .rect(
                        topLeadingRadius: cornerRadius,
                        bottomLeadingRadius: cornerRadius,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 0
                    )
                )

            // Content
            HStack(alignment: .center, spacing: 6 * scale) {
                Spacer().frame(width: max(5 * scale, 4))

                Image(systemName: device.category.symbolName)
                    .font(.system(size: max(14 * scale, 10)))
                    .foregroundStyle(device.resolvedColor())
                    .frame(width: 20 * scale, height: 20 * scale)

                VStack(alignment: .leading, spacing: 1) {
                    Text(device.displayName)
                        .font(.system(size: max(12 * scale, 8), weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(device.categoryLabel)
                        .font(.system(size: max(9 * scale, 6)))
                        .foregroundStyle(Color(white: 0.55))
                        .lineLimit(1)
                }

                Spacer(minLength: 4)
            }
            .padding(.vertical, 6 * scale)
        }
        .frame(width: cardW, height: cardH)
        .shadow(color: .black.opacity(0.5), radius: 6 * scale, y: 2 * scale)
        // Highlight when this card is the connection source
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(isSource ? device.resolvedColor() : (isDragging ? Color.white.opacity(0.4) : Color.clear),
                        lineWidth: isSource ? 2.5 : 1.5)
        )
        // Pulse animation when selected as connection source
        .scaleEffect(isSource ? 1.04 : 1.0)
        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isSource)
    }
}
