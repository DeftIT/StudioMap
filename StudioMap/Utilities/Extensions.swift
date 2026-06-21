import SwiftUI

// MARK: - Color Hex Support

extension Color {
    init?(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "#", with: "")
        guard cleaned.count == 6, let value = UInt64(cleaned, radix: 16) else { return nil }
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8)  & 0xFF) / 255.0
        let b = Double(value         & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

// MARK: - Add Studio Sheet

struct AddStudioSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var name = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Studio Name", text: $name)
                }
            }
            .navigationTitle("New Studio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        appState.addStudio(name: name.trimmingCharacters(in: .whitespaces))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.fraction(0.3)])
    }
}

// MARK: - Rename Studio Alert Helper

struct RenameStudioAlert: ViewModifier {
    @Binding var isPresented: Bool
    let studio: Studio?
    let onRename: (String) -> Void

    @State private var name = ""

    func body(content: Content) -> some View {
        content.alert("Rename Studio", isPresented: $isPresented, presenting: studio) { s in
            TextField("Studio name", text: $name)
            Button("Rename") { if !name.isEmpty { onRename(name) } }
            Button("Cancel", role: .cancel) {}
        } message: { s in
            Text("Enter a new name for \"\(s.name)\"")
        }
        .onChange(of: studio?.id) { _, _ in name = studio?.name ?? "" }
    }
}

extension View {
    func renameStudioAlert(isPresented: Binding<Bool>, studio: Studio?, onRename: @escaping (String) -> Void) -> some View {
        modifier(RenameStudioAlert(isPresented: isPresented, studio: studio, onRename: onRename))
    }
}
