import Foundation

struct Product: Identifiable, Equatable, Codable, Sendable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let thumbnail: String?
}

struct ProductPage: Equatable, Codable, Sendable {
    let products: [Product]
    let total: Int
}
