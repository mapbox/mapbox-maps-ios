import Foundation
@testable import MapboxMaps

extension Character {
    static func randomASCII() -> Self {
        return Character(UnicodeScalar(.random(in: 0x20...0x7E))!)
    }
}

extension String {
    static func randomASCII(withLength length: UInt) -> Self {
        return (0..<length).reduce(into: "") { s, _ in s.append(.randomASCII()) }
    }
}

extension StyleColor {
    static func random() -> Self {
        return StyleColor(
            red: .random(in: 0...255),
            green: .random(in: 0...255),
            blue: .random(in: 0...255),
            alpha: .random(in: 0...1))!
    }
}

extension Array {
    static func random(withLength length: UInt, generator: () -> Element) -> Self {
        return (0..<length).reduce(into: []) { array, _ in array.append(generator()) }
    }
}
