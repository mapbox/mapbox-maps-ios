import XCTest
@testable import MapboxMaps

final class CameraViewTests: XCTestCase {

    let cameraOptions = CameraOptions(
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
        pitch: 10)

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
        XCTAssertEqual(cameraView.layer.bounds, CGRect(x: padding.left,
                                                         y: padding.right,
                                                         width: padding.bottom,
                                                         height: padding.top))
        let center = cameraOptions.center!
        XCTAssertEqual(cameraView.layer.position, CGPoint(x: center.longitude,
                                                          y: center.latitude))
        XCTAssertEqual(cameraView.layer.transform.m11, cameraOptions.pitch!)
        XCTAssertEqual(cameraView.layer.anchorPoint, cameraOptions.anchor!)
    }

    func testLocalCamera() {
        XCTAssertEqual(cameraView.cameraOptions, cameraOptions)
    }
}
