// This file is generated
import XCTest
@testable import MapboxMaps

final class CircleAnnotationTests: XCTestCase {

    func testCircleSortKey() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.circleSortKey =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(circleSortKey) = layerProperties["circle-sort-key"] else {
            return XCTFail("Layer property circle-sort-key should be set to a number.")
        }
        XCTAssertEqual(circleSortKey, annotation.circleSortKey)
    }

    func testCircleBlur() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.circleBlur =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(circleBlur) = layerProperties["circle-blur"] else {
            return XCTFail("Layer property circle-blur should be set to a number.")
        }
        XCTAssertEqual(circleBlur, annotation.circleBlur)
    }

    func testCircleColor() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.circleColor =  StyleColor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(circleColor) = layerProperties["circle-color"] else {
            return XCTFail("Layer property circle-color should be set to a string.")
        }
        XCTAssertEqual(circleColor, annotation.circleColor.flatMap { $0.rawValue })
    }

    func testCircleOpacity() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.circleOpacity =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(circleOpacity) = layerProperties["circle-opacity"] else {
            return XCTFail("Layer property circle-opacity should be set to a number.")
        }
        XCTAssertEqual(circleOpacity, annotation.circleOpacity)
    }

    func testCircleRadius() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.circleRadius =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(circleRadius) = layerProperties["circle-radius"] else {
            return XCTFail("Layer property circle-radius should be set to a number.")
        }
        XCTAssertEqual(circleRadius, annotation.circleRadius)
    }

    func testCircleStrokeColor() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.circleStrokeColor =  StyleColor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(circleStrokeColor) = layerProperties["circle-stroke-color"] else {
            return XCTFail("Layer property circle-stroke-color should be set to a string.")
        }
        XCTAssertEqual(circleStrokeColor, annotation.circleStrokeColor.flatMap { $0.rawValue })
    }

    func testCircleStrokeOpacity() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.circleStrokeOpacity =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(circleStrokeOpacity) = layerProperties["circle-stroke-opacity"] else {
            return XCTFail("Layer property circle-stroke-opacity should be set to a number.")
        }
        XCTAssertEqual(circleStrokeOpacity, annotation.circleStrokeOpacity)
    }

    func testCircleStrokeWidth() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.circleStrokeWidth =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(circleStrokeWidth) = layerProperties["circle-stroke-width"] else {
            return XCTFail("Layer property circle-stroke-width should be set to a number.")
        }
        XCTAssertEqual(circleStrokeWidth, annotation.circleStrokeWidth)
    }

    @available(*, deprecated)
    func testUserInfo() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        let userInfo = ["foo": "bar"]
        annotation.userInfo = userInfo

        let featureProperties = try XCTUnwrap(annotation.feature.properties)
        let actualUserInfo = try XCTUnwrap(featureProperties["userInfo"]??.rawValue as? [String: Any])
        XCTAssertEqual(actualUserInfo["foo"] as? String, userInfo["foo"])
    }

    @available(*, deprecated)
    func testUserInfoNilWhenNonJSONObjectPassed() throws {
        struct NonJSON: Equatable {}
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.userInfo = ["foo": NonJSON()]

        let featureProperties = try XCTUnwrap(annotation.feature.properties)
        let actualUserInfo = try XCTUnwrap(featureProperties["userInfo"]??.rawValue as? [String: Any])
        XCTAssertNil(actualUserInfo["foo"] as? NonJSON)
    }

    @available(*, deprecated)
    func testCustomData() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        let customData: JSONObject = ["foo": .string("bar")]
        annotation.customData = customData

        let actualCustomData = try XCTUnwrap(annotation.feature.properties?["custom_data"])
        XCTAssertEqual(actualCustomData, .object(customData))
    }
}

// End of generated file
