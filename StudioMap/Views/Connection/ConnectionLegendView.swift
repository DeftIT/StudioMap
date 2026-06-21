import SwiftUI

struct ConnectionLegendView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Connection Types") {
                    ForEach(ConnectionType.allCases) { type in
                        HStack(spacing: 16) {
                            // Line + arrow preview
                            ZStack {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(type.color)
                                    .frame(width: 44, height: 3)

                                if type.isBidirectional {
                                    HStack(spacing: 0) {
                                        Image(systemName: "arrowtriangle.left.fill")
                                            .font(.system(size: 7))
                                            .foregroundStyle(type.color)
                                            .offset(x: -4)
                                        Spacer()
                                        Image(systemName: "arrowtriangle.right.fill")
                                            .font(.system(size: 7))
                                            .foregroundStyle(type.color)
                                            .offset(x: 4)
                                    }
                                    .frame(width: 44)
                                } else {
                                    HStack {
                                        Spacer()
                                        Image(systemName: "arrowtriangle.right.fill")
                                            .font(.system(size: 7))
                                            .foregroundStyle(type.color)
                                            .offset(x: 4)
                                    }
                                    .frame(width: 44)
                                }
                            }
                            .frame(width: 44)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(type.rawValue)
                                    .font(.headline)
                                Text(type.legendDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Line Thickness") {
                    thicknessRow("Thin",   subtitle: "1–2 channels",   height: 2)
                    thicknessRow("Medium", subtitle: "3–8 channels",   height: 4)
                    thicknessRow("Thick",  subtitle: "9+ channels (ADAT/MADI)", height: 7)
                }

                Section("Signal Flow") {
                    Label("Arrows show signal direction", systemImage: "arrowtriangle.right.fill")
                    Label("Two arrows = bidirectional (Computer, Bluetooth)", systemImage: "arrow.left.arrow.right")
                    Label("Multiple connections can share the same port (splitters)", systemImage: "arrow.triangle.branch")
                }
            }
            .navigationTitle("Connection Legend")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func thicknessRow(_ label: String, subtitle: String, height: CGFloat) -> some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: height / 2)
                .fill(Color(white: 0.6))
                .frame(width: 44, height: height)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.headline)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
