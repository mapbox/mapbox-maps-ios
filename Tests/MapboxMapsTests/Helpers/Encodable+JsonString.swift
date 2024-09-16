import Foundation

extension Encodable {
    func jsonString() throws -> String {
        String(data: try JSONEncoder().encode(self), encoding: .utf8)!
    }
}
