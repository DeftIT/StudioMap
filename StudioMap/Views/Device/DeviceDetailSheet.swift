import SwiftUI

struct DeviceDetailSheet: View {
    let device: Device
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Identity") {
                    infoRow("Nickname", value: device.nickname)
                    infoRow("Manufacturer", value: device.manufacturer)
                    if !device.productID.isEmpty { infoRow("Model", value: device.productID) }
                    infoRow("Category", value: device.categoryLabel)
                    if !device.serialNumber.isEmpty { infoRow("Serial #", value: device.serialNumber) }
                    if !device.location.isEmpty { infoRow("Location", value: device.location) }
                }

                if device.analogInputCount > 0 || device.analogOutputCount > 0 {
                    Section("Analog I/O") {
                        if device.analogInputCount > 0 {
                            infoRow("Inputs", value: "\(device.analogInputCount) channels")
                        }
                        if device.analogOutputCount > 0 {
                            infoRow("Outputs", value: "\(device.analogOutputCount) channels")
                        }
                    }
                }

                let hasDigital = device.adatInputPorts + device.adatOutputPorts +
                                 device.madiInputPorts + device.madiOutputPorts +
                                 device.midiInputPorts + device.midiOutputPorts > 0 ||
                                 device.hasAESEBU || device.hasSPDIF || device.hasWordClock ||
                                 device.hasDante || device.hasMIDIoverUSB
                if hasDigital {
                    Section("Digital & MIDI I/O") {
                        if device.adatInputPorts > 0  { infoRow("ADAT In",  value: "\(device.adatInputPorts) ports") }
                        if device.adatOutputPorts > 0 { infoRow("ADAT Out", value: "\(device.adatOutputPorts) ports") }
                        if device.madiInputPorts > 0  { infoRow("MADI In",  value: "\(device.madiInputPorts) ports") }
                        if device.madiOutputPorts > 0 { infoRow("MADI Out", value: "\(device.madiOutputPorts) ports") }
                        if device.midiInputPorts > 0  { infoRow("MIDI In",  value: "\(device.midiInputPorts) ports") }
                        if device.midiOutputPorts > 0 { infoRow("MIDI Out", value: "\(device.midiOutputPorts) ports") }
                        toggleRow("AES/EBU",       on: device.hasAESEBU)
                        toggleRow("S/PDIF",        on: device.hasSPDIF)
                        toggleRow("Word Clock",    on: device.hasWordClock)
                        toggleRow("Dante",         on: device.hasDante)
                        toggleRow("MIDI over USB", on: device.hasMIDIoverUSB)
                    }
                }

                let hasComputer = device.usbCount + device.usbCCount + device.thunderboltCount +
                                  device.firewireCount + device.ethernetCount > 0
                if hasComputer {
                    Section("Computer I/O") {
                        if device.usbCount > 0         { infoRow("USB-A",       value: "\(device.usbCount)") }
                        if device.usbCCount > 0        { infoRow("USB-C",        value: "\(device.usbCCount)") }
                        if device.thunderboltCount > 0 { infoRow("Thunderbolt",  value: "\(device.thunderboltCount)") }
                        if device.firewireCount > 0    { infoRow("FireWire",     value: "\(device.firewireCount)") }
                        if device.ethernetCount > 0    { infoRow("Ethernet",     value: "\(device.ethernetCount)") }
                    }
                }

                if !device.customPorts.isEmpty {
                    Section("Named Ports") {
                        ForEach(device.customPorts) { port in
                            HStack {
                                Image(systemName: portDirectionIcon(port.direction))
                                    .foregroundStyle(port.signalType.color)
                                    .frame(width: 20)
                                VStack(alignment: .leading) {
                                    Text(port.name).font(.body)
                                    Text(port.connectorType.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(port.direction.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                if !device.notes.isEmpty {
                    Section("Notes") {
                        Text(device.notes)
                            .foregroundStyle(.secondary)
                    }
                }

                // Connections this device is involved in
                let connections = appState.selectedStudio?.connections.filter {
                    $0.fromDeviceId == device.id || $0.toDeviceId == device.id
                } ?? []
                if !connections.isEmpty {
                    Section("Connections (\(connections.count))") {
                        ForEach(connections) { conn in
                            connectionRow(conn)
                        }
                    }
                }
            }
            .navigationTitle(device.displayName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    deviceMenu
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var deviceMenu: some View {
        Menu {
            Button { appState.activeSheet = .editDevice(device) } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button {
                guard let sid = appState.selectedStudioId else { return }
                appState.cloneDevice(id: device.id, inStudioId: sid)
                dismiss()
            } label: {
                Label("Clone", systemImage: "plus.square.on.square")
            }
            if appState.studios.count > 1 {
                Menu("Move to Studio") {
                    ForEach(appState.studios.filter { $0.id != appState.selectedStudioId }) { s in
                        Button(s.name) {
                            guard let sid = appState.selectedStudioId else { return }
                            appState.moveDevice(id: device.id, fromStudio: sid, toStudio: s.id)
                            dismiss()
                        }
                    }
                }
            }
            Divider()
            Button(role: .destructive) {
                guard let sid = appState.selectedStudioId else { return }
                appState.deleteDevice(id: device.id, fromStudioId: sid)
                dismiss()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }

    @ViewBuilder
    private func connectionRow(_ conn: Connection) -> some View {
        let studio = appState.selectedStudio
        let fromName = studio?.devices.first(where: { $0.id == conn.fromDeviceId })?.displayName ?? "Unknown"
        let toName   = studio?.devices.first(where: { $0.id == conn.toDeviceId })?.displayName   ?? "Unknown"

        HStack(spacing: 8) {
            Circle().fill(conn.connectionType.color).frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 2) {
                if conn.connectionType.isBidirectional {
                    Text("\(fromName) ↔ \(toName)")
                        .font(.subheadline)
                } else {
                    Text("\(fromName) → \(toName)")
                        .font(.subheadline)
                }
                if !conn.channelMap.isEmpty {
                    Text(conn.channelMap)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(conn.connectionType.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            appState.activeSheet = .editConnection(conn)
            dismiss()
        }
    }

    @ViewBuilder
    private func infoRow(_ label: String, value: String) -> some View {
        if !value.isEmpty {
            LabeledContent(label, value: value)
        }
    }

    @ViewBuilder
    private func toggleRow(_ label: String, on: Bool) -> some View {
        if on {
            Label(label, systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }

    private func portDirectionIcon(_ direction: PortDirection) -> String {
        switch direction {
        case .input:         return "arrow.down.circle"
        case .output:        return "arrow.up.circle"
        case .bidirectional: return "arrow.up.arrow.down.circle"
        }
    }
}
