import Foundation

extension Encodable {
    func jsonString() throws -> String {
        try String(decoding: JSONEncoder().encode(self), as: UTF8.self)
    }
}
