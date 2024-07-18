import UIKit
@testable import MapboxMaps

internal extension Value where T == Double {
    static func testConstantValue() -> Value<Double> {
        return .constant(.testConstantValue())
    }
}

internal extension Value where T == [Double] {
    static func testConstantValue() -> Value<[Double]> {
        return .constant(.testConstantValue())
    }
}

internal extension Value where T == String {
    static func testConstantValue() -> Value<String> {
        return .constant("some string")
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

internal extension Value where T == StyleColor {
    static func testConstantValue() -> Value<StyleColor> {
        return .constant(StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)))
    }
}

internal extension Value where T == Bool {
    static func testConstantValue() -> Value<Bool> {
        return .constant(true)
    }
}

internal extension Value where T == [TextAnchor] {
    static func testConstantValue() -> Value<[TextAnchor]> {
        return .constant([.bottom, .right])
    }
}

internal extension Value where T == [ClipLayerTypes] {
    static func testConstantValue() -> Value<[ClipLayerTypes]> {
        return .constant([.model, .symbol])
    }
}

internal extension Value where T == [TextWritingMode] {
    static func testConstantValue() -> Value<[TextWritingMode]> {
        return .constant([.horizontal, .vertical])
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

internal extension Array where Element == ClipLayerTypes {
    static func testConstantValue() -> [ClipLayerTypes] {
        return [.model, .symbol]
    }
}

internal extension Value {
    init?(stylePropertyValue: StylePropertyValue) {
        switch (stylePropertyValue.kind, stylePropertyValue.value) {
        case (.constant, let value as T):
            self = .constant(value)
        case (.expression, let expression):
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: expression)
                let decodedStruct = try JSONDecoder().decode(Exp.self, from: jsonData)
                self = .expression(decodedStruct)
            } catch {
                return nil
            }
        default:
            return nil
        }
    }
}
