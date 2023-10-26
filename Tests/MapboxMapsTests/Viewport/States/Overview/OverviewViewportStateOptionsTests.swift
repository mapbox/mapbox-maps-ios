import MapboxMaps
import XCTest

final class OverviewViewportStateOptionsTests: XCTestCase {
    func testInitWithDefaultValues() {
        let geometry: GeometryConvertible = [
            Point(.random()),
            LineString([.random(), .random()])
        ].randomElement()!

        let options = OverviewViewportStateOptions(geometry: geometry)

        XCTAssertEqual(options.geometry, geometry.geometry)
        XCTAssertEqual(options.padding, nil)
        XCTAssertEqual(options.bearing, 0)
        XCTAssertEqual(options.pitch, 0)
        XCTAssertEqual(options.animationDuration, 1)
    }

    func testInitWithNonDefaultValues() {
        let geometry: GeometryConvertible = [
            Point(.random()),
            LineString([.random(), .random()])
        ].randomElement()!
        let geometryPadding = UIEdgeInsets.random()
        let padding = UIEdgeInsets.random()
        let bearing = CLLocationDirection?.random(.random(in: 0..<360))
        let pitch = CGFloat?.random(.random(in: 0...80))
        let animationDuration = TimeInterval.random(in: 0..<10)

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
