import SwiftUI

struct SignalPathsView: View {
    let studio: Studio
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if studio.signalPaths.isEmpty {
                    ContentUnavailableView(
                        "No Signal Paths",
                        systemImage: "arrow.triangle.branch",
                        description: Text("Document the full route a signal takes through your setup — e.g. Guitar → SSL → DAW → Monitors.")
                    )
                } else {
                    List {
                        ForEach(studio.signalPaths) { path in
                            pathRow(path)
                        }
                        .onDelete { indexSet in
                            for idx in indexSet {
                                let path = studio.signalPaths[idx]
                                appState.deleteSignalPath(id: path.id, fromStudioId: studio.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Signal Paths")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination:
                        EditSignalPathView(path: SignalPath(), studio: studio)
                            .environmentObject(appState)
                    ) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func pathRow(_ path: SignalPath) -> some View {
        let isHighlighted = appState.highlightedPathId == path.id
        let chain = deviceChain(for: path)

        return NavigationLink(destination:
            EditSignalPathView(path: path, studio: studio)
                .environmentObject(appState)
        ) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(hex: path.colorHex) ?? .orange)
                    .frame(width: 14, height: 14)

                VStack(alignment: .leading, spacing: 3) {
                    Text(path.name.isEmpty ? "Unnamed Path" : path.name)
                        .font(.body)
                        .foregroundStyle(.primary)
                    if !chain.isEmpty {
                        Text(chain)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    Text("\(path.connectionIds.count) connection\(path.connectionIds.count == 1 ? "" : "s")")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                Button(action: {
                    withAnimation {
                        if isHighlighted {
                            appState.highlightedPathId = nil
                        } else {
                            appState.highlightedPathId = path.id
                            dismiss()
                        }
                    }
                }) {
                    Image(systemName: isHighlighted ? "eye.fill" : "eye")
                        .foregroundStyle(isHighlighted ? Color.accentColor : Color.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func deviceChain(for path: SignalPath) -> String {
        var seenIds: [UUID] = []
        for connId in path.connectionIds {
            guard let conn = studio.connections.first(where: { $0.id == connId }) else { continue }
            if !seenIds.contains(conn.fromDeviceId) { seenIds.append(conn.fromDeviceId) }
            if !seenIds.contains(conn.toDeviceId)   { seenIds.append(conn.toDeviceId) }
        }
        return seenIds.compactMap { id in
            studio.devices.first { $0.id == id }?.displayName
        }.joined(separator: " → ")
    }
}
