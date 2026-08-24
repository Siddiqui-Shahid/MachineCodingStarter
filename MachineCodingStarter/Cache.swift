import Foundation

protocol Caching: Sendable {
    func get<T>(_ key: String) async -> T?
    func set<T>(_ value: T, for key: String) async
}

actor MemoryCache: Caching {
    private var storage: [String: Any] = [:]

    func get<T>(_ key: String) -> T? { storage[key] as? T }
    func set<T>(_ value: T, for key: String) { storage[key] = value }
}
