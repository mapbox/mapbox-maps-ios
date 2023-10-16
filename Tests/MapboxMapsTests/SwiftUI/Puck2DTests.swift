import XCTest
@_spi(Experimental) @testable import MapboxMaps

@available(iOS 13.0, *)
final class Puck2DTests: XCTestCase {

    func testVisit() throws {
        var expectedPuckConfiguration = Puck2DConfiguration.makeDefault(showBearing: false)
        expectedPuckConfiguration.scale = .constant(.random(in: 10...100))
        expectedPuckConfiguration.pulsing = .random(.default)
        expectedPuckConfiguration.showsAccuracyRing = .random()
        expectedPuckConfiguration.opacity = .random(in: 0...1)
        expectedPuckConfiguration.accuracyRingColor = .random()
        expectedPuckConfiguration.accuracyRingBorderColor = .random()

        let puck = Puck2D()
            .opacity(expectedPuckConfiguration.opacity)
            .scale(try XCTUnwrap(expectedPuckConfiguration.scale))
            .pulsing(expectedPuckConfiguration.pulsing)
            .showsAccuracyRing(expectedPuckConfiguration.showsAccuracyRing)
            .accuracyRingColor(expectedPuckConfiguration.accuracyRingColor)
            .accuracyRingBorderColor(expectedPuckConfiguration.accuracyRingBorderColor)

        let visitor = DefaultMapContentVisitor()
        puck.visit(visitor)

        XCTAssertEqual(visitor.locationOptions, .init(puckType: .puck2D(expectedPuckConfiguration), puckBearingEnabled: false))
    }
}
