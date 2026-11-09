import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class CameraViewTests: XCTestCase {

    let cameraOptions: CameraOptions = {
        var options = CameraOptions(
        center: CLLocationCoordinate2D(
            latitude: 10,
            longitude: 10),
        padding: UIEdgeInsets(
            top: 10,
            left: 10,
            bottom: 10,
            right: 10),
        anchor: CGPoint(
            x: 10,
            y: 10),
        zoom: 10,
        bearing: 10,
        pitch: 10,
        verticalFov: 10)
        options.positionPoint = CameraPositionPoint(x: 0.25, y: -0.5)
        return options
    }()

    var cameraView: CameraView!

    override func setUp() {
        super.setUp()
        cameraView = CameraView()
        cameraView.syncLayer(to: cameraOptions)
    }

    override func tearDown() {
        cameraView = nil
        super.tearDown()
    }

    func testSyncLayer() {
        XCTAssertEqual(cameraView.layer.opacity, Float(cameraOptions.zoom!))
        XCTAssertEqual(cameraView.layer.cornerRadius, CGFloat(cameraOptions.bearing!))
        let padding = cameraOptions.padding!
        XCTAssertEqual(cameraView.layer.bounds.origin, CGPoint(x: padding.left, y: padding.right))
        XCTAssertEqual(cameraView.layer.contentsRect.origin, CGPoint(x: padding.top, y: padding.bottom))
        let center = cameraOptions.center!
        XCTAssertEqual(cameraView.layer.position, CGPoint(x: center.longitude,
                                                          y: center.latitude))
        XCTAssertEqual(cameraView.layer.borderWidth, cameraOptions.pitch!)
        XCTAssertEqual(cameraView.layer.anchorPoint, cameraOptions.anchor!)
        XCTAssertEqual(cameraView.layer.zPosition, cameraOptions.verticalFov!)
        XCTAssertEqual(cameraView.layer.shadowOffset, CGSize(width: 0.25, height: -0.5))
    }

    func testSyncLayerKeepsPositionPointWhenNil() {
        cameraView.syncLayer(to: CameraOptions(zoom: 3))

        XCTAssertEqual(cameraView.cameraOptions.positionPoint, CameraPositionPoint(x: 0.25, y: -0.5))
    }

    func testPositionPointIsCenteredBeforeTheFirstSync() {
        XCTAssertEqual(CameraView().cameraOptions.positionPoint, CameraPositionPoint(x: 0, y: 0))
    }

    func testLocalCamera() {
        XCTAssertEqual(cameraView.cameraOptions, cameraOptions)
    }
}
