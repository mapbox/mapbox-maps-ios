// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class PolylineAnnotationTests: XCTestCase {

    func testLineElevationGroundScaleTransition() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.lineElevationGroundScaleTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(lineElevationGroundScaleTransition) = layerProperties["line-elevation-ground-scale-transition"],
              case let .number(duration) = lineElevationGroundScaleTransition["duration"],
              case let .number(delay) = lineElevationGroundScaleTransition["delay"]
        else {
            return XCTFail("Layer property line-elevation-ground-scale-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.lineElevationGroundScaleTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.lineElevationGroundScaleTransition?.delay)
    }

    func testLineElevationGroundScale() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.lineElevationGroundScale =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(lineElevationGroundScale) = layerProperties["line-elevation-ground-scale"] else {
            return XCTFail("Layer property line-elevation-ground-scale should be set to a number.")
        }
        XCTAssertEqual(lineElevationGroundScale, annotation.lineElevationGroundScale)
    }

    func testLineJoin() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
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
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
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

    func testLineZOffset() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.lineZOffset =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(lineZOffset) = layerProperties["line-z-offset"] else {
            return XCTFail("Layer property line-z-offset should be set to a number.")
        }
        XCTAssertEqual(lineZOffset, annotation.lineZOffset)
    }

    func testLineBlurTransition() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.lineBlurTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(lineBlurTransition) = layerProperties["line-blur-transition"],
              case let .number(duration) = lineBlurTransition["duration"],
              case let .number(delay) = lineBlurTransition["delay"]
        else {
            return XCTFail("Layer property line-blur-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.lineBlurTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.lineBlurTransition?.delay)
    }

    func testLineBlur() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
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

    func testLineBorderColorUseTheme() {
      let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
      annotation.lineBorderColorUseTheme = .default

      guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
          return
      }
      guard case let .object(layerProperties) = featureProperties["layerProperties"],
            case let .string(lineBorderColorUseTheme) = layerProperties["line-border-color-use-theme"] else {
          return XCTFail("Layer property line-border-color-use-theme should be set to a string.")
      }

      XCTAssertEqual(lineBorderColorUseTheme, annotation.lineBorderColorUseTheme?.rawValue)
    }
    func testLineBorderColorTransition() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.lineBorderColorTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(lineBorderColorTransition) = layerProperties["line-border-color-transition"],
              case let .number(duration) = lineBorderColorTransition["duration"],
              case let .number(delay) = lineBorderColorTransition["delay"]
        else {
            return XCTFail("Layer property line-border-color-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.lineBorderColorTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.lineBorderColorTransition?.delay)
    }

    func testLineBorderColor() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.lineBorderColor =  StyleColor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(lineBorderColor) = layerProperties["line-border-color"] else {
            return XCTFail("Layer property line-border-color should be set to a string.")
        }
        XCTAssertEqual(lineBorderColor, annotation.lineBorderColor.flatMap { $0.rawValue })
    }

    func testLineBorderWidthTransition() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.lineBorderWidthTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(lineBorderWidthTransition) = layerProperties["line-border-width-transition"],
              case let .number(duration) = lineBorderWidthTransition["duration"],
              case let .number(delay) = lineBorderWidthTransition["delay"]
        else {
            return XCTFail("Layer property line-border-width-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.lineBorderWidthTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.lineBorderWidthTransition?.delay)
    }

    func testLineBorderWidth() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.lineBorderWidth =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(lineBorderWidth) = layerProperties["line-border-width"] else {
            return XCTFail("Layer property line-border-width should be set to a number.")
        }
        XCTAssertEqual(lineBorderWidth, annotation.lineBorderWidth)
    }

    func testLineColorUseTheme() {
      let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
      annotation.lineColorUseTheme = .default

      guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
          return
      }
      guard case let .object(layerProperties) = featureProperties["layerProperties"],
            case let .string(lineColorUseTheme) = layerProperties["line-color-use-theme"] else {
          return XCTFail("Layer property line-color-use-theme should be set to a string.")
      }

      XCTAssertEqual(lineColorUseTheme, annotation.lineColorUseTheme?.rawValue)
    }
    func testLineColorTransition() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.lineColorTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(lineColorTransition) = layerProperties["line-color-transition"],
              case let .number(duration) = lineColorTransition["duration"],
              case let .number(delay) = lineColorTransition["delay"]
        else {
            return XCTFail("Layer property line-color-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.lineColorTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.lineColorTransition?.delay)
    }

    func testLineColor() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.lineColor =  StyleColor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(lineColor) = layerProperties["line-color"] else {
            return XCTFail("Layer property line-color should be set to a string.")
        }
        XCTAssertEqual(lineColor, annotation.lineColor.flatMap { $0.rawValue })
    }

    func testLineEmissiveStrengthTransition() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.lineEmissiveStrengthTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(lineEmissiveStrengthTransition) = layerProperties["line-emissive-strength-transition"],
              case let .number(duration) = lineEmissiveStrengthTransition["duration"],
              case let .number(delay) = lineEmissiveStrengthTransition["delay"]
        else {
            return XCTFail("Layer property line-emissive-strength-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.lineEmissiveStrengthTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.lineEmissiveStrengthTransition?.delay)
    }

    func testLineEmissiveStrength() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.lineEmissiveStrength =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(lineEmissiveStrength) = layerProperties["line-emissive-strength"] else {
            return XCTFail("Layer property line-emissive-strength should be set to a number.")
        }
        XCTAssertEqual(lineEmissiveStrength, annotation.lineEmissiveStrength)
    }

    func testLineGapWidthTransition() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.lineGapWidthTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(lineGapWidthTransition) = layerProperties["line-gap-width-transition"],
              case let .number(duration) = lineGapWidthTransition["duration"],
              case let .number(delay) = lineGapWidthTransition["delay"]
        else {
            return XCTFail("Layer property line-gap-width-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.lineGapWidthTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.lineGapWidthTransition?.delay)
    }

    func testLineGapWidth() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
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

    func testLineOffsetTransition() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.lineOffsetTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(lineOffsetTransition) = layerProperties["line-offset-transition"],
              case let .number(duration) = lineOffsetTransition["duration"],
              case let .number(delay) = lineOffsetTransition["delay"]
        else {
            return XCTFail("Layer property line-offset-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.lineOffsetTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.lineOffsetTransition?.delay)
    }

    func testLineOffset() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
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

    func testLineOpacityTransition() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.lineOpacityTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(lineOpacityTransition) = layerProperties["line-opacity-transition"],
              case let .number(duration) = lineOpacityTransition["duration"],
              case let .number(delay) = lineOpacityTransition["delay"]
        else {
            return XCTFail("Layer property line-opacity-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.lineOpacityTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.lineOpacityTransition?.delay)
    }

    func testLineOpacity() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
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
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
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

    func testLineWidthTransition() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.lineWidthTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(lineWidthTransition) = layerProperties["line-width-transition"],
              case let .number(duration) = lineWidthTransition["duration"],
              case let .number(delay) = lineWidthTransition["delay"]
        else {
            return XCTFail("Layer property line-width-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.lineWidthTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.lineWidthTransition?.delay)
    }

    func testLineWidth() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
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

    @available(*, deprecated)
    func testUserInfo() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        let userInfo = ["foo": "bar"]
        annotation.userInfo = userInfo

        let featureProperties = try XCTUnwrap(annotation.feature.properties)
        let actualUserInfo = try XCTUnwrap(featureProperties["userInfo"]??.rawValue as? [String: Any])
        XCTAssertEqual(actualUserInfo["foo"] as? String, userInfo["foo"])
    }

    @available(*, deprecated)
    func testUserInfoNilWhenNonJSONObjectPassed() throws {
        struct NonJSON: Equatable {}
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.userInfo = ["foo": NonJSON()]

        let featureProperties = try XCTUnwrap(annotation.feature.properties)
        let actualUserInfo = try XCTUnwrap(featureProperties["userInfo"]??.rawValue as? [String: Any])
        XCTAssertNil(actualUserInfo["foo"] as? NonJSON)
    }

    @available(*, deprecated)
    func testCustomData() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        let customData: JSONObject = ["foo": .string("bar")]
        annotation.customData = customData

        let actualCustomData = try XCTUnwrap(annotation.feature.properties?["custom_data"])
        XCTAssertEqual(actualCustomData, .object(customData))
    }
}

// End of generated file
