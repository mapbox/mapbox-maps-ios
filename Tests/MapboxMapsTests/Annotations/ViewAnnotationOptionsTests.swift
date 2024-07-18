import XCTest
@testable import MapboxMaps

final class ViewAnnotationOptionsTests: XCTestCase {

    let annotatedLayerFeature = AnnotatedFeature.layerFeature(layerId: "foo", featureId: "gar")
    let point = Point(CLLocationCoordinate2D(latitude: 10, longitude: 20))
    let width: CGFloat = 25.0
    let height: CGFloat = 50.0
    let allowOverlap: Bool = true
    let allowOverlapWithPuck = true
    let allowZElevate = true
    let ignoreCameraPadding = true
    let visible: Bool = true
    let anchor: ViewAnnotationAnchor = .right
    let offsetX: CGFloat = 100.0
    let offsetY: CGFloat = 200.0
    let selected: Bool = true
    var variableAnchors: [ViewAnnotationAnchorConfig] {
        [ViewAnnotationAnchorConfig(anchor: anchor, offsetX: offsetX, offsetY: offsetY)]
    }

    func testMemberwiseInit() {
        let options = ViewAnnotationOptions(
            annotatedFeature: annotatedLayerFeature,
            width: width,
            height: height,
            allowOverlap: allowOverlap,
            visible: visible,
            selected: selected,
            variableAnchors: variableAnchors)

        XCTAssertEqual(options.annotatedFeature, annotatedLayerFeature)
        XCTAssertEqual(options.width, width)
        XCTAssertEqual(options.height, height)
        XCTAssertEqual(options.allowOverlap, allowOverlap)
        XCTAssertEqual(options.visible, visible)
        XCTAssertEqual(options.variableAnchors?.first?.anchor, anchor)
        XCTAssertEqual(options.variableAnchors?.first?.offsetX, offsetX)
        XCTAssertEqual(options.variableAnchors?.first?.offsetY, offsetY)
        XCTAssertEqual(options.selected, selected)
    }

    func testCoreInit() {
        let swiftValue = ViewAnnotationOptions(
            annotatedFeature: .geometry(point),
            width: width,
            height: height,
            allowOverlap: allowOverlap,
            allowOverlapWithPuck: allowOverlapWithPuck,
            visible: visible,
            selected: selected,
            variableAnchors: [ViewAnnotationAnchorConfig(anchor: anchor, offsetX: offsetX, offsetY: offsetY)],
            ignoreCameraPadding: ignoreCameraPadding)

        let objcValue = CoreViewAnnotationOptions(
            __annotatedFeature: .fromGeometry(MapboxCommon.Geometry(point)),
            width: width as NSNumber?,
            height: height as NSNumber?,
            allowOverlap: allowOverlap as NSNumber?,
            allowOverlapWithPuck: allowOverlap as NSNumber?,
            allowZElevate: allowZElevate as NSNumber?,
            visible: visible as NSNumber?,
            variableAnchors: variableAnchors,
            selected: selected as NSNumber?,
            ignoreCameraPadding: ignoreCameraPadding as NSNumber?
        )

        let convertedOptions = ViewAnnotationOptions(objcValue)
        XCTAssertEqual(convertedOptions, swiftValue)

        let convertedObjcValue = CoreViewAnnotationOptions(swiftValue)
        let convertedBack = ViewAnnotationOptions(convertedObjcValue)

        XCTAssertEqual(convertedBack, swiftValue)
    }

    func testFrame() {
        func verifyFrame(_ frame: CGRect, expectedOrigin: CGPoint) {
            XCTAssertEqual(frame.width, width)
            XCTAssertEqual(frame.height, height)
            XCTAssertEqual(frame.origin.x, expectedOrigin.x)
            XCTAssertEqual(frame.origin.y, expectedOrigin.y)
        }

        let width: CGFloat = 80
        let height: CGFloat = 40
        let offsetX: CGFloat = -30
        let offsetY: CGFloat = 50

        var sut = ViewAnnotationOptions(
            annotatedFeature: .layerFeature(layerId: "foo"),
            width: width,
            height: height
        )

        // center
        sut.variableAnchors = [ViewAnnotationAnchorConfig(anchor: .center, offsetX: offsetX, offsetY: offsetY)]
        verifyFrame(sut.frame(with: nil), expectedOrigin: CGPoint(x: offsetX - width * 0.5, y: offsetY - height * 0.5))

        // top
        sut.variableAnchors = [ViewAnnotationAnchorConfig(anchor: .top, offsetX: offsetX, offsetY: offsetY)]
        verifyFrame(sut.frame(with: nil), expectedOrigin: CGPoint(x: offsetX - width * 0.5, y: offsetY))

        // top-left
        sut.variableAnchors = [ViewAnnotationAnchorConfig(anchor: .topLeft, offsetX: offsetX, offsetY: offsetY)]
        verifyFrame(sut.frame(with: nil), expectedOrigin: CGPoint(x: offsetX, y: offsetY))

        // top-right
        sut.variableAnchors = [ViewAnnotationAnchorConfig(anchor: .topRight, offsetX: offsetX, offsetY: offsetY)]
        verifyFrame(sut.frame(with: nil), expectedOrigin: CGPoint(x: offsetX - width, y: offsetY))

        // bottom
        sut.variableAnchors = [ViewAnnotationAnchorConfig(anchor: .bottom, offsetX: offsetX, offsetY: offsetY)]
        verifyFrame(sut.frame(with: nil), expectedOrigin: CGPoint(x: offsetX - width * 0.5, y: offsetY - height))

        // bottom-left
        sut.variableAnchors = [ViewAnnotationAnchorConfig(anchor: .bottomLeft, offsetX: offsetX, offsetY: offsetY)]
        verifyFrame(sut.frame(with: nil), expectedOrigin: CGPoint(x: offsetX, y: offsetY - height))

        // bottom-right
        sut.variableAnchors = [ViewAnnotationAnchorConfig(anchor: .bottomRight, offsetX: offsetX, offsetY: offsetY)]
        verifyFrame(sut.frame(with: nil), expectedOrigin: CGPoint(x: offsetX - width, y: offsetY - height))

        // left
        sut.variableAnchors = [ViewAnnotationAnchorConfig(anchor: .left, offsetX: offsetX, offsetY: offsetY)]
        verifyFrame(sut.frame(with: nil), expectedOrigin: CGPoint(x: offsetX, y: offsetY - height * 0.5))

        // right
        sut.variableAnchors = [ViewAnnotationAnchorConfig(anchor: .right, offsetX: offsetX, offsetY: offsetY)]
        verifyFrame(sut.frame(with: nil), expectedOrigin: CGPoint(x: offsetX - width, y: offsetY - height * 0.5))

        // Empty frame if width and height are missing
        sut.width = nil
        sut.height = nil
        XCTAssertEqual(sut.frame(with: nil), .zero)
    }
}
