import SwiftUI

struct EditDeviceView: View {
    @ObservedObject var viewModel: DeviceViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            Form {
                Picker("Section", selection: $selectedTab) {
                    Text("Basics").tag(0)
                    Text("I/O").tag(1)
                    Text("Inventory").tag(2)
                }
                .pickerStyle(.segmented)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))

                switch selectedTab {
                case 0:  basicsSection
                case 1:  DeviceIOSectionView(device: $viewModel.device)
                case 2:  DeviceInventorySectionView(device: $viewModel.device)
                default: EmptyView()
                }
            }
            .navigationTitle(viewModel.isNew ? "Add Device" : "Edit Device")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(viewModel.device.displayName == "Unnamed Device" &&
                                  viewModel.device.nickname.isEmpty &&
                                  viewModel.device.manufacturer.isEmpty)
                }
            }
        }
    }

    @ViewBuilder
    private var basicsSection: some View {
        Section("Identity") {
            TextField("Nickname", text: $viewModel.device.nickname)
            TextField("Manufacturer", text: $viewModel.device.manufacturer)
            TextField("Model / Product ID", text: $viewModel.device.productID)

            Picker("Category", selection: $viewModel.device.category) {
                ForEach(DeviceCategory.allCases) { cat in
                    Label(cat.rawValue, systemImage: cat.symbolName).tag(cat)
                }
            }

            // Sub-type field shown for categories that benefit from free-text detail
            if subtypeCategories.contains(viewModel.device.category) {
                TextField(subtypePlaceholder, text: $viewModel.device.customSubtype)
            }

            TextField("Serial Number", text: $viewModel.device.serialNumber)
            TextField("Location in Studio", text: $viewModel.device.location)
        }

        Section("Display Color") {
            ColorPicker("Card Color", selection: Binding(
                get: {
                    if let hex = viewModel.device.customColorHex {
                        return Color(hex: hex) ?? viewModel.device.category.defaultColor
                    }
                    return viewModel.device.category.defaultColor
                },
                set: { viewModel.device.customColorHex = $0.toHex() }
            ), supportsOpacity: false)

            if viewModel.device.customColorHex != nil {
                Button("Reset to Category Default", role: .destructive) {
                    viewModel.device.customColorHex = nil
                }
            }
        }

        Section("Links") {
            TextField("Support Page URL", text: $viewModel.device.supportPageURL)
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            TextField("Downloads Page URL", text: $viewModel.device.downloadsPageURL)
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
    }

    // Categories where a custom sub-type text field is useful
    private var subtypeCategories: Set<DeviceCategory> {
        [.other, .instrument, .mobileDevice, .multi, .effectsUnit]
    }

    private var subtypePlaceholder: String {
        switch viewModel.device.category {
        case .instrument:    return "Type (e.g. Guitar, Drum Kit, Bass)"
        case .mobileDevice:  return "Device (e.g. iPhone 15, iPad Pro)"
        case .effectsUnit:   return "Type (e.g. Reverb, Delay, Looper)"
        case .multi:         return "Description (e.g. Drum Pad + Synth)"
        default:             return "Custom type (e.g. Drum Pad, Sequencer)"
        }
    }

    private func save() {
        guard let studioId = appState.selectedStudioId else { return }
        if viewModel.isNew {
            // Place new device slightly offset from canvas center
            var device = viewModel.device
            let offset = Double(appState.selectedStudio?.devices.count ?? 0) * 20.0
            device.positionX = offset
            device.positionY = offset
            appState.addDevice(device, toStudioId: studioId)
        } else {
            appState.updateDevice(viewModel.device, inStudioId: studioId)
        }
        dismiss()
    }
}
