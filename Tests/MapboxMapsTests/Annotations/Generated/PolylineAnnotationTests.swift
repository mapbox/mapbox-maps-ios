// This file is generated
import XCTest
@testable import MapboxMaps

final class PolylineAnnotationTests: XCTestCase {

    func testLineJoin() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        annotation.lineJoin =  LineJoin.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(lineJoin) = layerProperties["line-join"] else {
            return XCTFail("Layer property line-join should be set to a string.")
        }
        XCTAssertEqual(lineJoin, annotation.lineJoin?.rawValue)
    }

    func testLineSortKey() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        annotation.lineSortKey =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(lineSortKey) = layerProperties["line-sort-key"] else {
            return XCTFail("Layer property line-sort-key should be set to a number.")
        }
        XCTAssertEqual(lineSortKey, annotation.lineSortKey)
    }

    func testLineBlur() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        annotation.lineBlur =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(lineBlur) = layerProperties["line-blur"] else {
            return XCTFail("Layer property line-blur should be set to a number.")
        }
        XCTAssertEqual(lineBlur, annotation.lineBlur)
    }

    func testLineColor() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        annotation.lineColor =  StyleColor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(lineColor) = layerProperties["line-color"] else {
            return XCTFail("Layer property line-color should be set to a string.")
        }
        XCTAssertEqual(lineColor, annotation.lineColor.flatMap { $0.rgbaString })
    }

    func testLineGapWidth() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        annotation.lineGapWidth =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(lineGapWidth) = layerProperties["line-gap-width"] else {
            return XCTFail("Layer property line-gap-width should be set to a number.")
        }
        XCTAssertEqual(lineGapWidth, annotation.lineGapWidth)
    }

    func testLineOffset() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        annotation.lineOffset =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(lineOffset) = layerProperties["line-offset"] else {
            return XCTFail("Layer property line-offset should be set to a number.")
        }
        XCTAssertEqual(lineOffset, annotation.lineOffset)
    }

    func testLineOpacity() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        annotation.lineOpacity =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(lineOpacity) = layerProperties["line-opacity"] else {
            return XCTFail("Layer property line-opacity should be set to a number.")
        }
        XCTAssertEqual(lineOpacity, annotation.lineOpacity)
    }

    func testLinePattern() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        annotation.linePattern =  String.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(linePattern) = layerProperties["line-pattern"] else {
            return XCTFail("Layer property line-pattern should be set to a string.")
        }
        XCTAssertEqual(linePattern, annotation.linePattern)
    }

    func testLineWidth() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        annotation.lineWidth =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(lineWidth) = layerProperties["line-width"] else {
            return XCTFail("Layer property line-width should be set to a number.")
        }
        XCTAssertEqual(lineWidth, annotation.lineWidth)
    }

    func testOffsetGeometry() {
        let mapInitOptions = MapInitOptions()
        let mapView = MapView(frame: UIScreen.main.bounds, mapInitOptions: mapInitOptions)
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        guard let lineStringCoordinates = annotation.lineString.coordinates.first else { return }
        let point = CGPoint(x: lineStringCoordinates.longitude, y: lineStringCoordinates.latitude)

         // offsetGeometry return value is nil
         let offsetGeometryNilDistance = annotation.getOffsetGeometry(mapView.mapboxMap, moveDistancesObject: nil)
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

         let offsetGeometry = annotation.getOffsetGeometry(mapView.mapboxMap, moveDistancesObject: moveObject)
         XCTAssertNotNil(offsetGeometry)
     }
  }

// End of generated file
