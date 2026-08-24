import Foundation

struct ProductDTO: Decodable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let thumbnail: String?

    func toDomain() -> Product {
        Product(id: id, title: title, description: description, price: price, thumbnail: thumbnail)
    }
}

struct ProductListDTO: Decodable {
    let products: [ProductDTO]
    let total: Int

    func toDomain() -> ProductPage {
        ProductPage(products: products.map { $0.toDomain() }, total: total)
    }
}
