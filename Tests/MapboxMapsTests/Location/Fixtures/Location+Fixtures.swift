import MapboxMaps
import MapboxCommon

extension Location {
    static func testConstantValue() -> Location {
        Location(
            coordinate: .testConstantValue(),
            timestamp: Date(),
            bearing: .testConstantValue(),
            bearingAccuracy: .testConstantValue()
        )
    }
}

extension Heading {
    static func testConstantValue() -> Heading {
        Heading(direction: .testConstantValue(),
                accuracy: .testSourceValue())
    }
}

extension PuckRenderingData {
    static func testConstantValue() -> PuckRenderingData {
        PuckRenderingData(location: .testConstantValue(), heading: .testConstantValue())
    }
}

extension CLAccuracyAuthorization {
    static func testConstantValue() -> Self {
        return .reducedAccuracy
    }
}
