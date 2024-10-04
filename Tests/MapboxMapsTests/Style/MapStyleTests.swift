import XCTest
@testable import MapboxMaps
import Foundation

final class MapStyleTests: XCTestCase {
    func testStandard() throws {
        let standard = MapStyle.standard(
            theme: .faded,
            lightPreset: .night,
            font: .barlow,
            showPointOfInterestLabels: true,
            showTransitLabels: true,
            showPlaceLabels: true,
            showRoadLabels: true,
            show3dObjects: false)
        let config = try XCTUnwrap(standard.configuration)
        XCTAssertEqual(config["theme"], .string("faded"))
        XCTAssertEqual(config["lightPreset"], .string("night"))
        XCTAssertEqual(config["font"], .string("Barlow"))
        XCTAssertEqual(config["showPointOfInterestLabels"], .boolean(true))
        XCTAssertEqual(config["showTransitLabels"], .boolean(true))
        XCTAssertEqual(config["showPlaceLabels"], .boolean(true))
        XCTAssertEqual(config["showRoadLabels"], .boolean(true))
        XCTAssertEqual(config["show3dObjects"], .boolean(false))
        XCTAssertEqual(standard.data, .uri(.standard))
    }

    func testStandardSatellite() throws {
        let standard = MapStyle.standardSatellite(
            lightPreset: .dawn,
            font: .lato,
            showPointOfInterestLabels: true,
            showTransitLabels: true,
            showPlaceLabels: false,
            showRoadLabels: true,
            showPedestrianRoads: false)
        let config = try XCTUnwrap(standard.configuration)
        XCTAssertEqual(config["lightPreset"], .string("dawn"))
        XCTAssertEqual(config["font"], .string("Lato"))
        XCTAssertEqual(config["showPointOfInterestLabels"], .boolean(true))
        XCTAssertEqual(config["showTransitLabels"], .boolean(true))
        XCTAssertEqual(config["showPlaceLabels"], .boolean(false))
        XCTAssertEqual(config["showRoadLabels"], .boolean(true))
        XCTAssertEqual(config["showPedestrianRoads"], .boolean(false))
        XCTAssertEqual(standard.data, .uri(.standardSatellite))
    }
}
