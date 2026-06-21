import SwiftUI

struct CanvasContainerView: View {
    let studio: Studio
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var canvasVM: CanvasViewModel
    @State private var showUndoArrange = false
    @State private var preArrangeDevices: [Device] = []

    private let canvasBg = Color(red: 0.07, green: 0.07, blue: 0.09)

    var body: some View {
        ZStack(alignment: .top) {
            canvasBg.ignoresSafeArea()

            // Main canvas
            CanvasView(studio: studio)
                .environmentObject(canvasVM)

            // Floating toolbar at top
            CanvasToolbarView(studio: studio)
                .environmentObject(canvasVM)
                .padding(.horizontal, 16)
                .padding(.top, 12)

            // Auto-arrange + undo button at bottom-right
            VStack {
                Spacer()
                HStack {
                    if showUndoArrange {
                        Button(action: undoArrange) {
                            Label("Undo Arrange", systemImage: "arrow.uturn.backward")
                                .font(.subheadline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color(white: 0.2), in: Capsule())
                                .foregroundStyle(.white)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Button(action: autoArrange) {
                        Label("Auto Arrange", systemImage: "arrow.up.arrow.down.square.fill")
                            .font(.subheadline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.accentColor, in: Capsule())
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .animation(.spring(response: 0.3), value: showUndoArrange)
            }
        }
        .onAppear {
            let saved = appState.savedViewport(forStudio: studio.id)
            canvasVM.restoreViewport(saved)
        }
        .onDisappear {
            appState.saveViewport(canvasVM.viewport, forStudio: studio.id)
        }
    }

    private func autoArrange() {
        guard let studioId = appState.selectedStudioId else { return }
        preArrangeDevices = studio.devices
        let arranged = AutoArrangeEngine.arrange(devices: studio.devices, connections: studio.connections)
        for device in arranged {
            appState.updateDevice(device, inStudioId: studioId)
        }
        showUndoArrange = true
        // Hide undo button after 8 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            withAnimation { showUndoArrange = false }
        }
    }

    private func undoArrange() {
        guard let studioId = appState.selectedStudioId else { return }
        for device in preArrangeDevices {
            appState.updateDevice(device, inStudioId: studioId)
        }
        withAnimation { showUndoArrange = false }
    }
}
