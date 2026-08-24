import Foundation

@MainActor
final class AppContainer {
    let apiClient: APIClient
    let decoder: DataDecoding
    let cache: Caching

    init(
        apiClient: APIClient = URLSessionAPIClient(),
        decoder: DataDecoding = JSONDataDecoder(),
        cache: Caching = MemoryCache()
    ) {
        self.apiClient = apiClient
        self.decoder = decoder
        self.cache = cache
    }

    func makeProductRepository() -> ProductRepository {
        DefaultProductRepository(api: apiClient, decoder: decoder, cache: cache)
    }

    func makeProductListViewModel() -> ProductListViewModel {
        ProductListViewModel(repository: makeProductRepository())
    }
}
