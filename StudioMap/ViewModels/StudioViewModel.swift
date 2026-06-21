import Foundation

@MainActor
final class StudioViewModel: ObservableObject {
    @Published var searchText: String = ""

    func filteredStudios(from studios: [Studio]) -> [Studio] {
        guard !searchText.isEmpty else { return studios }
        return studios.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}
