import SwiftUI

struct CanvasToolbarView: View {
    let studio: Studio
    @Binding var viewMode: ViewMode
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var canvasVM: CanvasViewModel
    @AppStorage("preferredViewMode") private var preferredViewMode: String = ViewMode.canvas.rawValue

    var body: some View {
        HStack(spacing: 12) {
            // Studio name pill
            Text(studio.name)
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))

            Spacer()

            // Left group: view mode + paths
            HStack(spacing: 0) {
                viewModeButton
                Divider().frame(height: 20).opacity(0.4)
                toolbarButton("Paths", icon: "arrow.triangle.branch") {
                    appState.activeSheet = .signalPaths
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))

            // Right group: canvas tools
            HStack(spacing: 0) {
                toolbarButton("Matrix", icon: "tablecells") {
                    appState.activeSheet = .connectionMatrix
                }
                Divider().frame(height: 20).opacity(0.4)
                toolbarButton("Legend", icon: "info.circle") {
                    appState.activeSheet = .connectionLegend
                }
                Divider().frame(height: 20).opacity(0.4)
                toolbarButton("Reset", icon: "arrow.up.left.and.down.right.magnifyingglass") {
                    canvasVM.resetViewport()
                }
                Divider().frame(height: 20).opacity(0.4)
                addDeviceMenu
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - View Mode Button

    private var viewModeButton: some View {
        Button(action: cycleViewMode) {
            HStack(spacing: 5) {
                Image(systemName: viewMode.icon)
                Text(viewMode.rawValue)
                    .font(.subheadline)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Section("Switch View") {
                ForEach(ViewMode.allCases) { mode in
                    Button(action: { viewMode = mode }) {
                        Label(mode.rawValue, systemImage: mode.icon)
                    }
                }
            }
            Divider()
            Button(action: { preferredViewMode = viewMode.rawValue }) {
                Label("Set '\(viewMode.rawValue)' as Default", systemImage: "star")
            }
        }
    }

    // MARK: - Add Device Menu

    private var addDeviceMenu: some View {
        Menu {
            Button(action: { appState.activeSheet = .addDevice }) {
                Label("Add Device", systemImage: "plus.circle")
            }
            Button(action: { appState.activeSheet = .addAUv3 }) {
                Label("Add AUv3 Plugin", systemImage: "puzzlepiece.extension")
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "plus.circle.fill")
                Text("Add")
                    .font(.subheadline)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func cycleViewMode() {
        let all = ViewMode.allCases
        let idx = all.firstIndex(of: viewMode) ?? 0
        viewMode = all[(idx + 1) % all.count]
    }

    private func toolbarButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                Text(title)
                    .font(.subheadline)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}
