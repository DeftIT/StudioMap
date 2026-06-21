import SwiftUI

struct CanvasView: View {
    let studio: Studio
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var canvasVM: CanvasViewModel

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                // Layer 1: Connection lines (below everything)
                ConnectionLinesView(studio: studio, canvasVM: canvasVM, containerSize: size)

                // Layer 2: In-progress connection creation overlay
                if canvasVM.isCreatingConnection {
                    ConnectionCreationOverlay(studio: studio, canvasVM: canvasVM, containerSize: size)
                }

                // Layer 3: Device cards
                ForEach(studio.devices) { device in
                    DeviceCardView(device: device)
                        .position(canvasVM.toScreenSpace(device.position, containerSize: size))
                        .gesture(deviceDragGesture(device: device, containerSize: size))
                        .onTapGesture {
                            handleDeviceTap(device: device, containerSize: size)
                        }
                        .onLongPressGesture(minimumDuration: 0.4) {
                            handleDeviceLongPress(device: device)
                        }
                }

                // Empty state
                if studio.devices.isEmpty {
                    emptyState
                }
            }
            .frame(width: size.width, height: size.height)
            .contentShape(Rectangle())
            .gesture(canvasPanGesture())
            .simultaneousGesture(canvasPinchGesture())
            .onTapGesture {
                if canvasVM.isCreatingConnection {
                    canvasVM.cancelConnectionCreation()
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "plus.circle.dashed")
                .font(.system(size: 60))
                .foregroundStyle(Color(white: 0.35))
            Text("No devices yet")
                .font(.title2)
                .foregroundStyle(Color(white: 0.45))
            Text("Tap \"Add Device\" to start building your studio diagram")
                .font(.body)
                .foregroundStyle(Color(white: 0.35))
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }

    // MARK: - Gestures

    private func canvasPanGesture() -> some Gesture {
        DragGesture(minimumDistance: 5, coordinateSpace: .local)
            .onChanged { v in
                guard !canvasVM.isCreatingConnection, canvasVM.draggingDeviceId == nil else { return }
                canvasVM.onDragChanged(translation: v.translation)
            }
            .onEnded { _ in canvasVM.onDragEnded() }
    }

    private func canvasPinchGesture() -> some Gesture {
        MagnifyGesture()
            .onChanged { v in canvasVM.onMagnifyChanged(value: v.magnification) }
            .onEnded { _ in canvasVM.onMagnifyEnded() }
    }

    private func deviceDragGesture(device: Device, containerSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 3, coordinateSpace: .local)
            .onChanged { value in
                guard !canvasVM.isCreatingConnection else { return }
                canvasVM.draggingDeviceId = device.id
                var updated = device
                updated.position = canvasVM.toCanvasSpace(value.location, containerSize: containerSize)
                appState.updateDevice(updated, inStudioId: studio.id)
            }
            .onEnded { _ in
                canvasVM.draggingDeviceId = nil
            }
    }

    // MARK: - Tap Handlers

    private func handleDeviceTap(device: Device, containerSize: CGSize) {
        if canvasVM.isCreatingConnection {
            if let result = canvasVM.completeConnectionCreation(toDeviceId: device.id) {
                // Avoid duplicate connections
                let duplicate = studio.connections.contains {
                    ($0.fromDeviceId == result.from && $0.toDeviceId == result.to) ||
                    ($0.fromDeviceId == result.to && $0.toDeviceId == result.from)
                }
                if !duplicate {
                    appState.activeSheet = .addConnection(fromDeviceId: result.from, toDeviceId: result.to)
                }
            }
        } else {
            appState.activeSheet = .deviceDetail(device)
        }
    }

    private func handleDeviceLongPress(device: Device) {
        guard !canvasVM.isCreatingConnection else { return }
        canvasVM.beginConnectionCreation(fromDeviceId: device.id)
    }
}
