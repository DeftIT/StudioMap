import CoreGraphics

struct CanvasViewport: Equatable {
    var offset: CGSize = .zero
    var scale: Double = 1.0

    static let `default` = CanvasViewport()
    static let minScale: Double = 0.15
    static let maxScale: Double = 3.0
}
