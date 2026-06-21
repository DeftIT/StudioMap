import SwiftUI

struct CanvasToolbarView: View {
    let studio: Studio
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var canvasVM: CanvasViewModel

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

            // Action buttons
            HStack(spacing: 0) {
                toolbarButton("Matrix", icon: "tablecells") {
                    appState.activeSheet = .connectionMatrix
                }
                Divider().frame(height: 20).opacity(0.4)
                toolbarButton("Legend", icon: "info.circle") {
                    appState.activeSheet = .connectionLegend
                }
                Divider().frame(height: 20).opacity(0.4)
                toolbarButton("Reset View", icon: "arrow.up.left.and.down.right.magnifyingglass") {
                    canvasVM.resetViewport()
                }
                Divider().frame(height: 20).opacity(0.4)
                toolbarButton("Add Device", icon: "plus.circle.fill") {
                    appState.activeSheet = .addDevice
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
        }
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
