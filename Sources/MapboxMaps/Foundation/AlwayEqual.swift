import Foundation

struct AlwaysEqual<Value>: Equatable {
    var value: Value
    static func == (lhs: Self, rhs: Self) -> Bool { true }
}

extension AlwaysEqual: ExpressibleByNilLiteral where Value: ExpressibleByNilLiteral {
    init(nilLiteral: ()) { self.init(value: nil) }
}
