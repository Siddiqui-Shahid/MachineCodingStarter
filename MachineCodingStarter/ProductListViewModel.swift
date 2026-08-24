import Combine
import Foundation

@MainActor
final class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var favorites: Set<Int> = []

    private let repository: ProductRepository
    private let defaults: UserDefaults
    private let favKey = "favorites"
    private var hasMore = true
    private var searchTask: Task<Void, Never>?

    init(repository: ProductRepository, defaults: UserDefaults = .standard) {
        self.repository = repository
        self.defaults = defaults
        favorites = Set(defaults.array(forKey: favKey) as? [Int] ?? [])
    }

    func load(reset: Bool) async {
        if reset {
            products = []
            hasMore = true
        } else if !hasMore || isLoading {
            return
        }
        isLoading = true
        errorMessage = nil
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            let page = try await repository.fetchProducts(
                skip: products.count,
                query: q.isEmpty ? nil : q,
                fresh: reset
            )
            products += page.products
            hasMore = products.count < page.total && !page.products.isEmpty
        } catch is CancellationError {
        } catch {
            if products.isEmpty { errorMessage = error.localizedDescription }
        }
        isLoading = false
    }

    func loadMore() async { await load(reset: false) }

    func searchChanged() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            await load(reset: true)
        }
    }

    func toggleFav(_ product: Product) {
        if favorites.contains(product.id) { favorites.remove(product.id) }
        else { favorites.insert(product.id) }
        defaults.set(Array(favorites), forKey: favKey)
    }

    func isFav(_ product: Product) -> Bool { favorites.contains(product.id) }
}
