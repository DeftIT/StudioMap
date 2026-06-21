import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = StudioViewModel()
    @State private var showDeleteConfirm = false
    @State private var studioToDelete: Studio? = nil
    @State private var showRenameAlert = false
    @State private var studioToRename: Studio? = nil
    @State private var showImporter = false
    @State private var importError: String? = nil

    var body: some View {
        List(selection: $appState.selectedStudioId) {
            ForEach(vm.filteredStudios(from: appState.studios)) { studio in
                Label(studio.name, systemImage: "waveform.path.ecg")
                    .tag(studio.id)
                    .contextMenu {
                        Button("Rename") {
                            studioToRename = studio
                            showRenameAlert = true
                        }
                        Divider()
                        Button("Delete", role: .destructive) {
                            studioToDelete = studio
                            showDeleteConfirm = true
                        }
                    }
            }
        }
        .navigationTitle("Studios")
        .searchable(text: $vm.searchText, prompt: "Search studios")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Menu {
                    Button(action: { appState.exportJSON() }) {
                        Label("Export JSON", systemImage: "square.and.arrow.up")
                    }
                    Button(action: { showImporter = true }) {
                        Label("Import JSON", systemImage: "square.and.arrow.down")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }

                Button(action: { appState.activeSheet = .addStudio }) {
                    Image(systemName: "plus")
                }
            }
        }
        .confirmationDialog(
            "Delete Studio?",
            isPresented: $showDeleteConfirm,
            presenting: studioToDelete
        ) { s in
            Button("Delete \"\(s.name)\"", role: .destructive) {
                appState.deleteStudio(id: s.id)
            }
            Button("Cancel", role: .cancel) {}
        }
        .renameStudioAlert(isPresented: $showRenameAlert, studio: studioToRename) { newName in
            if let id = studioToRename?.id {
                appState.renameStudio(id: id, newName: newName)
            }
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first { appState.importJSON(from: url) }
            case .failure(let error):
                importError = error.localizedDescription
            }
        }
        .alert("Import Failed", isPresented: Binding(
            get: { importError != nil },
            set: { if !$0 { importError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importError ?? "")
        }
        // Export share sheet
        .sheet(isPresented: Binding(
            get: { appState.exportURL != nil },
            set: { if !$0 { appState.exportURL = nil } }
        )) {
            if let url = appState.exportURL {
                ShareSheet(url: url)
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
