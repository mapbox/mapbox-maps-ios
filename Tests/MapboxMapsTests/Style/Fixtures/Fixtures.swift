import Foundation
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

internal extension String {
    static func testSourceValue() -> String {
        return "test-string"
    }

    static func testConstantValue() -> String {
        return "test-string"
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

internal extension Dictionary where Key == String, Value == Expression {
    static func testSourceValue() -> [String: Expression] {
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

internal extension PromoteId {
    static func testSourceValue() -> PromoteId {
        return .string("test-promote-id")
    }
}

internal extension Array where Element == RasterArraySource.RasterDataLayer {
    static func testSourceValue() -> [RasterArraySource.RasterDataLayer] {
        return [.init(layerId: "test-layer-id", bands: ["band_0", "band_1"])]
    }
}
