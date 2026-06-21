import SwiftUI

struct DeviceInventorySectionView: View {
    @Binding var device: Device

    var body: some View {
        Group {
            Section("Financial") {
                HStack {
                    Text("Purchase Price")
                    Spacer()
                    TextField("0.00", value: $device.purchasePrice, format: .currency(code: "USD"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .frame(width: 120)
                }
                HStack {
                    Text("Current Value")
                    Spacer()
                    TextField("0.00", value: $device.currentValue, format: .currency(code: "USD"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .frame(width: 120)
                }
                TextField("Purchase Location", text: $device.purchaseLocation)
            }

            Section("Dates") {
                OptionalDatePicker("Purchase Date", date: $device.purchaseDate)
                OptionalDatePicker("Warranty Expires", date: $device.warrantyExpires)
            }

            Section("Insurance & Notes") {
                TextField("Insurance Policy #", text: $device.insurancePolicy)
                TextField("Notes", text: $device.notes, axis: .vertical)
                    .lineLimit(4...)
            }
        }
    }
}

// DatePicker that shows/hides based on whether the optional date is set
private struct OptionalDatePicker: View {
    let label: String
    @Binding var date: Date?

    var body: some View {
        if let binding = Binding($date) {
            HStack {
                DatePicker(label, selection: binding, displayedComponents: .date)
                Button(role: .destructive) { date = nil } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        } else {
            Button("Set \(label)") { date = Date() }
                .foregroundStyle(.accentColor)
        }
    }
}
