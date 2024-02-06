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
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
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
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.fillColor =  StyleColor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(fillColor) = layerProperties["fill-color"] else {
            return XCTFail("Layer property fill-color should be set to a string.")
        }
        XCTAssertEqual(fillColor, annotation.fillColor.flatMap { $0.rawValue })
    }

    func testFillOpacity() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
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
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.fillOutlineColor =  StyleColor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(fillOutlineColor) = layerProperties["fill-outline-color"] else {
            return XCTFail("Layer property fill-outline-color should be set to a string.")
        }
        XCTAssertEqual(fillOutlineColor, annotation.fillOutlineColor.flatMap { $0.rawValue })
    }

    func testFillPattern() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
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

    @available(*, deprecated)
    func testUserInfo() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        let userInfo = ["foo": "bar"]
        annotation.userInfo = userInfo

        let featureProperties = try XCTUnwrap(annotation.feature.properties)
        let actualUserInfo = try XCTUnwrap(featureProperties["userInfo"]??.rawValue as? [String: Any])
        XCTAssertEqual(actualUserInfo["foo"] as? String, userInfo["foo"])
    }

    @available(*, deprecated)
    func testUserInfoNilWhenNonJSONObjectPassed() throws {
        struct NonJSON: Equatable {}
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.userInfo = ["foo": NonJSON()]

        let featureProperties = try XCTUnwrap(annotation.feature.properties)
        let actualUserInfo = try XCTUnwrap(featureProperties["userInfo"]??.rawValue as? [String: Any])
        XCTAssertNil(actualUserInfo["foo"] as? NonJSON)
    }

    @available(*, deprecated)
    func testCustomData() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        let customData: JSONObject = ["foo": .string("bar")]
        annotation.customData = customData

        let actualCustomData = try XCTUnwrap(annotation.feature.properties?["custom_data"])
        XCTAssertEqual(actualCustomData, .object(customData))
    }
}

// End of generated file
