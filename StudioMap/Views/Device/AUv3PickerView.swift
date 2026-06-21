import SwiftUI
import AVFoundation
import AudioToolbox

struct AUv3PickerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var instruments: [AVAudioUnitComponent] = []
    @State private var effects: [AVAudioUnitComponent] = []
    @State private var selectedTab: PluginTab = .instrument
    @State private var searchText = ""
    @State private var isLoading = true

    enum PluginTab: String, CaseIterable, Identifiable {
        case instrument = "Instrument"
        case effect = "Effect"
        var id: String { rawValue }
    }

    private var displayed: [AVAudioUnitComponent] {
        let source = selectedTab == .instrument ? instruments : effects
        guard !searchText.isEmpty else { return source }
        let q = searchText.lowercased()
        return source.filter {
            $0.name.lowercased().contains(q) || $0.manufacturerName.lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Scanning for AUv3 plugins…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if displayed.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No AUv3 Plugins Found" : "No Results",
                        systemImage: "puzzlepiece.extension",
                        description: Text(searchText.isEmpty
                            ? "Install AUv3 apps like Loopy Pro, AUM, or Koala Sampler to see them here."
                            : "Try a different search term.")
                    )
                } else {
                    List(displayed, id: \.name) { component in
                        NavigationLink(destination:
                            EditDeviceView(viewModel: DeviceViewModel(template: draft(from: component)))
                                .environmentObject(appState)
                        ) {
                            pluginRow(component)
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search plugins")
                }
            }
            .navigationTitle("AUv3 Plugins")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .principal) {
                    Picker("Type", selection: $selectedTab) {
                        ForEach(PluginTab.allCases) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
            }
        }
        .task { loadComponents() }
    }

    private func pluginRow(_ component: AVAudioUnitComponent) -> some View {
        HStack(spacing: 12) {
            Image(systemName: selectedTab == .instrument ? "pianokeys" : "waveform")
                .font(.system(size: 22))
                .foregroundStyle(selectedTab == .instrument ? Color.orange : Color.blue)
                .frame(width: 36, height: 36)
                .background(Color(white: 0.2), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                Text(component.name)
                    .font(.body)
                    .foregroundStyle(.primary)
                Text(component.manufacturerName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(component.typeName)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }

    private func draft(from component: AVAudioUnitComponent) -> Device {
        let isMusicDevice = component.audioComponentDescription.componentType == kAudioUnitType_MusicDevice
        var device = Device()
        device.nickname = component.name
        device.manufacturer = component.manufacturerName
        device.category = isMusicDevice ? .softwareSynth : .auv3Plugin
        device.customSubtype = component.typeName
        return device
    }

    private func loadComponents() {
        DispatchQueue.global(qos: .userInitiated).async {
            let manager = AVAudioUnitComponentManager.shared()
            let all = manager.components(passingTest: { _, _ in true })

            let instTypes: [UInt32] = [kAudioUnitType_MusicDevice, kAudioUnitType_MIDIProcessor]
            let fxTypes:   [UInt32] = [kAudioUnitType_Effect, kAudioUnitType_MusicEffect]

            let inst = all.filter { instTypes.contains($0.audioComponentDescription.componentType) }
                          .sorted { $0.name < $1.name }
            let fx   = all.filter { fxTypes.contains($0.audioComponentDescription.componentType) }
                          .sorted { $0.name < $1.name }

            DispatchQueue.main.async {
                instruments = inst
                effects = fx
                isLoading = false
            }
        }
    }
}
