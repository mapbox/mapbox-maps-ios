import Foundation
extension String {
    static func testConstantAlphanumeric(withLength length: UInt) -> Self {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return (0..<length).reduce(into: "") { s, i in s.append(letters[letters.index(letters.startIndex, offsetBy: Int(i) % letters.count)]) }
    }

    static func testConstantASCII(withLength length: UInt) -> Self {
        return (0..<length).reduce(into: "") { s, i in s.append(.testConstantASCII(index: Int(i))) }
    }
}
