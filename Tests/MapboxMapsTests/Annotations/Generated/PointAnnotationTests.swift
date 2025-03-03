// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

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

    func testIconColorUseTheme() {
      var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
      annotation.iconColorUseTheme = .default

      guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
          return
      }
      guard case let .object(layerProperties) = featureProperties["layerProperties"],
            case let .string(iconColorUseTheme) = layerProperties["icon-color-use-theme"] else {
          return XCTFail("Layer property icon-color-use-theme should be set to a string.")
      }

      XCTAssertEqual(iconColorUseTheme, annotation.iconColorUseTheme?.rawValue)
    }
    func testIconColorTransition() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconColorTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(iconColorTransition) = layerProperties["icon-color-transition"],
              case let .number(duration) = iconColorTransition["duration"],
              case let .number(delay) = iconColorTransition["delay"]
        else {
            return XCTFail("Layer property icon-color-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.iconColorTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.iconColorTransition?.delay)
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

    func testIconEmissiveStrengthTransition() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconEmissiveStrengthTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(iconEmissiveStrengthTransition) = layerProperties["icon-emissive-strength-transition"],
              case let .number(duration) = iconEmissiveStrengthTransition["duration"],
              case let .number(delay) = iconEmissiveStrengthTransition["delay"]
        else {
            return XCTFail("Layer property icon-emissive-strength-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.iconEmissiveStrengthTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.iconEmissiveStrengthTransition?.delay)
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

    func testIconHaloBlurTransition() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconHaloBlurTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(iconHaloBlurTransition) = layerProperties["icon-halo-blur-transition"],
              case let .number(duration) = iconHaloBlurTransition["duration"],
              case let .number(delay) = iconHaloBlurTransition["delay"]
        else {
            return XCTFail("Layer property icon-halo-blur-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.iconHaloBlurTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.iconHaloBlurTransition?.delay)
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

    func testIconHaloColorUseTheme() {
      var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
      annotation.iconHaloColorUseTheme = .default

      guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
          return
      }
      guard case let .object(layerProperties) = featureProperties["layerProperties"],
            case let .string(iconHaloColorUseTheme) = layerProperties["icon-halo-color-use-theme"] else {
          return XCTFail("Layer property icon-halo-color-use-theme should be set to a string.")
      }

      XCTAssertEqual(iconHaloColorUseTheme, annotation.iconHaloColorUseTheme?.rawValue)
    }
    func testIconHaloColorTransition() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconHaloColorTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(iconHaloColorTransition) = layerProperties["icon-halo-color-transition"],
              case let .number(duration) = iconHaloColorTransition["duration"],
              case let .number(delay) = iconHaloColorTransition["delay"]
        else {
            return XCTFail("Layer property icon-halo-color-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.iconHaloColorTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.iconHaloColorTransition?.delay)
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

    func testIconHaloWidthTransition() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconHaloWidthTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(iconHaloWidthTransition) = layerProperties["icon-halo-width-transition"],
              case let .number(duration) = iconHaloWidthTransition["duration"],
              case let .number(delay) = iconHaloWidthTransition["delay"]
        else {
            return XCTFail("Layer property icon-halo-width-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.iconHaloWidthTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.iconHaloWidthTransition?.delay)
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

    func testIconImageCrossFadeTransition() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconImageCrossFadeTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(iconImageCrossFadeTransition) = layerProperties["icon-image-cross-fade-transition"],
              case let .number(duration) = iconImageCrossFadeTransition["duration"],
              case let .number(delay) = iconImageCrossFadeTransition["delay"]
        else {
            return XCTFail("Layer property icon-image-cross-fade-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.iconImageCrossFadeTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.iconImageCrossFadeTransition?.delay)
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

    func testIconOcclusionOpacityTransition() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconOcclusionOpacityTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(iconOcclusionOpacityTransition) = layerProperties["icon-occlusion-opacity-transition"],
              case let .number(duration) = iconOcclusionOpacityTransition["duration"],
              case let .number(delay) = iconOcclusionOpacityTransition["delay"]
        else {
            return XCTFail("Layer property icon-occlusion-opacity-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.iconOcclusionOpacityTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.iconOcclusionOpacityTransition?.delay)
    }

    func testIconOcclusionOpacity() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconOcclusionOpacity =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(iconOcclusionOpacity) = layerProperties["icon-occlusion-opacity"] else {
            return XCTFail("Layer property icon-occlusion-opacity should be set to a number.")
        }
        XCTAssertEqual(iconOcclusionOpacity, annotation.iconOcclusionOpacity)
    }

    func testIconOpacityTransition() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.iconOpacityTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(iconOpacityTransition) = layerProperties["icon-opacity-transition"],
              case let .number(duration) = iconOpacityTransition["duration"],
              case let .number(delay) = iconOpacityTransition["delay"]
        else {
            return XCTFail("Layer property icon-opacity-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.iconOpacityTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.iconOpacityTransition?.delay)
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

    func testSymbolZOffsetTransition() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.symbolZOffsetTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(symbolZOffsetTransition) = layerProperties["symbol-z-offset-transition"],
              case let .number(duration) = symbolZOffsetTransition["duration"],
              case let .number(delay) = symbolZOffsetTransition["delay"]
        else {
            return XCTFail("Layer property symbol-z-offset-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.symbolZOffsetTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.symbolZOffsetTransition?.delay)
    }

    func testSymbolZOffset() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.symbolZOffset =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(symbolZOffset) = layerProperties["symbol-z-offset"] else {
            return XCTFail("Layer property symbol-z-offset should be set to a number.")
        }
        XCTAssertEqual(symbolZOffset, annotation.symbolZOffset)
    }

    func testTextColorUseTheme() {
      var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
      annotation.textColorUseTheme = .default

      guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
          return
      }
      guard case let .object(layerProperties) = featureProperties["layerProperties"],
            case let .string(textColorUseTheme) = layerProperties["text-color-use-theme"] else {
          return XCTFail("Layer property text-color-use-theme should be set to a string.")
      }

      XCTAssertEqual(textColorUseTheme, annotation.textColorUseTheme?.rawValue)
    }
    func testTextColorTransition() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textColorTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(textColorTransition) = layerProperties["text-color-transition"],
              case let .number(duration) = textColorTransition["duration"],
              case let .number(delay) = textColorTransition["delay"]
        else {
            return XCTFail("Layer property text-color-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.textColorTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.textColorTransition?.delay)
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

    func testTextEmissiveStrengthTransition() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textEmissiveStrengthTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(textEmissiveStrengthTransition) = layerProperties["text-emissive-strength-transition"],
              case let .number(duration) = textEmissiveStrengthTransition["duration"],
              case let .number(delay) = textEmissiveStrengthTransition["delay"]
        else {
            return XCTFail("Layer property text-emissive-strength-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.textEmissiveStrengthTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.textEmissiveStrengthTransition?.delay)
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

    func testTextHaloBlurTransition() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textHaloBlurTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(textHaloBlurTransition) = layerProperties["text-halo-blur-transition"],
              case let .number(duration) = textHaloBlurTransition["duration"],
              case let .number(delay) = textHaloBlurTransition["delay"]
        else {
            return XCTFail("Layer property text-halo-blur-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.textHaloBlurTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.textHaloBlurTransition?.delay)
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

    func testTextHaloColorUseTheme() {
      var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
      annotation.textHaloColorUseTheme = .default

      guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
          return
      }
      guard case let .object(layerProperties) = featureProperties["layerProperties"],
            case let .string(textHaloColorUseTheme) = layerProperties["text-halo-color-use-theme"] else {
          return XCTFail("Layer property text-halo-color-use-theme should be set to a string.")
      }

      XCTAssertEqual(textHaloColorUseTheme, annotation.textHaloColorUseTheme?.rawValue)
    }
    func testTextHaloColorTransition() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textHaloColorTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(textHaloColorTransition) = layerProperties["text-halo-color-transition"],
              case let .number(duration) = textHaloColorTransition["duration"],
              case let .number(delay) = textHaloColorTransition["delay"]
        else {
            return XCTFail("Layer property text-halo-color-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.textHaloColorTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.textHaloColorTransition?.delay)
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

    func testTextHaloWidthTransition() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textHaloWidthTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(textHaloWidthTransition) = layerProperties["text-halo-width-transition"],
              case let .number(duration) = textHaloWidthTransition["duration"],
              case let .number(delay) = textHaloWidthTransition["delay"]
        else {
            return XCTFail("Layer property text-halo-width-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.textHaloWidthTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.textHaloWidthTransition?.delay)
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

    func testTextOcclusionOpacityTransition() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textOcclusionOpacityTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(textOcclusionOpacityTransition) = layerProperties["text-occlusion-opacity-transition"],
              case let .number(duration) = textOcclusionOpacityTransition["duration"],
              case let .number(delay) = textOcclusionOpacityTransition["delay"]
        else {
            return XCTFail("Layer property text-occlusion-opacity-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.textOcclusionOpacityTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.textOcclusionOpacityTransition?.delay)
    }

    func testTextOcclusionOpacity() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textOcclusionOpacity =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(textOcclusionOpacity) = layerProperties["text-occlusion-opacity"] else {
            return XCTFail("Layer property text-occlusion-opacity should be set to a number.")
        }
        XCTAssertEqual(textOcclusionOpacity, annotation.textOcclusionOpacity)
    }

    func testTextOpacityTransition() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textOpacityTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(textOpacityTransition) = layerProperties["text-opacity-transition"],
              case let .number(duration) = textOpacityTransition["duration"],
              case let .number(delay) = textOpacityTransition["delay"]
        else {
            return XCTFail("Layer property text-opacity-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.textOpacityTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.textOpacityTransition?.delay)
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
