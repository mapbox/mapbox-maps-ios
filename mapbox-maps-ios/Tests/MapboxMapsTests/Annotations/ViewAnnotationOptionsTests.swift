import XCTest
@testable import MapboxMaps
@_implementationOnly import MapboxCoreMaps_Private

final class ViewAnnotationOptionsTests: XCTestCase {

    let geometry: Point = .init(.init(latitude: 10.0, longitude: 20.0))
    let width: CGFloat = 25.0
    let height: CGFloat = 50.0
    let associatedFeatureId: String = "test"
    let allowOverlap: Bool = true
    let visible: Bool = true
    let anchor: ViewAnnotationAnchor = .right
    let offsetX: CGFloat = 100.0
    let offsetY: CGFloat = 200.0
    let selected: Bool = true

    func testMemberwiseInit() {
        let options = ViewAnnotationOptions(
            geometry: geometry,
            width: width,
            height: height,
            associatedFeatureId: associatedFeatureId,
            allowOverlap: allowOverlap,
            visible: visible,
            anchor: anchor,
            offsetX: offsetX,
            offsetY: offsetY,
            selected: selected
        )

        XCTAssertEqual(options.geometry, .point(geometry))
        XCTAssertEqual(options.width, width)
        XCTAssertEqual(options.height, height)
        XCTAssertEqual(options.associatedFeatureId, associatedFeatureId)
        XCTAssertEqual(options.allowOverlap, allowOverlap)
        XCTAssertEqual(options.visible, visible)
        XCTAssertEqual(options.anchor, anchor)
        XCTAssertEqual(options.offsetX, offsetX)
        XCTAssertEqual(options.offsetY, offsetY)
        XCTAssertEqual(options.selected, selected)
    }

    func testCoreInit() {
        let swiftValue = ViewAnnotationOptions(
            geometry: geometry,
            width: width,
            height: height,
            associatedFeatureId: associatedFeatureId,
            allowOverlap: allowOverlap,
            visible: visible,
            anchor: anchor,
            offsetX: offsetX,
            offsetY: offsetY,
            selected: selected
        )

        let objcValue = MapboxCoreMaps.ViewAnnotationOptions(
            __geometry: MapboxCommon.Geometry(geometry),
            associatedFeatureId: associatedFeatureId,
            width: width as NSNumber?,
            height: height as NSNumber?,
            allowOverlap: allowOverlap as NSNumber?,
            visible: visible as NSNumber?,
            anchor: anchor.rawValue as NSNumber?,
            offsetX: offsetX as NSNumber?,
            offsetY: offsetY as NSNumber?,
            selected: selected as NSNumber?
        )

        let convertedOptions = ViewAnnotationOptions(objcValue)
        XCTAssertEqual(convertedOptions, swiftValue)
    }

    func testCoreConversion() {
        let swiftValue = ViewAnnotationOptions(
            geometry: geometry,
            width: width,
            height: height,
            associatedFeatureId: associatedFeatureId,
            allowOverlap: allowOverlap,
            visible: visible,
            anchor: anchor,
            offsetX: offsetX,
            offsetY: offsetY,
            selected: selected
        )

        let convertedOptions = MapboxCoreMaps.ViewAnnotationOptions(swiftValue)

        XCTAssertEqual(Geometry(convertedOptions.__geometry!), .point(geometry))
        XCTAssertEqual(convertedOptions.__associatedFeatureId, associatedFeatureId)
        XCTAssertEqual(convertedOptions.__width, width as NSNumber?)
        XCTAssertEqual(convertedOptions.__height, height as NSNumber?)
        XCTAssertEqual(convertedOptions.__allowOverlap, allowOverlap as NSNumber?)
        XCTAssertEqual(convertedOptions.__visible, visible as NSNumber?)
        XCTAssertEqual(convertedOptions.__anchor, anchor.rawValue as NSNumber?)
        XCTAssertEqual(convertedOptions.__offsetX, offsetX as NSNumber?)
        XCTAssertEqual(convertedOptions.__offsetY, offsetY as NSNumber?)
        XCTAssertEqual(convertedOptions.__selected, selected as NSNumber)
    }

    func testFrame() {
        func verifyFrame(_ frame: CGRect, expectedOrigin: CGPoint) {
            XCTAssertEqual(frame.width, width)
            XCTAssertEqual(frame.height, height)
            XCTAssertEqual(frame.origin.x, expectedOrigin.x)
            XCTAssertEqual(frame.origin.y, expectedOrigin.y)
        }

        let width = CGFloat.random(in: 20...100)
        let height = CGFloat.random(in: 20...100)
        let offsetX = CGFloat.random(in: -100...100)
        let offsetY = CGFloat.random(in: -100...100)

        var sut = ViewAnnotationOptions(
            width: width,
            height: height,
            offsetX: offsetX,
            offsetY: offsetY
        )

        // center
        sut.anchor = .center
        verifyFrame(sut.frame, expectedOrigin: CGPoint(x: offsetX - width * 0.5, y: offsetY - height * 0.5))

        // top
        sut.anchor = .top
        verifyFrame(sut.frame, expectedOrigin: CGPoint(x: offsetX - width * 0.5, y: offsetY))

        // top-left
        sut.anchor = .topLeft
        verifyFrame(sut.frame, expectedOrigin: CGPoint(x: offsetX, y: offsetY))

        // top-right
        sut.anchor = .topRight
        verifyFrame(sut.frame, expectedOrigin: CGPoint(x: offsetX - width, y: offsetY))

        // bottom
        sut.anchor = .bottom
        verifyFrame(sut.frame, expectedOrigin: CGPoint(x: offsetX - width * 0.5, y: offsetY - height))

        // bottom-left
        sut.anchor = .bottomLeft
        verifyFrame(sut.frame, expectedOrigin: CGPoint(x: offsetX, y: offsetY - height))

        // bottom-right
        sut.anchor = .bottomRight
        verifyFrame(sut.frame, expectedOrigin: CGPoint(x: offsetX - width, y: offsetY - height))

        // left
        sut.anchor = .left
        verifyFrame(sut.frame, expectedOrigin: CGPoint(x: offsetX, y: offsetY - height * 0.5))

        // right
        sut.anchor = .right
        verifyFrame(sut.frame, expectedOrigin: CGPoint(x: offsetX - width, y: offsetY - height * 0.5))

        // Empty frame if width and height are missing
        sut.width = nil
        sut.height = nil
        XCTAssertEqual(sut.frame, .zero)
    }
}
