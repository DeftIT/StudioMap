import SwiftUI

enum ViewMode: String, CaseIterable, Identifiable {
    case canvas = "Canvas"
    case tree   = "Tree"
    case mixer  = "Mixer"
    case list   = "List"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .canvas: return "square.grid.2x2"
        case .tree:   return "list.bullet.indent"
        case .mixer:  return "slider.horizontal.3"
        case .list:   return "list.dash"
        }
    }
}

struct CanvasContainerView: View {
    let studio: Studio
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var canvasVM: CanvasViewModel
    @AppStorage("preferredViewMode") private var preferredViewMode: String = ViewMode.canvas.rawValue
    @State private var viewMode: ViewMode = .canvas
    @State private var showUndoArrange = false
    @State private var preArrangeDevices: [Device] = []

    private let canvasBg = Color(red: 0.07, green: 0.07, blue: 0.09)

    var body: some View {
        ZStack(alignment: .top) {
            canvasBg.ignoresSafeArea()

            // Main content — switches based on view mode
            switch viewMode {
            case .canvas:
                CanvasView(studio: studio)
                    .environmentObject(canvasVM)
            case .tree:
                TreeView(studio: studio)
                    .environmentObject(appState)
            case .mixer:
                MixerView(studio: studio)
                    .environmentObject(appState)
            case .list:
                StudioListView(studio: studio)
                    .environmentObject(appState)
            }

            // Floating toolbar at top (all modes)
            CanvasToolbarView(studio: studio, viewMode: $viewMode)
                .environmentObject(appState)
                .environmentObject(canvasVM)
                .padding(.horizontal, 16)
                .padding(.top, 12)

            // Auto-arrange + undo (canvas mode only)
            if viewMode == .canvas {
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
        }
        .onAppear {
            viewMode = ViewMode(rawValue: preferredViewMode) ?? .canvas
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
