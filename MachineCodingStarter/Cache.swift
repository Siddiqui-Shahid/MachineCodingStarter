import Foundation

protocol Caching: Sendable {
    func get<T: Codable>(_ key: String) async -> T?
    func set<T: Codable>(_ value: T, for key: String) async
}

actor MemoryCache: Caching {
    private var storage: [String: Any] = [:]

    func get<T: Codable>(_ key: String) -> T? { storage[key] as? T }
    func set<T: Codable>(_ value: T, for key: String) { storage[key] = value }
}

final class UserDefaultsCache: Caching, @unchecked Sendable {
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func get<T: Codable>(_ key: String) async -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    func set<T: Codable>(_ value: T, for key: String) async {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }
}
