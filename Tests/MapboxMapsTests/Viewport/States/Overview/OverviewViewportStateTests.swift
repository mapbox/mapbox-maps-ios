import XCTest
import UIKit
@testable import MapboxMaps

final class OverviewViewportStateTest: XCTestCase {
    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var me: OverviewViewportState!
    @TestPublished var safeAreaPadding: UIEdgeInsets?

    var options = OverviewViewportStateOptions(geometry: Point(CLLocationCoordinate2D(latitude: 1, longitude: 2)),
                                               animationDuration: 0) {
        didSet {
            me?.options = options
        }
    }

    override func setUp() {
        super.setUp()
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = MockCameraAnimationsManager()
        me = OverviewViewportState(
            options: options,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager,
            safeAreaPadding: $safeAreaPadding)

        mapboxMap.cameraForCoordinatesStub.defaultSideEffect = { [unowned self] inv in
            var camera = inv.returnValue
            camera.center = self.options.geometry.coordinates.first
            inv.returnValue = camera
        }
    }

    override func tearDown() {
        me = nil
        cameraAnimationsManager = nil
        mapboxMap = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertEqual(me.options, options)
    }

    func testObserveDataSource() throws {
        let stub = Stub<CameraOptions, Bool>(defaultReturnValue: true)
        _ = me.observeDataSource(with: stub.call(with:))

        func checkCameraCalcCall(_ count: Int) throws {
            XCTAssertEqual(mapboxMap.cameraForCoordinatesStub.invocations.count, count)
            let cameraParams = try XCTUnwrap(mapboxMap.cameraForCoordinatesStub.invocations.last?.parameters)
            XCTAssertEqual(cameraParams.coordinates, options.geometry.coordinates)
            XCTAssertEqual(cameraParams.coordinatesPadding, options.geometryPadding)
            XCTAssertEqual(cameraParams.camera.padding, options.padding + safeAreaPadding)
            XCTAssertEqual(cameraParams.camera.bearing, options.bearing)
            XCTAssertEqual(cameraParams.camera.pitch, options.pitch)
        }

        func checkStubCall(_ count: Int) throws {
            XCTAssertEqual(stub.invocations.count, count)
            let result = try XCTUnwrap(stub.invocations.last?.parameters)
            XCTAssertEqual(result.center, options.geometry.coordinates.first)
        }

        try checkCameraCalcCall(1)
        try checkStubCall(1)

        options = apply(options) {
            $0.geometryPadding = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)
            $0.geometry = .point(Point(.init(latitude: 2, longitude: 3)))
        }

        try checkCameraCalcCall(2)
        try checkStubCall(2)

        safeAreaPadding = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)

        try checkCameraCalcCall(3)
        try checkStubCall(3)

        safeAreaPadding = nil

        try checkCameraCalcCall(4)
        try checkStubCall(4)

        safeAreaPadding = nil
        options = apply(options) { _ in }
        try checkCameraCalcCall(5)
        try checkStubCall(4)
    }

    func testStartUpdatingCamera() throws {
        me.startUpdatingCamera()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
        let params = try XCTUnwrap(mapboxMap.setCameraStub.invocations.last?.parameters)
        XCTAssertEqual(params.center, options.geometry.coordinates.first)

        me.stopUpdatingCamera()

        options = apply(options) {
            $0.geometry = .point(Point(.init(latitude: 2, longitude: 3)))
        }
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)

        me.startUpdatingCamera()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 2)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 0)

        options = apply(options) {
            $0.geometry = .point(Point(.init(latitude: 3, longitude: 4)))
            $0.animationDuration = 1.2
        }

        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 1)
        let animParams = try XCTUnwrap(cameraAnimationsManager.easeToStub.invocations.last?.parameters)
        XCTAssertEqual(animParams.curve, .linear)
        XCTAssertEqual(animParams.duration, 1.2)

        me.startUpdatingCamera()
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 2)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 1)
    }
}

func apply<T>(_ t: T, _ actions: (inout T) -> Void) -> T {
    var t = t
    actions(&t)
    return t
}
