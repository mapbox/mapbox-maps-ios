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
            showPedestrianRoads: false,
            show3dObjects: false,
            backgroundPointOfInterestLabels: .circle,
            colorAdminBoundaries: StyleColor(.red),
            colorBuildingHighlight: StyleColor(.blue),
            colorBuildingSelect: StyleColor(.green),
            colorGreenspace: StyleColor(.cyan),
            colorModePointOfInterestLabels: .single,
            colorMotorways: StyleColor(.yellow),
            colorPlaceLabelHighlight: StyleColor(.magenta),
            colorPlaceLabels: StyleColor(.orange),
            colorPlaceLabelSelect: StyleColor(.purple),
            colorPointOfInterestLabels: StyleColor(.brown),
            colorRoadLabels: StyleColor(.gray),
            colorRoads: StyleColor(.lightGray),
            colorTrunks: StyleColor(.darkGray),
            colorWater: StyleColor(.blue),
            densityPointOfInterestLabels: 2.5,
            roadsBrightness: 0.6,
            showAdminBoundaries: false,
            showLandmarkIconLabels: false,
            showLandmarkIcons: true,
            themeData: "custom-theme-data")
        let config = try XCTUnwrap(standard.configuration)
        XCTAssertEqual(config["theme"], .string("faded"))
        XCTAssertEqual(config["lightPreset"], .string("night"))
        XCTAssertEqual(config["font"], .string("Barlow"))
        XCTAssertEqual(config["showPointOfInterestLabels"], .boolean(true))
        XCTAssertEqual(config["showTransitLabels"], .boolean(true))
        XCTAssertEqual(config["showPlaceLabels"], .boolean(true))
        XCTAssertEqual(config["showRoadLabels"], .boolean(true))
        XCTAssertEqual(config["showPedestrianRoads"], .boolean(false))
        XCTAssertEqual(config["show3dObjects"], .boolean(false))
        XCTAssertEqual(config["colorBuildingHighlight"], .string("rgba(0.00, 0.00, 255.00, 1.00)"))
        XCTAssertEqual(config["colorBuildingSelect"], .string("rgba(0.00, 255.00, 0.00, 1.00)"))
        XCTAssertEqual(config["colorMotorways"], .string("rgba(255.00, 255.00, 0.00, 1.00)"))
        XCTAssertEqual(config["colorPlaceLabelHighlight"], .string("rgba(255.00, 0.00, 255.00, 1.00)"))
        XCTAssertEqual(config["colorPlaceLabelSelect"], .string("rgba(127.50, 0.00, 127.50, 1.00)"))
        XCTAssertEqual(config["colorRoads"], .string("rgba(170.00, 170.00, 170.00, 1.00)"))
        XCTAssertEqual(config["colorTrunks"], .string("rgba(85.00, 85.00, 85.00, 1.00)"))
        XCTAssertEqual(config["showLandmarkIcons"], .boolean(true))
        XCTAssertEqual(config["theme-data"], .string("custom-theme-data"))
        XCTAssertEqual(config["backgroundPointOfInterestLabels"], .string("circle"))
        XCTAssertEqual(config["colorAdminBoundaries"], .string("rgba(255.00, 0.00, 0.00, 1.00)"))
        XCTAssertEqual(config["colorGreenspace"], .string("rgba(0.00, 255.00, 255.00, 1.00)"))
        XCTAssertEqual(config["colorModePointOfInterestLabels"], .string("single"))
        XCTAssertEqual(config["colorPlaceLabels"], .string("rgba(255.00, 127.50, 0.00, 1.00)"))
        XCTAssertEqual(config["colorPointOfInterestLabels"], .string("rgba(153.00, 102.00, 51.00, 1.00)"))
        XCTAssertEqual(config["colorRoadLabels"], .string("rgba(127.50, 127.50, 127.50, 1.00)"))
        XCTAssertEqual(config["colorWater"], .string("rgba(0.00, 0.00, 255.00, 1.00)"))
        XCTAssertEqual(config["densityPointOfInterestLabels"], .number(2.5))
        XCTAssertEqual(config["roadsBrightness"], .number(0.6))
        XCTAssertEqual(config["showAdminBoundaries"], .boolean(false))
        XCTAssertEqual(config["showLandmarkIconLabels"], .boolean(false))
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
            showRoadsAndTransit: false,
            showPedestrianRoads: false,
            backgroundPointOfInterestLabels: .noBackground,
            colorAdminBoundaries: StyleColor(.red),
            colorModePointOfInterestLabels: .default,
            colorMotorways: StyleColor(.yellow),
            colorPlaceLabelHighlight: StyleColor(.magenta),
            colorPlaceLabels: StyleColor(.orange),
            colorPlaceLabelSelect: StyleColor(.purple),
            colorPointOfInterestLabels: StyleColor(.brown),
            colorRoadLabels: StyleColor(.gray),
            colorRoads: StyleColor(.lightGray),
            colorTrunks: StyleColor(.darkGray),
            densityPointOfInterestLabels: 1.8,
            roadsBrightness: 0.7,
            showAdminBoundaries: true)
        let config = try XCTUnwrap(standard.configuration)
        XCTAssertEqual(config["lightPreset"], .string("dawn"))
        XCTAssertEqual(config["font"], .string("Lato"))
        XCTAssertEqual(config["showPointOfInterestLabels"], .boolean(true))
        XCTAssertEqual(config["showTransitLabels"], .boolean(true))
        XCTAssertEqual(config["showPlaceLabels"], .boolean(false))
        XCTAssertEqual(config["showRoadLabels"], .boolean(true))
        XCTAssertEqual(config["showRoadsAndTransit"], .boolean(false))
        XCTAssertEqual(config["showPedestrianRoads"], .boolean(false))
        XCTAssertEqual(config["colorMotorways"], .string("rgba(255.00, 255.00, 0.00, 1.00)"))
        XCTAssertEqual(config["colorPlaceLabelHighlight"], .string("rgba(255.00, 0.00, 255.00, 1.00)"))
        XCTAssertEqual(config["colorPlaceLabelSelect"], .string("rgba(127.50, 0.00, 127.50, 1.00)"))
        XCTAssertEqual(config["colorRoads"], .string("rgba(170.00, 170.00, 170.00, 1.00)"))
        XCTAssertEqual(config["colorTrunks"], .string("rgba(85.00, 85.00, 85.00, 1.00)"))
        XCTAssertEqual(config["backgroundPointOfInterestLabels"], .string("none"))
        XCTAssertEqual(config["colorAdminBoundaries"], .string("rgba(255.00, 0.00, 0.00, 1.00)"))
        XCTAssertEqual(config["colorModePointOfInterestLabels"], .string("default"))
        XCTAssertEqual(config["colorPlaceLabels"], .string("rgba(255.00, 127.50, 0.00, 1.00)"))
        XCTAssertEqual(config["colorPointOfInterestLabels"], .string("rgba(153.00, 102.00, 51.00, 1.00)"))
        XCTAssertEqual(config["colorRoadLabels"], .string("rgba(127.50, 127.50, 127.50, 1.00)"))
        XCTAssertEqual(config["densityPointOfInterestLabels"], .number(1.8))
        XCTAssertEqual(config["roadsBrightness"], .number(0.7))
        XCTAssertEqual(config["showAdminBoundaries"], .boolean(true))
        XCTAssertEqual(standard.data, .uri(.standardSatellite))
    }
}
