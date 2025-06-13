import Foundation
import UIKit
@_spi(Experimental) @testable import MapboxMaps

internal extension Double {
    static func testSourceValue() -> Double {
        return 100.0
    }

    static func testConstantValue() -> Double {
        return 10.0
    }
}

internal extension StyleColor {
    static func testConstantValue() -> StyleColor {
        return StyleColor(.red)
    }
}

internal extension StyleTransition {
    static func testConstantValue() -> StyleTransition {
        return StyleTransition(duration: 2.0, delay: 2.0)
    }
}

internal extension TransitionOptions {
    static func testConstantValue() -> TransitionOptions {
        return TransitionOptions(duration: 2.0, delay: 1.0, enablePlacementTransitions: false)
    }
}

internal extension String {
    static func testSourceValue() -> String {
        return "test-string"
    }

    static func testConstantValue() -> String {
        return "test-string"
    }
}

internal extension Exp {
    static func testConstantValue() -> Exp {
        return Exp(.all)
    }
}

internal extension Array where Element == String {
    static func testSourceValue() -> [String] {
        return ["test-string-1", "test-string-2"]
    }

    static func testConstantValue() -> [String] {
        return ["test-string-1", "test-string-2"]
    }
}

internal extension Array where Element == Double {
    static func testSourceValue() -> [Double] {
        return [1.0, 2.0, 3.0]
    }

    static func testConstantValue() -> [Double] {
        return [1.0, 2.0, 3.0]
    }
}

internal extension Dictionary where Key == String, Value == Exp {
    static func testSourceValue() -> [String: Exp] {
        let exp = Exp(.sum) {
            10
            12
        }

        return ["sum": exp]
    }
}

extension TileCacheBudgetSize {
    static func testSourceValue(_ tileCacheBudget: TileCacheBudgetSize = .tiles(200)) -> TileCacheBudgetSize {
        tileCacheBudget
    }
}

internal extension Array where Element == [Double] {
    static func testSourceValue() -> [[Double]] {
        return [[30.0, 30.0], [0.0, 0.0], [30.0, 30.0], [0.0, 0.0]]
    }

    static func testConstantValue() -> [[Double]] {
        return [[30.0, 30.0], [0.0, 0.0], [30.0, 30.0], [0.0, 0.0]]
    }
}

internal extension Bool {
    static func testSourceValue() -> Bool {
        return true
    }

    static func testConstantValue() -> Bool {
        return true
    }
}

internal extension UIEdgeInsets {
    static func testConstantValue() -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 34, bottom: 56, right: 78)
    }
}

internal extension Slot {
    static func testConstantValue() -> Slot {
        return Slot.init(stringLiteral: "bottom")
    }
}

internal extension LayerPosition {
    static func testConstantValue() -> LayerPosition {
        return LayerPosition.at(1)
    }
}

internal extension PromoteId {
    static func testSourceValue() -> PromoteId {
        return .string("test-promote-id")
    }
}

internal extension VectorSourcePromoteId {
    static func testSourceValue() -> VectorSourcePromoteId {
        return .byLayer([
            "layer-1": .constant("test-promote-id-1"),
            "layer-2": .expression(Exp(.get, "name")),
        ])
    }
}

extension Value where T == String {
    static func testSourceValue() -> Value {
        .expression(Exp(.get, "name"))
    }
}

internal extension Array where Element == RasterArraySource.RasterDataLayer {
    static func testSourceValue() -> [RasterArraySource.RasterDataLayer] {
        return [.init(layerId: "test-layer-id", bands: ["band_0", "band_1"])]
    }
}

internal extension String {
    static func testStyleJSON() -> String {
        let styleJSONObject: [String: Any] = [
            "version": 8,
            "center": [
                -87.6298,
                 41.8781
            ],
            "zoom": 12,
            "sources": [Any](),
            "layers": [Any]()
        ]
        return ValueConverter.toJson(forValue: styleJSONObject)
    }
}
