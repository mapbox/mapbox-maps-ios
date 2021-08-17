// swiftlint:disable all
// This file is generated
import XCTest
import Turf
@testable import MapboxMaps

final class CircleAnnotationTests: XCTestCase {

    func testCircleSortKey() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.circleSortKey =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["circle-sort-key"] as? Double, annotation.circleSortKey)
    }

    func testCircleBlur() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.circleBlur =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["circle-blur"] as? Double, annotation.circleBlur)
    }

    func testCircleColor() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.circleColor =  ColorRepresentable.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["circle-color"] as? String, annotation.circleColor.flatMap { try? $0.jsonString() })
    }

    func testCircleOpacity() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.circleOpacity =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["circle-opacity"] as? Double, annotation.circleOpacity)
    }

    func testCircleRadius() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.circleRadius =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["circle-radius"] as? Double, annotation.circleRadius)
    }

    func testCircleStrokeColor() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.circleStrokeColor =  ColorRepresentable.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["circle-stroke-color"] as? String, annotation.circleStrokeColor.flatMap { try? $0.jsonString() })
    }

    func testCircleStrokeOpacity() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.circleStrokeOpacity =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["circle-stroke-opacity"] as? Double, annotation.circleStrokeOpacity)
    }

    func testCircleStrokeWidth() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.circleStrokeWidth =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["circle-stroke-width"] as? Double, annotation.circleStrokeWidth)
    }
}

// End of generated file
// swiftlint:enable all
