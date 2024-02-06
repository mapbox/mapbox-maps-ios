// This file is generated
import XCTest
@testable import MapboxMaps

final class PointAnnotationTests: XCTestCase {

    func testIconAnchor() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconAnchor =  IconAnchor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(iconAnchor) = layerProperties["icon-anchor"] else {
            return XCTFail("Layer property icon-anchor should be set to a string.")
        }
        XCTAssertEqual(iconAnchor, annotation.iconAnchor?.rawValue)
    }

    func testIconImage() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconImage =  String.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(iconImage) = layerProperties["icon-image"] else {
            return XCTFail("Layer property icon-image should be set to a string.")
        }
        XCTAssertEqual(iconImage, annotation.iconImage)
    }

    func testIconOffset() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconOffset =  [Double].testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .array(iconOffset) = layerProperties["icon-offset"] else {
            return XCTFail("Layer property icon-offset should be set to a array of Doubles.")
        }
        XCTAssertEqual(iconOffset.compactMap { $0?.rawValue } as? [Double], annotation.iconOffset)
    }

    func testIconRotate() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconRotate =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(iconRotate) = layerProperties["icon-rotate"] else {
            return XCTFail("Layer property icon-rotate should be set to a number.")
        }
        XCTAssertEqual(iconRotate, annotation.iconRotate)
    }

    func testIconSize() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconSize =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(iconSize) = layerProperties["icon-size"] else {
            return XCTFail("Layer property icon-size should be set to a number.")
        }
        XCTAssertEqual(iconSize, annotation.iconSize)
    }

    func testIconTextFit() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconTextFit =  IconTextFit.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(iconTextFit) = layerProperties["icon-text-fit"] else {
            return XCTFail("Layer property icon-text-fit should be set to a string.")
        }
        XCTAssertEqual(iconTextFit, annotation.iconTextFit?.rawValue)
    }

    func testIconTextFitPadding() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconTextFitPadding =  [Double].testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .array(iconTextFitPadding) = layerProperties["icon-text-fit-padding"] else {
            return XCTFail("Layer property icon-text-fit-padding should be set to a array of Doubles.")
        }
        XCTAssertEqual(iconTextFitPadding.compactMap { $0?.rawValue } as? [Double], annotation.iconTextFitPadding)
    }

    func testSymbolSortKey() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.symbolSortKey =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(symbolSortKey) = layerProperties["symbol-sort-key"] else {
            return XCTFail("Layer property symbol-sort-key should be set to a number.")
        }
        XCTAssertEqual(symbolSortKey, annotation.symbolSortKey)
    }

    func testTextAnchor() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textAnchor =  TextAnchor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(textAnchor) = layerProperties["text-anchor"] else {
            return XCTFail("Layer property text-anchor should be set to a string.")
        }
        XCTAssertEqual(textAnchor, annotation.textAnchor?.rawValue)
    }

    func testTextField() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textField =  String.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(textField) = layerProperties["text-field"] else {
            return XCTFail("Layer property text-field should be set to a string.")
        }
        XCTAssertEqual(textField, annotation.textField)
    }

    func testTextJustify() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textJustify =  TextJustify.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(textJustify) = layerProperties["text-justify"] else {
            return XCTFail("Layer property text-justify should be set to a string.")
        }
        XCTAssertEqual(textJustify, annotation.textJustify?.rawValue)
    }

    func testTextLetterSpacing() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textLetterSpacing =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(textLetterSpacing) = layerProperties["text-letter-spacing"] else {
            return XCTFail("Layer property text-letter-spacing should be set to a number.")
        }
        XCTAssertEqual(textLetterSpacing, annotation.textLetterSpacing)
    }

    func testTextLineHeight() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textLineHeight =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(textLineHeight) = layerProperties["text-line-height"] else {
            return XCTFail("Layer property text-line-height should be set to a number.")
        }
        XCTAssertEqual(textLineHeight, annotation.textLineHeight)
    }

    func testTextMaxWidth() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textMaxWidth =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(textMaxWidth) = layerProperties["text-max-width"] else {
            return XCTFail("Layer property text-max-width should be set to a number.")
        }
        XCTAssertEqual(textMaxWidth, annotation.textMaxWidth)
    }

    func testTextOffset() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textOffset =  [Double].testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .array(textOffset) = layerProperties["text-offset"] else {
            return XCTFail("Layer property text-offset should be set to a array of Doubles.")
        }
        XCTAssertEqual(textOffset.compactMap { $0?.rawValue } as? [Double], annotation.textOffset)
    }

    func testTextRadialOffset() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textRadialOffset =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(textRadialOffset) = layerProperties["text-radial-offset"] else {
            return XCTFail("Layer property text-radial-offset should be set to a number.")
        }
        XCTAssertEqual(textRadialOffset, annotation.textRadialOffset)
    }

    func testTextRotate() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textRotate =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(textRotate) = layerProperties["text-rotate"] else {
            return XCTFail("Layer property text-rotate should be set to a number.")
        }
        XCTAssertEqual(textRotate, annotation.textRotate)
    }

    func testTextSize() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textSize =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(textSize) = layerProperties["text-size"] else {
            return XCTFail("Layer property text-size should be set to a number.")
        }
        XCTAssertEqual(textSize, annotation.textSize)
    }

    func testTextTransform() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textTransform =  TextTransform.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(textTransform) = layerProperties["text-transform"] else {
            return XCTFail("Layer property text-transform should be set to a string.")
        }
        XCTAssertEqual(textTransform, annotation.textTransform?.rawValue)
    }

    func testIconColor() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconColor =  StyleColor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(iconColor) = layerProperties["icon-color"] else {
            return XCTFail("Layer property icon-color should be set to a string.")
        }
        XCTAssertEqual(iconColor, annotation.iconColor.flatMap { $0.rawValue })
    }

    func testIconEmissiveStrength() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconEmissiveStrength =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(iconEmissiveStrength) = layerProperties["icon-emissive-strength"] else {
            return XCTFail("Layer property icon-emissive-strength should be set to a number.")
        }
        XCTAssertEqual(iconEmissiveStrength, annotation.iconEmissiveStrength)
    }

    func testIconHaloBlur() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconHaloBlur =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(iconHaloBlur) = layerProperties["icon-halo-blur"] else {
            return XCTFail("Layer property icon-halo-blur should be set to a number.")
        }
        XCTAssertEqual(iconHaloBlur, annotation.iconHaloBlur)
    }

    func testIconHaloColor() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconHaloColor =  StyleColor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(iconHaloColor) = layerProperties["icon-halo-color"] else {
            return XCTFail("Layer property icon-halo-color should be set to a string.")
        }
        XCTAssertEqual(iconHaloColor, annotation.iconHaloColor.flatMap { $0.rawValue })
    }

    func testIconHaloWidth() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconHaloWidth =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(iconHaloWidth) = layerProperties["icon-halo-width"] else {
            return XCTFail("Layer property icon-halo-width should be set to a number.")
        }
        XCTAssertEqual(iconHaloWidth, annotation.iconHaloWidth)
    }

    func testIconImageCrossFade() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconImageCrossFade =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(iconImageCrossFade) = layerProperties["icon-image-cross-fade"] else {
            return XCTFail("Layer property icon-image-cross-fade should be set to a number.")
        }
        XCTAssertEqual(iconImageCrossFade, annotation.iconImageCrossFade)
    }

    func testIconOpacity() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconOpacity =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(iconOpacity) = layerProperties["icon-opacity"] else {
            return XCTFail("Layer property icon-opacity should be set to a number.")
        }
        XCTAssertEqual(iconOpacity, annotation.iconOpacity)
    }

    func testTextColor() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textColor =  StyleColor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(textColor) = layerProperties["text-color"] else {
            return XCTFail("Layer property text-color should be set to a string.")
        }
        XCTAssertEqual(textColor, annotation.textColor.flatMap { $0.rawValue })
    }

    func testTextEmissiveStrength() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textEmissiveStrength =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(textEmissiveStrength) = layerProperties["text-emissive-strength"] else {
            return XCTFail("Layer property text-emissive-strength should be set to a number.")
        }
        XCTAssertEqual(textEmissiveStrength, annotation.textEmissiveStrength)
    }

    func testTextHaloBlur() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textHaloBlur =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(textHaloBlur) = layerProperties["text-halo-blur"] else {
            return XCTFail("Layer property text-halo-blur should be set to a number.")
        }
        XCTAssertEqual(textHaloBlur, annotation.textHaloBlur)
    }

    func testTextHaloColor() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textHaloColor =  StyleColor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(textHaloColor) = layerProperties["text-halo-color"] else {
            return XCTFail("Layer property text-halo-color should be set to a string.")
        }
        XCTAssertEqual(textHaloColor, annotation.textHaloColor.flatMap { $0.rawValue })
    }

    func testTextHaloWidth() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textHaloWidth =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(textHaloWidth) = layerProperties["text-halo-width"] else {
            return XCTFail("Layer property text-halo-width should be set to a number.")
        }
        XCTAssertEqual(textHaloWidth, annotation.textHaloWidth)
    }

    func testTextOpacity() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textOpacity =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(textOpacity) = layerProperties["text-opacity"] else {
            return XCTFail("Layer property text-opacity should be set to a number.")
        }
        XCTAssertEqual(textOpacity, annotation.textOpacity)
    }

    @available(*, deprecated)
    func testUserInfo() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        let userInfo = ["foo": "bar"]
        annotation.userInfo = userInfo

        let featureProperties = try XCTUnwrap(annotation.feature.properties)
        let actualUserInfo = try XCTUnwrap(featureProperties["userInfo"]??.rawValue as? [String: Any])
        XCTAssertEqual(actualUserInfo["foo"] as? String, userInfo["foo"])
    }

    @available(*, deprecated)
    func testUserInfoNilWhenNonJSONObjectPassed() throws {
        struct NonJSON: Equatable {}
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.userInfo = ["foo": NonJSON()]

        let featureProperties = try XCTUnwrap(annotation.feature.properties)
        let actualUserInfo = try XCTUnwrap(featureProperties["userInfo"]??.rawValue as? [String: Any])
        XCTAssertNil(actualUserInfo["foo"] as? NonJSON)
    }

    @available(*, deprecated)
    func testCustomData() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        let customData: JSONObject = ["foo": .string("bar")]
        annotation.customData = customData

        let actualCustomData = try XCTUnwrap(annotation.feature.properties?["custom_data"])
        XCTAssertEqual(actualCustomData, .object(customData))
    }
}

// End of generated file
