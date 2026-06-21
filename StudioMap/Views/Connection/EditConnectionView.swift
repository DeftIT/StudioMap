import SwiftUI

struct EditConnectionView: View {
    let studio: Studio
    let isNew: Bool

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var draft: Connection

    // MARK: - Init for new connection
    init(fromDeviceId: UUID, toDeviceId: UUID, studio: Studio) {
        self.studio = studio
        self.isNew = true
        _draft = State(initialValue: Connection(fromDeviceId: fromDeviceId, toDeviceId: toDeviceId))
    }

    // MARK: - Init for editing existing
    init(connection: Connection, studio: Studio) {
        self.studio = studio
        self.isNew = false
        _draft = State(initialValue: connection)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Devices") {
                    devicePicker("From", selection: $draft.fromDeviceId)
                    devicePicker("To", selection: $draft.toDeviceId)
                }

                Section("Connection Type") {
                    ForEach(ConnectionType.allCases) { type in
                        Button(action: { draft.connectionType = type }) {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(type.color)
                                    .frame(width: 14, height: 14)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(type.rawValue)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    Text(type.legendDescription)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if draft.connectionType == type {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.accentColor)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section("Channels") {
                    Stepper("Channel Count: \(draft.channelCount)", value: $draft.channelCount, in: 1...512)
                    HStack {
                        Image(systemName: "line.diagonal")
                            .foregroundStyle(.secondary)
                        Text(draft.thicknessLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    TextField("Channel Routing", text: $draft.channelMap,
                              prompt: Text("e.g. Out 3+4 → In 1+2"))
                } footer: {
                    Text("Optionally document which physical channels this cable uses.")
                }

                // Port-to-port section
                portSection

                Section("Label & Notes") {
                    TextField("Label (shown on diagram)", text: $draft.label)
                    TextField("Notes", text: $draft.notes, axis: .vertical)
                        .lineLimit(3...)
                }

                if !isNew {
                    Section {
                        Button("Delete Connection", role: .destructive) {
                            appState.deleteConnection(id: draft.id, fromStudioId: studio.id)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(isNew ? "New Connection" : "Edit Connection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(draft.fromDeviceId == draft.toDeviceId)
                }
            }
        }
    }

    // MARK: - Port-to-Port Section

    @ViewBuilder
    private var portSection: some View {
        let fromDevice = studio.devices.first(where: { $0.id == draft.fromDeviceId })
        let toDevice   = studio.devices.first(where: { $0.id == draft.toDeviceId })

        let fromPorts = fromDevice?.customPorts.filter {
            $0.direction == .output || $0.direction == .bidirectional
        } ?? []
        let toPorts = toDevice?.customPorts.filter {
            $0.direction == .input || $0.direction == .bidirectional
        } ?? []

        Section("Port Details (Optional)") {
            if !fromPorts.isEmpty {
                Picker("From Port", selection: $draft.fromPortId) {
                    Text("Any / Not Specified").tag(Optional<UUID>.none)
                    ForEach(fromPorts) { port in
                        Text("\(port.name) (\(port.connectorType.rawValue))").tag(Optional(port.id))
                    }
                }
            }
            TextField("From Port Label", text: $draft.fromPortLabel,
                      prompt: Text("e.g. 3.5mm jack, Out 1"))

            if !toPorts.isEmpty {
                Picker("To Port", selection: $draft.toPortId) {
                    Text("Any / Not Specified").tag(Optional<UUID>.none)
                    ForEach(toPorts) { port in
                        Text("\(port.name) (\(port.connectorType.rawValue))").tag(Optional(port.id))
                    }
                }
            }
            TextField("To Port Label", text: $draft.toPortLabel,
                      prompt: Text("e.g. 1/4\" input, Exp pedal jack"))
        } footer: {
            Text("Optionally specify which physical ports this cable connects. Useful for complex rigs or multi-channel devices.")
        }
    }

    // MARK: - Helpers

    private func devicePicker(_ label: String, selection: Binding<UUID>) -> some View {
        Picker(label, selection: selection) {
            ForEach(studio.devices) { device in
                Text(device.displayName).tag(device.id)
            }
        }
    }

    private func save() {
        if isNew {
            appState.addConnection(draft, toStudioId: studio.id)
        } else {
            appState.updateConnection(draft, inStudioId: studio.id)
        }
        dismiss()
    }
}
