import CoreGraphics

struct ConnectionRouter {
    /// Returns the point on the edge of a device card closest to `target`, in canvas coordinates.
    static func anchorPoint(forDevice device: Device, towardPoint target: CGPoint) -> CGPoint {
        let center = device.position
        let hw = device.width / 2
        let hh = device.height / 2

        let dx = target.x - center.x
        let dy = target.y - center.y

        guard dx != 0 || dy != 0 else { return center }

        // Find intersection with card rectangle edges
        let scaleX = hw / abs(dx == 0 ? 1e-6 : dx)
        let scaleY = hh / abs(dy == 0 ? 1e-6 : dy)
        let scale  = min(scaleX, scaleY)

        return CGPoint(
            x: center.x + dx * scale,
            y: center.y + dy * scale
        )
    }
}
