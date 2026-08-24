import Foundation

protocol DataDecoding: Sendable {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

struct JSONDataDecoder: DataDecoding {
    var decoder = JSONDecoder()

    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try decoder.decode(type, from: data)
    }
}
