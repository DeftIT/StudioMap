import SwiftUI

struct PortEditorView: View {
    @Binding var ports: [Port]
    @State private var showAddPort = false
    @State private var editingPort: Port? = nil

    var body: some View {
        List {
            ForEach(groupedPorts.keys.sorted(), id: \.self) { group in
                Section(group.isEmpty ? "Ports" : group) {
                    ForEach(groupedPorts[group] ?? []) { port in
                        portRow(port)
                            .onTapGesture { editingPort = port }
                    }
                }
            }
        }
        .navigationTitle("Named Ports")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Port") { showAddPort = true }
            }
        }
        .sheet(isPresented: $showAddPort) {
            PortEditSheet(port: nil) { newPort in
                ports.append(newPort)
            }
        }
        .sheet(item: $editingPort) { port in
            PortEditSheet(port: port) { updated in
                if let idx = ports.firstIndex(where: { $0.id == updated.id }) {
                    ports[idx] = updated
                }
            } onDelete: {
                ports.removeAll { $0.id == port.id }
            }
        }
    }

    private var groupedPorts: [String: [Port]] {
        Dictionary(grouping: ports, by: { $0.group })
    }

    private func portRow(_ port: Port) -> some View {
        HStack(spacing: 10) {
            Image(systemName: directionIcon(port.direction))
                .foregroundStyle(port.signalType.color)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(port.name).font(.body)
                Text(port.connectorType.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(port.direction.rawValue)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(white: 0.2), in: Capsule())
        }
    }

    private func directionIcon(_ dir: PortDirection) -> String {
        switch dir {
        case .input:         return "arrow.down.circle.fill"
        case .output:        return "arrow.up.circle.fill"
        case .bidirectional: return "arrow.up.arrow.down.circle.fill"
        }
    }
}

struct PortEditSheet: View {
    let existingPort: Port?
    let onSave: (Port) -> Void
    let onDelete: (() -> Void)?

    @State private var port: Port
    @Environment(\.dismiss) var dismiss

    init(port: Port?, onSave: @escaping (Port) -> Void, onDelete: (() -> Void)? = nil) {
        self.existingPort = port
        self.onSave = onSave
        self.onDelete = onDelete
        _port = State(initialValue: port ?? Port(
            name: "",
            connectorType: .quarterInch,
            direction: .input,
            signalType: .analog
        ))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Port Details") {
                    TextField("Name (e.g. Kick In, Expression, Main Out L)", text: $port.name)
                    TextField("Group (optional, e.g. Analog In)", text: $port.group)

                    Picker("Connector Type", selection: $port.connectorType) {
                        ForEach(ConnectorType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }

                    Picker("Direction", selection: $port.direction) {
                        ForEach(PortDirection.allCases) { dir in
                            Text(dir.rawValue).tag(dir)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker("Signal Type", selection: $port.signalType) {
                        ForEach(ConnectionType.allCases) { type in
                            Label(type.rawValue, systemImage: signalIcon(type)).tag(type)
                        }
                    }
                }

                if let onDelete = onDelete {
                    Section {
                        Button("Delete Port", role: .destructive) {
                            onDelete()
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(existingPort == nil ? "Add Port" : "Edit Port")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Auto-fill signal type from connector if still default
                        if port.signalType == .analog {
                            port.signalType = port.connectorType.defaultConnectionType
                        }
                        onSave(port)
                        dismiss()
                    }
                    .disabled(port.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onChange(of: port.connectorType) { _, newType in
                port.signalType = newType.defaultConnectionType
            }
        }
        .presentationDetents([.medium])
    }

    private func signalIcon(_ type: ConnectionType) -> String {
        switch type {
        case .analog:        return "waveform"
        case .digital:       return "wave.3.right"
        case .midi:          return "pianokeys"
        case .computer:      return "laptopcomputer"
        case .bluetoothMidi: return "bluetooth"
        }
    }
}
