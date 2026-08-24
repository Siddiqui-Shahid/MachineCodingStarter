import XCTest
@testable import MachineCodingStarter

private struct FakeRepository: ProductRepository {
    var all: [Product] = []
    var total = 0
    var pageSize = 20
    var error: Error?

    func fetchProducts(skip: Int, query: String?, fresh: Bool) async throws -> ProductPage {
        if let error { throw error }
        return ProductPage(products: Array(all.dropFirst(skip).prefix(pageSize)), total: total)
    }
}

private final class CountingAPI: APIClient, @unchecked Sendable {
    var data: Data
    var calls = 0

    init(data: Data) { self.data = data }

    func data(from url: URL) async throws -> Data {
        calls += 1
        return data
    }
}

@MainActor
final class ProductListViewModelTests: XCTestCase {
    private func product(_ id: Int) -> Product {
        Product(id: id, title: "Item \(id)", description: "", price: 1, thumbnail: nil)
    }

    private func makeDefaults() -> UserDefaults {
        let defaults = UserDefaults(suiteName: "ProductListViewModelTests")!
        defaults.removePersistentDomain(forName: "ProductListViewModelTests")
        return defaults
    }

    func testLoadSuccess() async {
        let repo = FakeRepository(all: [product(1)], total: 1)
        let vm = ProductListViewModel(repository: repo, defaults: makeDefaults())
        await vm.load(reset: true)
        XCTAssertEqual(vm.products.map(\.id), [1])
        XCTAssertNil(vm.errorMessage)
    }

    func testLoadError() async {
        var repo = FakeRepository()
        repo.error = APIError.badStatus(500)
        let vm = ProductListViewModel(repository: repo, defaults: makeDefaults())
        await vm.load(reset: true)
        XCTAssertTrue(vm.products.isEmpty)
        XCTAssertNotNil(vm.errorMessage)
    }

    func testLoadMore() async {
        let repo = FakeRepository(all: [product(1), product(2), product(3)], total: 3, pageSize: 2)
        let vm = ProductListViewModel(repository: repo, defaults: makeDefaults())
        await vm.load(reset: true)
        await vm.loadMore()
        XCTAssertEqual(vm.products.map(\.id), [1, 2, 3])
    }

    func testFavoritesPersist() {
        let defaults = makeDefaults()
        let vm = ProductListViewModel(repository: FakeRepository(), defaults: defaults)
        let item = product(4)
        vm.toggleFav(item)
        XCTAssertTrue(vm.isFav(item))
        let again = ProductListViewModel(repository: FakeRepository(), defaults: defaults)
        XCTAssertTrue(again.isFav(item))
    }
}

final class ProductRepositoryTests: XCTestCase {
    func testDecodeAndCache() async throws {
        let json = Data(#"{"products":[{"id":1,"title":"Phone","description":"x","price":9.5,"thumbnail":null}],"total":1}"#.utf8)
        let api = CountingAPI(data: json)
        let repo = DefaultProductRepository(api: api, decoder: JSONDataDecoder(), cache: MemoryCache())

        let first = try await repo.fetchProducts(skip: 0, query: nil, fresh: false)
        let second = try await repo.fetchProducts(skip: 0, query: nil, fresh: false)

        XCTAssertEqual(first.products.first?.title, "Phone")
        XCTAssertEqual(second.products.first?.id, 1)
        XCTAssertEqual(api.calls, 1)
    }

    func testFreshBypassesCache() async throws {
        let json = Data(#"{"products":[{"id":1,"title":"Phone","description":"","price":1,"thumbnail":null}],"total":1}"#.utf8)
        let api = CountingAPI(data: json)
        let repo = DefaultProductRepository(api: api, decoder: JSONDataDecoder(), cache: MemoryCache())

        _ = try await repo.fetchProducts(skip: 0, query: nil, fresh: false)
        _ = try await repo.fetchProducts(skip: 0, query: nil, fresh: true)
        XCTAssertEqual(api.calls, 2)
    }
}
