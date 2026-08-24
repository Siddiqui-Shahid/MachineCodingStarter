import Foundation

protocol ProductRepository: Sendable {
    func fetchProducts(skip: Int, query: String?, fresh: Bool) async throws -> ProductPage
}

struct DefaultProductRepository: ProductRepository {
    var api: APIClient
    var decoder: DataDecoding
    var cache: Caching
    var pageSize = 20

    func fetchProducts(skip: Int, query: String?, fresh: Bool) async throws -> ProductPage {
        let key = "\(query ?? "")|\(skip)"
        if !fresh, let cached: ProductPage = await cache.get(key) { return cached }

        let dto: ProductListDTO = try decoder.decode(
            ProductListDTO.self,
            from: try await api.data(from: url(skip: skip, query: query))
        )
        let page = dto.toDomain()
        await cache.set(page, for: key)
        return page
    }

    private func url(skip: Int, query: String?) -> URL {
        var url = URL(string: "https://dummyjson.com/products")!
        var items = [
            URLQueryItem(name: "limit", value: "\(pageSize)"),
            URLQueryItem(name: "skip", value: "\(skip)")
        ]
        if let query, !query.isEmpty {
            url = URL(string: "https://dummyjson.com/products/search")!
            items.insert(URLQueryItem(name: "q", value: query), at: 0)
        }
        return url.appending(queryItems: items)
    }
}
