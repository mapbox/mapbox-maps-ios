import XCTest
@testable import MapboxMaps

final class FollowPuckViewportStateTest: XCTestCase {

    var mapboxMap: MockMapboxMap!
    var state: FollowPuckViewportState!

    @TestSignal var onPuckRender: Signal<PuckRenderingData>
    @TestPublished var safeAreaPadding: UIEdgeInsets?

    override func setUp() {
        super.setUp()
        mapboxMap = MockMapboxMap()
        state = FollowPuckViewportState(
            options: options,
            mapboxMap: mapboxMap,
            onPuckRender: onPuckRender,
            safeAreaPadding: $safeAreaPadding)
    }

    override func tearDown() {
        state = nil
        mapboxMap = nil
        super.tearDown()
    }

    var options = FollowPuckViewportStateOptions() {
        didSet {
            state?.options = options
        }
    }

    func testGetSetOptions() {
        XCTAssertEqual(state.options, options)
        state.options = .init(zoom: 5)
        XCTAssertEqual(state.options, .init(zoom: 5))
    }

    func testObserveDataSource() throws {
        let stub = Stub<CameraOptions, Bool>(defaultReturnValue: true)
        _ = state.observeDataSource(with: stub.call(with:))

        XCTAssertEqual(stub.invocations.count, 0, "no data without puck render event")

        var puck = PuckRenderingData(
            location: Location(coordinate: .init(latitude: 1, longitude: 2)),
            heading: Heading(direction: 3, accuracy: 4))
        $onPuckRender.send(puck)

        XCTAssertEqual(stub.invocations.count, 1)
        var params = try XCTUnwrap(stub.invocations.last?.parameters)
        XCTAssertEqual(params.center, puck.location.coordinate)
        XCTAssertEqual(params.padding, nil,
                       "doesn't reset padding if it is not specified nor in options or safe area")

        options = apply(options) {
            $0.bearing = .course
            $0.pitch = 20
            $0.padding = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)
        }
        safeAreaPadding = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        puck.location = Location(
            coordinate: .init(latitude: 3, longitude: 4),
            bearing: 42)
        $onPuckRender.send(puck)

        XCTAssertEqual(stub.invocations.count, 4)
        params = try XCTUnwrap(stub.invocations.last?.parameters)
        XCTAssertEqual(params.center, puck.location.coordinate)
        XCTAssertEqual(params.padding, safeAreaPadding + options.padding)
        XCTAssertEqual(params.bearing, puck.location.bearing)
        XCTAssertEqual(params.pitch, options.pitch)
    }

    func testStartAndStopUpdatingCamera() throws {
        state.startUpdatingCamera()

        var puck = PuckRenderingData(
            location: Location(coordinate: .init(latitude: 1, longitude: 2)),
            heading: Heading(direction: 3, accuracy: 4))
        $onPuckRender.send(puck)

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
        let params = try XCTUnwrap(mapboxMap.setCameraStub.invocations.last?.parameters)
        XCTAssertEqual(params.center, puck.location.coordinate)

        state.stopUpdatingCamera()
        puck.location = Location(coordinate: .init(latitude: 3, longitude: 4))
        $onPuckRender.send(puck)
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
    }

    func testAnimationInProgressFlag() throws {
        state.startUpdatingCamera()
        XCTAssertEqual(mapboxMap.beginAnimationStub.invocations.count, 1)

        state.stopUpdatingCamera()
        XCTAssertEqual(mapboxMap.endAnimationStub.invocations.count, 1)
    }
}
