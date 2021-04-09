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
        let mapInitOptions = MapInitOptions(resourceOptions: ResourceOptions(accessToken: "a1b2c3"),
                                            mapOptions: MapOptions.default)

        mapView = BaseMapView(frame: CGRect(x: 10, y: 10, width: 100, height: 100),
                              mapInitOptions: mapInitOptions,
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

    // MARK: Converting between points and coordinates

    func testCoordinateToPoint() {
        let centerCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let convertedPoint = mapView.point(for: centerCoordinate, in: mapView)

        XCTAssertEqual(convertedPoint.x, mapView.bounds.midX, accuracy: 0.01)
        XCTAssertEqual(convertedPoint.y, mapView.bounds.midY, accuracy: 0.01)
    }

    func testPointToCoordinateInSubviewWithEqualCenter() {
        let subView = UIView(frame: mapView.bounds)
        mapView.addSubview(subView)

        // Convert the subview's center to a coordinate.
        // The subview's center is expected to be at the center coordinate of the map.
        let center = CGPoint(x: subView.bounds.midX, y: subView.bounds.midY)
        let coordinate = mapView.coordinate(for: center, in: subView)

        XCTAssertEqual(coordinate.latitude, CLLocationDegrees(0), accuracy: accuracy)
        XCTAssertEqual(coordinate.longitude, CLLocationDegrees(0), accuracy: accuracy)
    }

    func testPointToCoordinateInSubViewEqualOrigins() {
        let subViewRect = CGRect(x: 0,
                                 y: 0,
                                 width: mapView.bounds.size.width / 2,
                                 height: mapView.bounds.size.height / 2)
        let subview = UIView(frame: subViewRect)

        mapView.addSubview(subview)

        /**
         We shouldn't expect the centers to be the same, since now that the
         mapView is offset. The "center" is in the space of the parent view.
         */
        subview.center = CGPoint(x: mapView.bounds.midX, y: mapView.bounds.midY)
        XCTAssertNotEqual(subview.center, mapView.center, "Center of both views are not equal")
        XCTAssertEqual(subview.frame.origin.x, 25.0)
        XCTAssertEqual(subview.frame.origin.y, 25.0)

        let updatedSubViewOrigin = subview.frame.origin
        let originCoordinateA = mapView.coordinate(for: updatedSubViewOrigin, in: mapView)
        let originCoordinateB = mapView.coordinate(for: CGPoint.zero, in: subview)

        XCTAssertEqual(originCoordinateA.latitude, originCoordinateB.latitude, accuracy: accuracy)
        XCTAssertEqual(originCoordinateA.longitude, originCoordinateB.longitude, accuracy: accuracy)

        // The subview's origin is expected to be 1/4 of the map view's height and width
//        let expectedSubViewOrigin = CGPoint(x: mapView.bounds.width * 0.25, y: mapView.bounds.height * 0.25)
//        let convertedSubViewOrigin = mapView.convert(expectedSubViewOrigin, to: subview)
//        // So this should be zero
//        XCTAssertEqual(convertedSubViewOrigin, .zero)
//
//        let originCoordinateC = mapView.convert(convertedSubViewOrigin, toCoordinateFrom: subview)
//
//        XCTAssertEqual(originCoordinateB.latitude, originCoordinateC.latitude, accuracy: accuracy)
//        XCTAssertEqual(originCoordinateB.longitude, originCoordinateC.longitude, accuracy: accuracy)
//
//        XCTAssertEqual(originCoordinateA.latitude, originCoordinateC.latitude, accuracy: accuracy)
//        XCTAssertEqual(originCoordinateA.longitude, originCoordinateC.longitude, accuracy: accuracy)
    }

    func testPointToCoordinateWithBoundsShifted() {
        // Shift bounds down and right 1/2 of the map's size
        mapView.bounds = CGRect(x: mapView.frame.midX,
                                y: mapView.frame.midY,
                                width: mapView.frame.width,
                                height: mapView.frame.height)

        let mapViewFrameCenterPoint = CGPoint(x: mapView.frame.midX, y: mapView.frame.midY)
        let mapViewFrameCenterCoordinate = mapView.coordinate(for: mapViewFrameCenterPoint, in: mapView)
        let mapViewBoundsOriginCoordinate = mapView.coordinate(for: mapView.bounds.origin, in: mapView)

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
        let originalMapViewBoundsCenterCoordinate = mapView.coordinate(for: originalMapViewBoundsCenterPoint,
                                                                       in: mapView)

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

        let mapViewBoundsCenterCoordinate = mapView.coordinate(for: mapViewBoundsCenterPoint, in: mapView)

        // Adjusting the bounds should affect the coordinate conversion
        XCTAssertNotEqual(originalMapViewBoundsCenterCoordinate.latitude, mapViewBoundsCenterCoordinate.latitude)
        XCTAssertNotEqual(originalMapViewBoundsCenterCoordinate.longitude, mapViewBoundsCenterCoordinate.longitude)
    }

    func testConvertCoordinateRoundTrip() {
        // Convert a point to a coordinate and back to a point
        let originalPoint = CGPoint(x: mapView.frame.midX, y: mapView.frame.midY)

        let coordinate = mapView.coordinate(for: originalPoint, in: mapView)
        let point = mapView.point(for: coordinate, in: mapView)

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

        let rect = mapView.rect(for: bounds, in: mapView)

        // Test southwest points
        let swPoint = mapView.point(for: southwest, in: mapView)
        let swRect = CGPoint(x: rect.minX, y: rect.maxY)

        XCTAssertEqual(swPoint.x, swRect.x, accuracy: 0.1)
        XCTAssertEqual(swPoint.y, swRect.y, accuracy: 0.1)

        // Test southeast points
        let sePoint = mapView.point(for: southeast, in: mapView)
        let seRect = CGPoint(x: rect.maxX, y: rect.maxY)

        XCTAssertEqual(sePoint.x, seRect.x, accuracy: 0.1)
        XCTAssertEqual(sePoint.y, seRect.y, accuracy: 0.1)

        // Test northwest points
        let nwPoint = mapView.point(for: northwest, in: mapView)
        let nwRect = CGPoint(x: rect.minX, y: rect.minY)
        XCTAssertEqual(nwPoint.x, nwRect.x, accuracy: 0.1)
        XCTAssertEqual(nwPoint.y, nwRect.y, accuracy: 0.1)

        // Test northeast points
        let nePoint = mapView.point(for: northeast, in: mapView)
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
}
