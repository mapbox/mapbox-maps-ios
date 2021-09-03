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
        XCTAssertEqual((featureProperties["layerProperties"] as! [String: Any])["fill-sort-key"] as? Double, annotation.fillSortKey)
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
        XCTAssertEqual((featureProperties["layerProperties"] as! [String: Any])["fill-color"] as? String, annotation.fillColor.flatMap { $0.rgbaString })
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
        XCTAssertEqual((featureProperties["layerProperties"] as! [String: Any])["fill-opacity"] as? Double, annotation.fillOpacity)
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
        XCTAssertEqual((featureProperties["layerProperties"] as! [String: Any])["fill-outline-color"] as? String, annotation.fillOutlineColor.flatMap { $0.rgbaString })
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
        XCTAssertEqual((featureProperties["layerProperties"] as! [String: Any])["fill-pattern"] as? String, annotation.fillPattern)
    }
}

// End of generated file
