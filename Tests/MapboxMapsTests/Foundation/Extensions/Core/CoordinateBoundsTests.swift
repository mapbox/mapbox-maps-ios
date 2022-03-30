import XCTest
@testable import MapboxMaps

final class CoordinateBoundsTests: XCTestCase {

    func testFullIntersect() {
        let outer = CoordinateBounds(
            southwest: CLLocationCoordinate2D(latitude: 59.87239799228177, longitude: 21.46728515625),
            northeast: CLLocationCoordinate2D(latitude: 63.28306240110864, longitude: 28.575439453125))
        let inner = CoordinateBounds(
            southwest: CLLocationCoordinate2D(latitude: 60.855613316239335, longitude: 23.22509765625),
            northeast: CLLocationCoordinate2D(latitude: 61.938950426660604, longitude: 25.81787109375))

        XCTAssertEqual(outer.intersect(inner), inner)
        XCTAssertEqual(inner.intersect(outer), inner)
    }

    func testCornerIntersect() {
        let one = CoordinateBounds(
            southwest: CLLocationCoordinate2D(latitude: 59.87239799228177, longitude: 21.46728515625),
            northeast: CLLocationCoordinate2D(latitude: 63.28306240110864, longitude: 28.575439453125))
        let another = CoordinateBounds(
            southwest: CLLocationCoordinate2D(latitude: 59.5343180010956, longitude: 20.906982421874993),
            northeast: CLLocationCoordinate2D(latitude: 60.66241476534366, longitude: 23.49975585937499))
        let expected = CoordinateBounds(
            southwest: CLLocationCoordinate2D(latitude: 59.87239799228177, longitude: 21.46728515625),
            northeast: CLLocationCoordinate2D(latitude: 60.66241476534366, longitude: 23.49975585937499))

        XCTAssertEqual(one.intersect(another), expected)
        XCTAssertEqual(another.intersect(one), expected)
    }

    func testSideIntersect() {
        let one = CoordinateBounds(
            southwest: CLLocationCoordinate2D(latitude: 59.87239799228177, longitude: 21.46728515625),
            northeast: CLLocationCoordinate2D(latitude: 63.28306240110864, longitude: 28.575439453125))
        let another = CoordinateBounds(
            southwest: CLLocationCoordinate2D(latitude: 61.270232790000605, longitude: 20.577392578124996),
            northeast: CLLocationCoordinate2D(latitude: 62.33941057752868, longitude: 23.170166015624993))
        let expected = CoordinateBounds(
            southwest: CLLocationCoordinate2D(latitude: 61.270232790000605, longitude: 21.46728515625),
            northeast: CLLocationCoordinate2D(latitude: 62.33941057752868, longitude: 23.170166015624993))

        XCTAssertEqual(one.intersect(another), expected)
        XCTAssertEqual(another.intersect(one), expected)
    }

    func testNoIntersect() {
        let one = CoordinateBounds(
            southwest: CLLocationCoordinate2D(latitude: 59.87239799228177, longitude: 21.46728515625),
            northeast: CLLocationCoordinate2D(latitude: 63.28306240110864, longitude: 28.575439453125))
        let another = CoordinateBounds(
            southwest: CLLocationCoordinate2D(latitude: 61.270232790000605, longitude: 17.611083984375004),
            northeast: CLLocationCoordinate2D(latitude: 62.33941057752868, longitude: 20.203857421875))

        XCTAssertNil(one.intersect(another))
        XCTAssertNil(another.intersect(one))
    }

    func testEquals() {
        let one = CoordinateBounds(southwest: CLLocationCoordinate2D(), northeast: CLLocationCoordinate2D())
        let another = CoordinateBounds(southwest: CLLocationCoordinate2D(), northeast: CLLocationCoordinate2D())

        XCTAssertEqual(one, another)
    }

    func testNotEquals() {
        let one = CoordinateBounds(
            southwest: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            northeast: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            infiniteBounds: false)
        let swLat = CoordinateBounds(
            southwest: CLLocationCoordinate2D(latitude: -1, longitude: 0),
            northeast: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            infiniteBounds: false)
        let swLon = CoordinateBounds(
            southwest: CLLocationCoordinate2D(latitude: 0, longitude: -1),
            northeast: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            infiniteBounds: false)
        let neLat = CoordinateBounds(
            southwest: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            northeast: CLLocationCoordinate2D(latitude: 1, longitude: 0),
            infiniteBounds: false)
        let neLon = CoordinateBounds(
            southwest: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            northeast: CLLocationCoordinate2D(latitude: 0, longitude: 1),
            infiniteBounds: false)

        XCTAssertNotEqual(one, swLat)
        XCTAssertNotEqual(one, swLon)
        XCTAssertNotEqual(one, neLat)
        XCTAssertNotEqual(one, neLon)

        XCTAssertEqual(one.hash, 180_1800_900_90)
        XCTAssertEqual(swLat.hash, 180_1800_890_90)
        XCTAssertEqual(swLon.hash, 179_1800_900_90)
        XCTAssertEqual(neLat.hash, 180_1800_900_91)
        XCTAssertEqual(neLon.hash, 180_1810_900_90)
    }

    func testContains() {
        let bounds = CoordinateBounds(
            southwest: CLLocationCoordinate2D(latitude: 59.87239799228177, longitude: 21.46728515625),
            northeast: CLLocationCoordinate2D(latitude: 63.28306240110864, longitude: 28.575439453125))
        let pointsInside = [CLLocationCoordinate2D(latitude: 62.11416112594049, longitude: 26.25732421875),
                            CLLocationCoordinate2D(latitude: 61.079544234557304, longitude: 23.31298828125)]
        let pointsOnSides = [CLLocationCoordinate2D(latitude: 59.87239799228177, longitude: 26.25732421875),
                             CLLocationCoordinate2D(latitude: 61.079544234557304, longitude: 28.575439453125)]
        let pointsOutside = [CLLocationCoordinate2D(latitude: 62.11416112594049, longitude: 21.25732421875),
                            CLLocationCoordinate2D(latitude: 59.079544234557304, longitude: 23.31298828125)]

        XCTAssertTrue(bounds.contains(pointsInside))
        XCTAssertTrue(bounds.contains(pointsOnSides))
        XCTAssertFalse(bounds.contains(pointsOutside))
    }
}
