// This file is generated
import XCTest
@testable import MapboxMaps

final class PolygonAnnotationTests: XCTestCase {

    func testFillSortKey() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
        annotation.fillSortKey =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(fillSortKey) = layerProperties["fill-sort-key"] else {
            return XCTFail("Layer property fill-sort-key should be set to a number.")
        }
        XCTAssertEqual(fillSortKey, annotation.fillSortKey)
    }

    func testFillColor() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
        annotation.fillColor =  StyleColor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(fillColor) = layerProperties["fill-color"] else {
            return XCTFail("Layer property fill-color should be set to a string.")
        }
        XCTAssertEqual(fillColor, annotation.fillColor.flatMap { $0.rgbaString })
    }

    func testFillOpacity() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
        annotation.fillOpacity =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(fillOpacity) = layerProperties["fill-opacity"] else {
            return XCTFail("Layer property fill-opacity should be set to a number.")
        }
        XCTAssertEqual(fillOpacity, annotation.fillOpacity)
    }

    func testFillOutlineColor() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
        annotation.fillOutlineColor =  StyleColor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(fillOutlineColor) = layerProperties["fill-outline-color"] else {
            return XCTFail("Layer property fill-outline-color should be set to a string.")
        }
        XCTAssertEqual(fillOutlineColor, annotation.fillOutlineColor.flatMap { $0.rgbaString })
    }

    func testFillPattern() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
        annotation.fillPattern =  String.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(fillPattern) = layerProperties["fill-pattern"] else {
            return XCTFail("Layer property fill-pattern should be set to a string.")
        }
        XCTAssertEqual(fillPattern, annotation.fillPattern)
    }

    func testOffsetGeometry() {
        let mapInitOptions = MapInitOptions()
        let mapView = MapView(frame: UIScreen.main.bounds, mapInitOptions: mapInitOptions)
         let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
         ]
         var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
         guard let polygonCoordinates = annotation.polygon.outerRing.coordinates.first else { return }
         let point = CGPoint(x: annotation.polygon.outerRing.coordinates.first?.longitude, y: annotation.polygon.outerRing.coordinates.first?.latitude)

         // offsetGeometry return value is nil
         let offsetGeometryNilDistance = annotation.getOffsetGeometry(mapboxMap: mapView.mapboxMap, moveDistancesObject: nil)
         XCTAssertNil(offsetGeometryNilDistance)

         // offsetGeometry return value is not nil
         let moveObject = MoveDistancesObject()
         moveObject.currentX = CGFloat.random(in: 0...100)
         moveObject.currentY = CGFloat.random(in: 0...100)
         moveObject.prevX = point.x
         moveObject.prevY = point.y
         moveObject.distanceXSinceLast = moveObject.prevX - moveObject.currentX
         moveObject.distanceYSinceLast = moveObject.prevY - moveObject.currentY
         XCTAssertNotNil(moveObject)

         let offsetGeometry = annotation.getOffsetGeometry(mapboxMap: mapView.mapboxMap, moveDistancesObject: moveObject)
         XCTAssertNotNil(offsetGeometry)
     }
  }

// End of generated file
