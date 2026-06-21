import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var canvasVM = CanvasViewModel()

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            if let studio = appState.selectedStudio {
                CanvasContainerView(studio: studio)
                    .environmentObject(canvasVM)
                    .id(studio.id)
            } else {
                ContentUnavailableView(
                    "No Studio Selected",
                    systemImage: "waveform.path.ecg",
                    description: Text("Create a studio using the + button in the sidebar.")
                )
                .background(Color(red: 0.08, green: 0.08, blue: 0.1))
            }
        }
        .sheet(item: $appState.activeSheet) { sheet in
            sheetContent(for: sheet)
        }
    }

    @ViewBuilder
    private func sheetContent(for sheet: ActiveSheet) -> some View {
        switch sheet {
        case .addStudio:
            AddStudioSheet()
                .environmentObject(appState)

        case .connectionLegend:
            ConnectionLegendView()

        case .connectionMatrix:
            if let studio = appState.selectedStudio {
                ConnectionMatrixView(studio: studio)
                    .environmentObject(appState)
            }

        case .addDevice:
            EditDeviceView(viewModel: DeviceViewModel())
                .environmentObject(appState)

        case .editDevice(let device):
            EditDeviceView(viewModel: DeviceViewModel(device: device))
                .environmentObject(appState)

        case .deviceDetail(let device):
            DeviceDetailSheet(device: device)
                .environmentObject(appState)

        case .addConnection(let fromId, let toId):
            if let studio = appState.selectedStudio {
                EditConnectionView(fromDeviceId: fromId, toDeviceId: toId, studio: studio)
                    .environmentObject(appState)
            }

        case .editConnection(let conn):
            if let studio = appState.selectedStudio {
                EditConnectionView(connection: conn, studio: studio)
                    .environmentObject(appState)
            }

        case .signalPaths:
            if let studio = appState.selectedStudio {
                SignalPathsView(studio: studio)
                    .environmentObject(appState)
            }

        case .editSignalPath(let path):
            if let studio = appState.selectedStudio {
                EditSignalPathView(path: path, studio: studio)
                    .environmentObject(appState)
            }

        case .addAUv3:
            AUv3PickerView()
                .environmentObject(appState)
        }
    }
}
