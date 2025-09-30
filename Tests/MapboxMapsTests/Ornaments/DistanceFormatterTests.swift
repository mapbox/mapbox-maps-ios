import XCTest
@testable import MapboxMaps

class DistanceFormatterTests: XCTestCase {

    func testMetersFormat() {
        let sut = DistanceFormatter()
        sut.locale = Locale(identifier: "EN_CA")

        let formattedString = sut.string(fromDistance: 1, units: .metric)

        XCTAssert(sut.locale.usesMetricSystem, "Selected locale does not use Metric system")
        XCTAssertEqual(formattedString, "1 m", "Meters distance is not formatted correctly!")
    }

    func testKilometersFormat() {
        let sut = DistanceFormatter()
        sut.locale = Locale(identifier: "EN_CA")

        let formattedString = sut.string(fromDistance: 1337, units: .metric)

        XCTAssert(sut.locale.usesMetricSystem, "Selected locale does not use Metric system")
        XCTAssertEqual(formattedString, "1.25 km", "Kilometers distance is not formatted correctly!")
    }

    func testFeetFormat() {
        let sut = DistanceFormatter()
        sut.locale = Locale(identifier: "EN_US")

        let formattedString = sut.string(fromDistance: 1, units: .imperial)

        XCTAssert(!sut.locale.usesMetricSystem, "Selected locale does not use Imperial system")
        XCTAssertEqual(formattedString, "3.25 ft", "Feet distance is not formatted correctly!")
    }

    func testMilesFormat() {
        let sut = DistanceFormatter()
        sut.locale = Locale(identifier: "EN_US")

        let formattedString = sut.string(fromDistance: 1337, units: .imperial)

        XCTAssert(!sut.locale.usesMetricSystem, "Selected locale does not use Imperial system")
        XCTAssertEqual(formattedString, "0.75 mi", "Miles distance is not formatted correctly!")
    }

    func testMetricOverride() {
        let sut = DistanceFormatter()
        sut.locale = Locale(identifier: "EN_US")

        let formattedString = sut.string(fromDistance: 1337, units: .metric)

        XCTAssertFalse(sut.locale.usesMetricSystem, "Selected locale does not use Metric system")
        XCTAssertEqual(formattedString, "1.25 km", "Kilometers distance is not formatted correctly!")
    }

    func testImperialOverride() {
        let sut = DistanceFormatter()
        sut.locale = Locale(identifier: "EN_CA")

        let formattedString = sut.string(fromDistance: 1337, units: .imperial)

        XCTAssert(sut.locale.usesMetricSystem, "Selected locale does not use Metric system")
        XCTAssertEqual(
            formattedString.trimmingCharacters(in: CharacterSet(charactersIn: ".")),
            "0.75 mi",
            "Miles distance is not formatted correctly!")
    }

    func testFathomsFormat() {
        let sut = DistanceFormatter()
        sut.locale = Locale(identifier: "EN_US")

        let formattedString = sut.string(fromDistance: 18.288, units: .nautical) // ~10 fathoms

        XCTAssertEqual(formattedString, "10 fth", "Small nautical distance should be formatted in fathoms")
    }

    func testNauticalMilesFormat() {
        let sut = DistanceFormatter()
        sut.locale = Locale(identifier: "EN_US")

        let formattedString = sut.string(fromDistance: 1852, units: .nautical) // 1 nautical mile

        XCTAssertEqual(formattedString, "1 nmi", "Large nautical distance should be formatted in nautical miles")
    }

    func testNauticalUnitsFormatting() {
        let sut = DistanceFormatter()
        sut.locale = Locale(identifier: "EN_US")

        // Test small distance (should use fathoms)
        let smallDistance = sut.string(fromDistance: 103, units: .nautical) // ~54 fathoms
        XCTAssertEqual(smallDistance, "56.25 fth", "Distance under 0.2 nautical miles should use fathoms")

        // Test large distance (should use nautical miles)
        let largeDistance = sut.string(fromDistance: 5556, units: .nautical) // ~3 nautical miles
        XCTAssertEqual(largeDistance, "3 nmi", "Distance over 0.2 nautical miles should use nautical miles")
    }
}
