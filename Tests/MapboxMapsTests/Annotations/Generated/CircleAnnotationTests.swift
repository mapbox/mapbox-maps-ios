// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

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

    func testCircleBlurTransition() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.circleBlurTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(circleBlurTransition) = layerProperties["circle-blur-transition"],
              case let .number(duration) = circleBlurTransition["duration"],
              case let .number(delay) = circleBlurTransition["delay"]
        else {
            return XCTFail("Layer property circle-blur-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.circleBlurTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.circleBlurTransition?.delay)
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

    func testCircleColorUseTheme() {
      var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
      annotation.circleColorUseTheme = .default

      guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
          return
      }
      guard case let .object(layerProperties) = featureProperties["layerProperties"],
            case let .string(circleColorUseTheme) = layerProperties["circle-color-use-theme"] else {
          return XCTFail("Layer property circle-color-use-theme should be set to a string.")
      }

      XCTAssertEqual(circleColorUseTheme, annotation.circleColorUseTheme?.rawValue)
    }
    func testCircleColorTransition() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.circleColorTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(circleColorTransition) = layerProperties["circle-color-transition"],
              case let .number(duration) = circleColorTransition["duration"],
              case let .number(delay) = circleColorTransition["delay"]
        else {
            return XCTFail("Layer property circle-color-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.circleColorTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.circleColorTransition?.delay)
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

    func testCircleOpacityTransition() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.circleOpacityTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(circleOpacityTransition) = layerProperties["circle-opacity-transition"],
              case let .number(duration) = circleOpacityTransition["duration"],
              case let .number(delay) = circleOpacityTransition["delay"]
        else {
            return XCTFail("Layer property circle-opacity-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.circleOpacityTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.circleOpacityTransition?.delay)
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

    func testCircleRadiusTransition() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.circleRadiusTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(circleRadiusTransition) = layerProperties["circle-radius-transition"],
              case let .number(duration) = circleRadiusTransition["duration"],
              case let .number(delay) = circleRadiusTransition["delay"]
        else {
            return XCTFail("Layer property circle-radius-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.circleRadiusTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.circleRadiusTransition?.delay)
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

    func testCircleStrokeColorUseTheme() {
      var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
      annotation.circleStrokeColorUseTheme = .default

      guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
          return
      }
      guard case let .object(layerProperties) = featureProperties["layerProperties"],
            case let .string(circleStrokeColorUseTheme) = layerProperties["circle-stroke-color-use-theme"] else {
          return XCTFail("Layer property circle-stroke-color-use-theme should be set to a string.")
      }

      XCTAssertEqual(circleStrokeColorUseTheme, annotation.circleStrokeColorUseTheme?.rawValue)
    }
    func testCircleStrokeColorTransition() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.circleStrokeColorTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(circleStrokeColorTransition) = layerProperties["circle-stroke-color-transition"],
              case let .number(duration) = circleStrokeColorTransition["duration"],
              case let .number(delay) = circleStrokeColorTransition["delay"]
        else {
            return XCTFail("Layer property circle-stroke-color-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.circleStrokeColorTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.circleStrokeColorTransition?.delay)
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

    func testCircleStrokeOpacityTransition() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.circleStrokeOpacityTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(circleStrokeOpacityTransition) = layerProperties["circle-stroke-opacity-transition"],
              case let .number(duration) = circleStrokeOpacityTransition["duration"],
              case let .number(delay) = circleStrokeOpacityTransition["delay"]
        else {
            return XCTFail("Layer property circle-stroke-opacity-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.circleStrokeOpacityTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.circleStrokeOpacityTransition?.delay)
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

    func testCircleStrokeWidthTransition() {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.circleStrokeWidthTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(circleStrokeWidthTransition) = layerProperties["circle-stroke-width-transition"],
              case let .number(duration) = circleStrokeWidthTransition["duration"],
              case let .number(delay) = circleStrokeWidthTransition["delay"]
        else {
            return XCTFail("Layer property circle-stroke-width-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.circleStrokeWidthTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.circleStrokeWidthTransition?.delay)
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
