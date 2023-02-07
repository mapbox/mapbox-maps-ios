import Foundation
extension String {
    static func randomAlphanumeric(withLength length: UInt) -> Self {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return (0..<length).reduce(into: "") { s, _ in s.append(letters.randomElement()!) }
    }

    static func randomASCII(withLength length: UInt) -> Self {
        return (0..<length).reduce(into: "") { s, _ in s.append(.randomASCII()) }
    }
}
