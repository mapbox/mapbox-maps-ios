import XCTest
import CoreLocation
import UIKit

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsFoundation
#endif

// swiftlint:disable explicit_top_level_acl explicit_acl
class MapboxMapsFoundationTests: XCTestCase {

    var mapView: BaseMapView!

    /**
       +/- 0.25 is the acceptable level of accuracy to account
       for differences in projecting coordinates to web mercator,
       and mirrors that of the existing Maps SDK implementation.
    */
    let accuracy = 0.25

    override func setUp() {
        /**
         Test with offset bounds
         */
        let resourceOptions = ResourceOptions(accessToken: "a1b2c3")
        mapView = BaseMapView(frame: CGRect(x: 10, y: 10, width: 100, height: 100),
                              resourceOptions: resourceOptions,
                              glyphsRasterizationOptions: GlyphsRasterizationOptions.default,
                              styleURI: nil)
    }

    override func tearDown() {
        mapView = nil
    }

    // MARK: Testing coordinate wrapping around the antimeridian

    func testCoordinateIsWrapped() {
        // Coordinate goes beyond the international date line (clockwise around the world once),
        // so it should be wrapped to stay within -180/180° longitude.
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 220)
        let worldLongitude = 360.0

        let expectedWrappedLongitude = coordinate.longitude - worldLongitude
        let actualWrappedLongitude = coordinate.wrap().longitude

        XCTAssertEqual(expectedWrappedLongitude, actualWrappedLongitude)
    }

    func testCoordinateIsNotWrapped() {
        // Coordinate doesn't go beyond international date line,
        // so it shouldn't be wrapped.
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 50)
        XCTAssertEqual(coordinate.longitude, coordinate.wrap().longitude)
    }

    // MARK: Converting between CGRect and coordinate bounds

    func testRectExtend() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let point = CGPoint(x: -10, y: -10)
        let expectedRect = rect.extend(from: point)
        let actualRect = CGRect(x: point.x,
                                y: point.y,
                                width: rect.width + abs(point.x),
                                height: rect.height + abs(point.x))

        XCTAssertEqual(expectedRect, actualRect)
    }

    func testImageConversion() {
        guard let original = UIImage(named: "green-star", in: .mapboxMapsTests, compatibleWith: nil) else {
            XCTFail("Could not load test image from bundle")
            return
        }

        guard let mbxImage = Image(uiImage: original) else {
            XCTFail("Could generate Image (\"MBXImage\") from UIImage")
            return
        }

        guard let roundtripped = UIImage(mbxImage: mbxImage) else {
            XCTFail("Could generate UIImage from Image (\"MBXImage\")")
            return
        }

         XCTAssertEqual(original.size, roundtripped.size)
         // TODO: Fix roundtrip image inconsistency - there's a small
         // amount of byte difference that can't be accounted for.
         // XCTAssertEqual(original.pngData(), roundtripped.pngData())
    }
}
