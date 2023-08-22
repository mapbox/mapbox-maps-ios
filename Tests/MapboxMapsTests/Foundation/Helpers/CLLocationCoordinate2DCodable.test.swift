import XCTest
@testable import MapboxMaps

class CLLocationCoordinate2DCodableTest: XCTestCase {

    func testEquatableSupport() throws {
        let value1 = CLLocationCoordinate2DCodable(latitude: 10, longitude: 11)
        let value2 = CLLocationCoordinate2DCodable(latitude: 20, longitude: 21)
        let value3 = CLLocationCoordinate2DCodable(latitude: 10, longitude: 11)

        XCTAssertNotEqual(value1, value2)
        XCTAssertNotEqual(value3, value2)
        XCTAssertEqual(value1, value3)
    }

    func testHashableSupport() throws {
        let value1 = CLLocationCoordinate2DCodable(latitude: 10, longitude: 11)
        let value2 = CLLocationCoordinate2DCodable(latitude: 20, longitude: 21)
        let value3 = CLLocationCoordinate2DCodable(latitude: 10, longitude: 11)

        var dict: [AnyHashable: String] = [:]
        dict[value1] = "value1"
        dict[value2] = "value2"
        dict[value3] = "value3"

        XCTAssertEqual(dict.count, 2)
        XCTAssertEqual(dict[value1], "value3")
        XCTAssertEqual(dict[value2], "value2")
        XCTAssertEqual(dict[value3], "value3")
    }

    func testCodableSupport() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let value = CLLocationCoordinate2DCodable(latitude: -90,
                                                  longitude: 180)

        let data = try encoder.encode(value)
        let decodedValue = try decoder.decode(CLLocationCoordinate2DCodable.self, from: data)

        XCTAssertEqual(value.latitude, decodedValue.latitude)
        XCTAssertEqual(value.longitude, decodedValue.longitude)
        XCTAssertEqual(value, decodedValue)
    }

    func testCoreLocationCoordinatesConversion() throws {
        let coordinates: CLLocationCoordinate2D = .random()
        let codableCoordinates = CLLocationCoordinate2DCodable(coordinates)

        XCTAssertEqual(coordinates, codableCoordinates.coordinates)
    }

    func testCoreLocationCoordinatesMutation() {
        let coordinates = CLLocationCoordinate2D(latitude: 10, longitude: 20)
        let newCoordinates = CLLocationCoordinate2D(latitude: 30, longitude: 40)

        var codableCoordinates = CLLocationCoordinate2DCodable(coordinates)
        codableCoordinates.coordinates = newCoordinates

        XCTAssertEqual(codableCoordinates.coordinates, newCoordinates)
        XCTAssertNotEqual(codableCoordinates.coordinates, coordinates)
    }
}
