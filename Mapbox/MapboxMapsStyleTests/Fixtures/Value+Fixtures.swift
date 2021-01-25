import Foundation
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

internal extension Value where T == Double {
    static func testConstantValue() -> Value<Double> {
        return .constant(1.0)
    }
}

internal extension Value where T == [Double] {
    static func testConstantValue() -> Value<[Double]> {
        return .constant([1.0, 2.0])
    }
}

internal extension Value where T == String {
    static func testConstantValue() -> Value<String> {
        return .constant("some string")
    }
}

internal extension Value where T == ColorRepresentable {
    static func testConstantValue() -> Value<ColorRepresentable> {
        return .constant(ColorRepresentable(color: .red)!)
    }
}

internal extension Value where T == [String] {
    static func testConstantValue() -> Value<[String]> {
        return .constant(["some string", "some other string"])
    }
}

internal extension Value where T == ResolvedImage {
    static func testConstantValue() -> Value<ResolvedImage> {
        return .constant(ResolvedImage.name("some-resolved-image"))
    }
}

internal extension Value where T == Bool {
    static func testConstantValue() -> Value<Bool> {
        return .constant(true)
    }
}

internal extension Array where Element == TextAnchor {
    static func testConstantValue() -> [TextAnchor] {
        return [.bottom, .right]
    }
}

internal extension Array where Element == TextWritingMode {
    static func testConstantValue() -> [TextWritingMode] {
        return [.horizontal, .vertical]
    }
}
