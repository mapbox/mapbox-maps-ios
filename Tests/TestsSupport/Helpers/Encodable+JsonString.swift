import Foundation

extension Encodable {
    func jsonString() throws -> String {
        try String(data: JSONEncoder().encode(self), encoding: .utf8)!
    }
}
