// swiftlint:disable all
// This file is generated
import XCTest
import Turf
@testable import MapboxMaps

final class PointAnnotationTests: XCTestCase {

    func testIconAnchor() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.iconAnchor =  IconAnchor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["icon-anchor"] as? String, annotation.iconAnchor?.rawValue)
    }

    func testIconImage() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.iconImage =  String.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["icon-image"] as? String, annotation.iconImage)
    }

    func testIconOffset() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.iconOffset =  [Double].testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["icon-offset"] as? [Double], annotation.iconOffset)
    }

    func testIconRotate() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.iconRotate =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["icon-rotate"] as? Double, annotation.iconRotate)
    }

    func testIconSize() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.iconSize =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["icon-size"] as? Double, annotation.iconSize)
    }

    func testSymbolSortKey() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.symbolSortKey =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["symbol-sort-key"] as? Double, annotation.symbolSortKey)
    }

    func testTextAnchor() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.textAnchor =  TextAnchor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["text-anchor"] as? String, annotation.textAnchor?.rawValue)
    }

    func testTextField() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.textField =  String.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["text-field"] as? String, annotation.textField)
    }

    func testTextJustify() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.textJustify =  TextJustify.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["text-justify"] as? String, annotation.textJustify?.rawValue)
    }

    func testTextLetterSpacing() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.textLetterSpacing =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["text-letter-spacing"] as? Double, annotation.textLetterSpacing)
    }

    func testTextMaxWidth() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.textMaxWidth =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["text-max-width"] as? Double, annotation.textMaxWidth)
    }

    func testTextOffset() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.textOffset =  [Double].testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["text-offset"] as? [Double], annotation.textOffset)
    }

    func testTextRadialOffset() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.textRadialOffset =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["text-radial-offset"] as? Double, annotation.textRadialOffset)
    }

    func testTextRotate() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.textRotate =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["text-rotate"] as? Double, annotation.textRotate)
    }

    func testTextSize() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.textSize =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["text-size"] as? Double, annotation.textSize)
    }

    func testTextTransform() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.textTransform =  TextTransform.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["text-transform"] as? String, annotation.textTransform?.rawValue)
    }

    func testIconColor() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.iconColor =  ColorRepresentable.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["icon-color"] as? String, annotation.iconColor.flatMap { try? $0.jsonString() })
    }

    func testIconHaloBlur() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.iconHaloBlur =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["icon-halo-blur"] as? Double, annotation.iconHaloBlur)
    }

    func testIconHaloColor() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.iconHaloColor =  ColorRepresentable.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["icon-halo-color"] as? String, annotation.iconHaloColor.flatMap { try? $0.jsonString() })
    }

    func testIconHaloWidth() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.iconHaloWidth =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["icon-halo-width"] as? Double, annotation.iconHaloWidth)
    }

    func testIconOpacity() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.iconOpacity =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["icon-opacity"] as? Double, annotation.iconOpacity)
    }

    func testTextColor() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.textColor =  ColorRepresentable.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["text-color"] as? String, annotation.textColor.flatMap { try? $0.jsonString() })
    }

    func testTextHaloBlur() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.textHaloBlur =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["text-halo-blur"] as? Double, annotation.textHaloBlur)
    }

    func testTextHaloColor() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.textHaloColor =  ColorRepresentable.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["text-halo-color"] as? String, annotation.textHaloColor.flatMap { try? $0.jsonString() })
    }

    func testTextHaloWidth() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.textHaloWidth =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["text-halo-width"] as? Double, annotation.textHaloWidth)
    }

    func testTextOpacity() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))

        annotation.textOpacity =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        XCTAssertEqual(featureProperties["text-opacity"] as? Double, annotation.textOpacity)
    }
}

// End of generated file
// swiftlint:enable all
