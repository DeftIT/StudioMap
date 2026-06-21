import SwiftUI

@MainActor
final class CanvasViewModel: ObservableObject {
    // MARK: - Viewport
    @Published var viewport: CanvasViewport = .default
    private var baseOffset: CGSize = .zero
    private var baseScale: Double = 1.0

    // MARK: - Connection Creation
    @Published var isCreatingConnection: Bool = false
    @Published var connectionSourceDeviceId: UUID? = nil
    @Published var connectionDragPoint: CGPoint? = nil

    // MARK: - Device Drag
    @Published var draggingDeviceId: UUID? = nil

    // MARK: - Viewport Gestures

    func onMagnifyChanged(value: CGFloat) {
        let newScale = (baseScale * value).clamped(to: CanvasViewport.minScale...CanvasViewport.maxScale)
        viewport.scale = newScale
    }

    func onMagnifyEnded() {
        baseScale = viewport.scale
    }

    func onDragChanged(translation: CGSize) {
        viewport.offset = CGSize(
            width: baseOffset.width + translation.width,
            height: baseOffset.height + translation.height
        )
    }

    func onDragEnded() {
        baseOffset = viewport.offset
    }

    func resetViewport() {
        viewport = .default
        baseOffset = .zero
        baseScale = 1.0
    }

    func restoreViewport(_ saved: CanvasViewport) {
        viewport = saved
        baseOffset = saved.offset
        baseScale = saved.scale
    }

    // MARK: - Coordinate Transforms

    func toScreenSpace(_ canvasPoint: CGPoint, containerSize: CGSize) -> CGPoint {
        let cx = containerSize.width / 2
        let cy = containerSize.height / 2
        return CGPoint(
            x: canvasPoint.x * viewport.scale + cx + viewport.offset.width,
            y: canvasPoint.y * viewport.scale + cy + viewport.offset.height
        )
    }

    func toCanvasSpace(_ screenPoint: CGPoint, containerSize: CGSize) -> CGPoint {
        let cx = containerSize.width / 2
        let cy = containerSize.height / 2
        return CGPoint(
            x: (screenPoint.x - cx - viewport.offset.width) / viewport.scale,
            y: (screenPoint.y - cy - viewport.offset.height) / viewport.scale
        )
    }

    // MARK: - Connection Creation State Machine

    func beginConnectionCreation(fromDeviceId id: UUID) {
        connectionSourceDeviceId = id
        isCreatingConnection = true
        connectionDragPoint = nil
    }

    func updateConnectionDrag(to point: CGPoint) {
        connectionDragPoint = point
    }

    func cancelConnectionCreation() {
        isCreatingConnection = false
        connectionSourceDeviceId = nil
        connectionDragPoint = nil
    }

    func completeConnectionCreation(toDeviceId: UUID) -> (from: UUID, to: UUID)? {
        guard let from = connectionSourceDeviceId, from != toDeviceId else {
            cancelConnectionCreation()
            return nil
        }
        let result = (from: from, to: toDeviceId)
        cancelConnectionCreation()
        return result
    }

    // MARK: - Hit Testing

    func device(at screenPoint: CGPoint, in devices: [Device], containerSize: CGSize) -> Device? {
        let canvasPoint = toCanvasSpace(screenPoint, containerSize: containerSize)
        return devices.first { device in
            let hw = device.width / 2
            let hh = device.height / 2
            return abs(canvasPoint.x - device.positionX) < hw &&
                   abs(canvasPoint.y - device.positionY) < hh
        }
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
