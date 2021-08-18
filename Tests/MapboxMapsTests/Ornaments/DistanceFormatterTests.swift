import XCTest
@testable import MapboxMaps

class DistanceFormatterTests: XCTestCase {

    func testMetersFormat() {
        let sut = DistanceFormatter()
        sut.locale = Locale(identifier: "EN_CA")

        let formattedString = sut.string(fromDistance: 1)

        XCTAssert(sut.locale.usesMetricSystem, "Selected locale does not use Metric system")
        XCTAssertEqual(formattedString, "1 m", "Meters distance is not formatted correctly!")
    }

    func testKilometersFormat() {
        let sut = DistanceFormatter()
        sut.locale = Locale(identifier: "EN_CA")

        let formattedString = sut.string(fromDistance: 1337)

        XCTAssert(sut.locale.usesMetricSystem, "Selected locale does not use Metric system")
        XCTAssertEqual(formattedString, "1.25 km", "Kilometers distance is not formatted correctly!")
    }

    func testFeetFormat() {
        let sut = DistanceFormatter()
        sut.locale = Locale(identifier: "EN_US")

        let formattedString = sut.string(fromDistance: 1)

        XCTAssert(!sut.locale.usesMetricSystem, "Selected locale does not use Imperial system")
        XCTAssertEqual(formattedString, "3.25 ft", "Feet distance is not formatted correctly!")
    }

    func testMilesFormat() {
        let sut = DistanceFormatter()
        sut.locale = Locale(identifier: "EN_US")

        let formattedString = sut.string(fromDistance: 1337)

        XCTAssert(!sut.locale.usesMetricSystem, "Selected locale does not use Imperial system")
        XCTAssertEqual(formattedString, "0.75 mi", "Miles distance is not formatted correctly!")
    }
}
