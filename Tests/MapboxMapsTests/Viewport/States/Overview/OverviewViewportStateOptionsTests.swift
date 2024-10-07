import MapboxMaps
import XCTest

final class OverviewViewportStateOptionsTests: XCTestCase {
    func testInitWithDefaultValues() {
        let geometry: GeometryConvertible = LineString([.testConstantValue(), .testConstantValue()])

        let options = OverviewViewportStateOptions(geometry: geometry)

        XCTAssertEqual(options.geometry, geometry.geometry)
        XCTAssertEqual(options.padding, nil)
        XCTAssertEqual(options.bearing, 0)
        XCTAssertEqual(options.pitch, 0)
        XCTAssertEqual(options.animationDuration, 1)
    }

    func testInitWithNonDefaultValues() {
        let geometry: GeometryConvertible =  Point(.testConstantValue())
        let geometryPadding = UIEdgeInsets.testConstantValue()
        let padding = UIEdgeInsets.testConstantValue()
        let bearing = 123.9
        let pitch = 43.9
        let animationDuration = TimeInterval.testConstantValue()

        let options = OverviewViewportStateOptions(
            geometry: geometry,
            geometryPadding: geometryPadding,
            bearing: bearing,
            pitch: pitch,
            padding: padding,
            animationDuration: animationDuration)

        XCTAssertEqual(options.geometry, geometry.geometry)
        XCTAssertEqual(options.geometryPadding, geometryPadding)
        XCTAssertEqual(options.padding, padding)
        XCTAssertEqual(options.bearing, bearing)
        XCTAssertEqual(options.pitch, pitch)
        XCTAssertEqual(options.animationDuration, animationDuration)
    }
}
