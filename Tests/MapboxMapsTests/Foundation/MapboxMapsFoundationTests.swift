import XCTest
import CoreLocation
import UIKit
@testable import MapboxMaps

// swiftlint:disable explicit_top_level_acl explicit_acl
class MapboxMapsFoundationTests: XCTestCase {

    var mapView: MapView!

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
        let mapInitOptions = MapInitOptions(resourceOptions: ResourceOptions(accessToken: "a1b2c3"),
                                            styleURI: nil)

        mapView = MapView(frame: CGRect(x: 10, y: 10, width: 100, height: 100),
                              mapInitOptions: mapInitOptions)
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

    // MARK: Converting between points and coordinates

    func testCoordinateToPoint() {
        let centerCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let convertedPoint = mapView.mapboxMap.point(for: centerCoordinate)

        XCTAssertEqual(convertedPoint.x, mapView.bounds.midX, accuracy: 0.01)
        XCTAssertEqual(convertedPoint.y, mapView.bounds.midY, accuracy: 0.01)
    }

    func testPointToCoordinateInSubviewWithEqualCenter() {
        let subView = UIView(frame: mapView.bounds)
        mapView.addSubview(subView)

        // Convert the subview's center to a coordinate.
        // The subview's center is expected to be at the center coordinate of the map.
        let center = CGPoint(x: subView.bounds.midX, y: subView.bounds.midY)
        let coordinate = mapView.mapboxMap.coordinate(for: center)

        XCTAssertEqual(coordinate.latitude, CLLocationDegrees(0), accuracy: accuracy)
        XCTAssertEqual(coordinate.longitude, CLLocationDegrees(0), accuracy: accuracy)
    }

    func testPointToCoordinateWithBoundsShifted() {
        // Shift bounds down and right 1/2 of the map's size
        mapView.bounds = CGRect(x: mapView.frame.midX,
                                y: mapView.frame.midY,
                                width: mapView.frame.width,
                                height: mapView.frame.height)

        let mapViewFrameCenterPoint = CGPoint(x: mapView.frame.midX, y: mapView.frame.midY)
        let mapViewFrameCenterCoordinate = mapView.mapboxMap.coordinate(for: mapViewFrameCenterPoint)
        let mapViewBoundsOriginCoordinate = mapView.mapboxMap.coordinate(for: mapView.bounds.origin)

        XCTAssertEqual(mapViewFrameCenterCoordinate.latitude,
                       mapViewBoundsOriginCoordinate.latitude,
                       accuracy: accuracy)
        XCTAssertEqual(mapViewFrameCenterCoordinate.longitude,
                       mapViewBoundsOriginCoordinate.longitude,
                       accuracy: accuracy)
    }

    func testPointToCoordinateWithBoundsShifted2() {
        let originalCenter = mapView.center
        let originalMapViewBoundsCenterPoint = CGPoint(x: mapView.bounds.midX, y: mapView.bounds.midY)
        let originalMapViewBoundsCenterCoordinate = mapView.mapboxMap.coordinate(for: originalMapViewBoundsCenterPoint)

        // Shift bounds by some arbitrary offset
        mapView.bounds = CGRect(x: 30,
                                y: -30,
                                width: mapView.frame.width,
                                height: mapView.frame.height)

        let mapViewFrameCenterPoint = CGPoint(x: mapView.frame.midX, y: mapView.frame.midY)
        let mapViewBoundsCenterPoint = CGPoint(x: mapView.bounds.midX, y: mapView.bounds.midY)

        // Frame should not have changed, since we're only changing the bounds
        XCTAssertEqual(originalCenter, mapView.center)
        XCTAssertEqual(originalCenter, mapViewFrameCenterPoint)

        let mapViewBoundsCenterCoordinate = mapView.mapboxMap.coordinate(for: mapViewBoundsCenterPoint)

        // Adjusting the bounds should affect the coordinate conversion
        XCTAssertNotEqual(originalMapViewBoundsCenterCoordinate.latitude, mapViewBoundsCenterCoordinate.latitude)
        XCTAssertNotEqual(originalMapViewBoundsCenterCoordinate.longitude, mapViewBoundsCenterCoordinate.longitude)
    }

    func testConvertCoordinateRoundTrip() {
        // Convert a point to a coordinate and back to a point
        let originalPoint = CGPoint(x: mapView.frame.midX, y: mapView.frame.midY)

        let coordinate = mapView.mapboxMap.coordinate(for: originalPoint)
        let point = mapView.mapboxMap.point(for: coordinate)

        XCTAssertEqual(originalPoint.x, point.x, accuracy: CGFloat(accuracy))
        XCTAssertEqual(originalPoint.y, point.y, accuracy: CGFloat(accuracy))
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

    func testCoordinateBoundsToRect() {
        let southwest = CLLocationCoordinate2D(latitude: -20, longitude: -20)
        let northeast = CLLocationCoordinate2D(latitude: 20, longitude: 20)

        let bounds = CoordinateBounds(southwest: southwest, northeast: northeast)

        let southeast = bounds.southeast
        let northwest = bounds.northwest

        let rect = mapView.mapboxMap.rect(for: bounds)

        // Test southwest points
        let swPoint = mapView.mapboxMap.point(for: southwest)
        let swRect = CGPoint(x: rect.minX, y: rect.maxY)

        XCTAssertEqual(swPoint.x, swRect.x, accuracy: 0.1)
        XCTAssertEqual(swPoint.y, swRect.y, accuracy: 0.1)

        // Test southeast points
        let sePoint = mapView.mapboxMap.point(for: southeast)
        let seRect = CGPoint(x: rect.maxX, y: rect.maxY)

        XCTAssertEqual(sePoint.x, seRect.x, accuracy: 0.1)
        XCTAssertEqual(sePoint.y, seRect.y, accuracy: 0.1)

        // Test northwest points
        let nwPoint = mapView.mapboxMap.point(for: northwest)
        let nwRect = CGPoint(x: rect.minX, y: rect.minY)
        XCTAssertEqual(nwPoint.x, nwRect.x, accuracy: 0.1)
        XCTAssertEqual(nwPoint.y, nwRect.y, accuracy: 0.1)

        // Test northeast points
        let nePoint = mapView.mapboxMap.point(for: northeast)
        let neRect = CGPoint(x: rect.maxX, y: rect.minY)
        XCTAssertEqual(nePoint.x, neRect.x, accuracy: 0.1)
        XCTAssertEqual(nePoint.y, neRect.y, accuracy: 0.1)
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

// MARK: Debug options
    func testDebugOptions() {
        let initialOptions = mapView.mapboxMap.debugOptions
        XCTAssertEqual(initialOptions, [], "The initial debug options should be an empty array.")

        let setOptions1: [MapDebugOptions] = [.tileBorders, .timestamps]
        mapView.mapboxMap.debugOptions = setOptions1
        let getOptions1 =  mapView.mapboxMap.debugOptions
        XCTAssertEqual(setOptions1, getOptions1, "Tile borders and timestamp should be enabled.")

        let setOptions2: [MapDebugOptions] = [.tileBorders]
        mapView.mapboxMap.debugOptions = setOptions2
        let getOptions2 = mapView.mapboxMap.debugOptions
        XCTAssertEqual(setOptions2, getOptions2, "Tile borders should be enabled.")

        mapView.mapboxMap.debugOptions = []
        let getOptions3 = mapView.mapboxMap.debugOptions
        XCTAssert(getOptions3.isEmpty, "The array of debug options should be empty.")
    }
}
