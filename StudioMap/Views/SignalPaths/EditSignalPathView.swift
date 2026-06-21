import SwiftUI

struct EditSignalPathView: View {
    let studio: Studio
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var draft: SignalPath
    @State private var selectedColor: Color
    private let isNew: Bool

    init(path: SignalPath, studio: Studio) {
        self.studio = studio
        self.isNew = path.name.isEmpty && path.connectionIds.isEmpty
        _draft = State(initialValue: path)
        _selectedColor = State(initialValue: Color(hex: path.colorHex) ?? .orange)
    }

    var body: some View {
        Form {
            Section("Name") {
                TextField("e.g. Guitar → Monitor, DAW Return (3+4)", text: $draft.name)
                TextField("Description", text: $draft.description, axis: .vertical)
                    .lineLimit(2...)
            }

            Section("Highlight Color") {
                ColorPicker("Color", selection: $selectedColor, supportsOpacity: false)
            }

            Section {
                if studio.connections.isEmpty {
                    Text("No connections in this studio yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(studio.connections) { conn in
                        connectionToggleRow(conn)
                    }
                }
            } header: {
                Text("Connections in this path")
            } footer: {
                Text("Select the connections that form this signal route. Highlighted connections will glow on the canvas.")
            }

            if !isNew {
                Section {
                    Button("Delete Path", role: .destructive) {
                        appState.deleteSignalPath(id: draft.id, fromStudioId: studio.id)
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle(isNew ? "New Signal Path" : "Edit Signal Path")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(draft.name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func connectionToggleRow(_ conn: Connection) -> some View {
        let isSelected = draft.connectionIds.contains(conn.id)
        let from = studio.devices.first { $0.id == conn.fromDeviceId }?.displayName ?? "?"
        let to   = studio.devices.first { $0.id == conn.toDeviceId }?.displayName   ?? "?"

        return Button(action: {
            if isSelected {
                draft.connectionIds.removeAll { $0 == conn.id }
            } else {
                draft.connectionIds.append(conn.id)
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                    .font(.system(size: 18))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(conn.connectionType.color)
                            .frame(width: 8, height: 8)
                        Text("\(from) → \(to)")
                            .font(.body)
                            .foregroundStyle(.primary)
                    }
                    if !conn.channelMap.isEmpty {
                        Text(conn.channelMap)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if !conn.label.isEmpty {
                        Text(conn.label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func save() {
        draft.colorHex = selectedColor.toHex() ?? "#FF6600"
        if isNew {
            appState.addSignalPath(draft, toStudioId: studio.id)
        } else {
            appState.updateSignalPath(draft, inStudioId: studio.id)
        }
        dismiss()
    }
}
