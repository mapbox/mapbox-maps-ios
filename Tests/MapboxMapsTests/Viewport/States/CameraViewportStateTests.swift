@testable import MapboxMaps
import XCTest

final class CameraViewportStateTests: XCTestCase {
    var me: CameraViewportState!
    var mapboxMap: MockMapboxMap!

    @TestPublished var cameraOptions = CameraOptions()
    @TestPublished var safeAreaPadding: UIEdgeInsets?

    override func setUp() {
        super.setUp()
        mapboxMap = MockMapboxMap()
        cameraOptions = CameraOptions()
        safeAreaPadding = nil
        me = CameraViewportState(
            cameraOptions: $cameraOptions,
            mapboxMap: mapboxMap,
            safeAreaPadding: $safeAreaPadding)
    }

    override func tearDown() {
        super.tearDown()
        mapboxMap = nil
        me = nil
    }

    func testObserveDataSource() {
        let handler = Stub<CameraOptions, Bool>(defaultReturnValue: true)
        _ = me.observeDataSource(with: handler.call(with:))

        XCTAssertEqual(handler.invocations.count, 1)
        XCTAssertEqual(handler.invocations.last?.parameters, CameraOptions())

        let padding = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)
        cameraOptions = CameraOptions(center: .init(latitude: 1, longitude: 2), padding: padding)
        XCTAssertEqual(handler.invocations.count, 2)
        XCTAssertEqual(handler.invocations.last?.parameters, cameraOptions)

        // disable observing
        handler.defaultReturnValue = false

        let safeArea = UIEdgeInsets(top: 5, left: 6, bottom: 7, right: 8)
        var expectedCameraOpts = cameraOptions
        expectedCameraOpts.padding = cameraOptions.padding + safeArea
        safeAreaPadding = safeArea
        XCTAssertEqual(handler.invocations.count, 3)
        XCTAssertEqual(handler.invocations.last?.parameters, expectedCameraOpts)

        cameraOptions = CameraOptions(zoom: 5)
        XCTAssertEqual(handler.invocations.count, 3)
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0)
    }

    func testObserveDataSourceCancelling() {
        let handler = Stub<CameraOptions, Bool>(defaultReturnValue: true)
        let token = me.observeDataSource(with: handler.call(with:))

        XCTAssertEqual(handler.invocations.count, 1)
        token.cancel()

        cameraOptions = CameraOptions(zoom: 5)
        XCTAssertEqual(handler.invocations.count, 1)
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0)
    }

    func testUpdatingCamera() {
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0)
        me.startUpdatingCamera()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.last?.parameters, cameraOptions)

        cameraOptions.padding = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)
        safeAreaPadding = UIEdgeInsets(top: 5, left: 6, bottom: 7, right: 8)

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 3)
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.last?.parameters, CameraOptions(padding: cameraOptions.padding + safeAreaPadding))

        me.stopUpdatingCamera()
    }

    func testDefaultViewportStyle() {
        let padding = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)
        let styleDefaultCamera = CameraOptions(center: .init(latitude: 0, longitude: 1), padding: UIEdgeInsets(top: 0, left: 1, bottom: 2, right: 3), zoom: 10)

        let styleManager = MockStyle()
        styleManager.styleDefaultCamera = styleDefaultCamera

        let me = CameraViewportState.defaultStyleViewport(
            with: padding,
            styleManager: styleManager,
            mapboxMap: mapboxMap,
            safeAreaPadding: $safeAreaPadding)

        let handler = Stub<CameraOptions, Bool>(defaultReturnValue: true)
        _ = me.observeDataSource(with: handler.call(with:))

        XCTAssertEqual(handler.invocations.count, 0)

        safeAreaPadding = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)

        XCTAssertEqual(handler.invocations.count, 0, "no update until style root is loaded")

        styleManager.styleRootLoaded = true

        XCTAssertEqual(handler.invocations.count, 1)
        var expectedCamera = styleDefaultCamera
        expectedCamera.padding = padding + safeAreaPadding
        XCTAssertEqual(handler.invocations.last?.parameters, expectedCamera)

        styleManager.styleRootLoaded = false
        styleManager.styleRootLoaded = true
        XCTAssertEqual(handler.invocations.count, 1, "loads only once")
    }
}
