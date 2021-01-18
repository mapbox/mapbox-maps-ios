import Foundation

internal extension Double {
    static func testSourceValue() -> Double {
        return 100.0
    }
}

internal extension String {
    static func testSourceValue() -> String {
        return "test-string"
    }
}

internal extension Array where Element == String {
    static func testSourceValue() -> [String] {
        return ["test-string-1", "test-string-2"]
    }
}

internal extension Array where Element == Double {
    static func testSourceValue() -> [Double] {
        return [1.0, 2.0, 3.0]
    }
}

internal extension Array where Element == [Double] {
    static func testSourceValue() -> [[Double]] {
        return [[30.0, 30.0], [0.0, 0.0]]
    }
}

internal extension Bool {
    static func testSourceValue() -> Bool {
        return true
    }
}
