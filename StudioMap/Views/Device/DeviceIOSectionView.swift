import SwiftUI

struct DeviceIOSectionView: View {
    @Binding var device: Device

    var body: some View {
        Group {
            Section("Analog I/O") {
                Stepper("Inputs: \(device.analogInputCount)", value: $device.analogInputCount, in: 0...256)
                Stepper("Outputs: \(device.analogOutputCount)", value: $device.analogOutputCount, in: 0...256)
            }

            Section("Digital I/O") {
                Picker("Sample Rate", selection: $device.sampleRate) {
                    ForEach([44100, 48000, 88200, 96000, 176400, 192000], id: \.self) {
                        Text("\($0 / 1000).\(($0 % 1000) / 100) kHz").tag($0)
                    }
                }
                Stepper("ADAT In: \(device.adatInputPorts)",   value: $device.adatInputPorts,   in: 0...16)
                Stepper("ADAT Out: \(device.adatOutputPorts)", value: $device.adatOutputPorts,  in: 0...16)
                Stepper("MADI In: \(device.madiInputPorts)",   value: $device.madiInputPorts,   in: 0...4)
                Stepper("MADI Out: \(device.madiOutputPorts)", value: $device.madiOutputPorts,  in: 0...4)
                Stepper("MIDI In: \(device.midiInputPorts)",   value: $device.midiInputPorts,   in: 0...16)
                Stepper("MIDI Out: \(device.midiOutputPorts)", value: $device.midiOutputPorts,  in: 0...16)
                Toggle("AES/EBU",       isOn: $device.hasAESEBU)
                Toggle("Dante",         isOn: $device.hasDante)
                Toggle("MIDI over USB", isOn: $device.hasMIDIoverUSB)
                Toggle("S/PDIF",        isOn: $device.hasSPDIF)
                Toggle("Word Clock",    isOn: $device.hasWordClock)
            }

            Section("Computer I/O") {
                Stepper("USB-A: \(device.usbCount)",             value: $device.usbCount,         in: 0...32)
                Stepper("USB-C: \(device.usbCCount)",            value: $device.usbCCount,         in: 0...32)
                Stepper("Thunderbolt: \(device.thunderboltCount)", value: $device.thunderboltCount, in: 0...8)
                Stepper("FireWire: \(device.firewireCount)",     value: $device.firewireCount,     in: 0...4)
                Stepper("Ethernet: \(device.ethernetCount)",     value: $device.ethernetCount,     in: 0...8)
            }

            Section {
                NavigationLink("Manage Named Ports (\(device.customPorts.count))") {
                    PortEditorView(ports: $device.customPorts)
                }
            } header: {
                Text("Named Ports")
            } footer: {
                Text("Add individual ports with jack types for detailed port-to-port connections (e.g. \"Kick In\" → 1/4\" jack, \"Expression\" → 3.5mm).")
            }
        }
    }
}
