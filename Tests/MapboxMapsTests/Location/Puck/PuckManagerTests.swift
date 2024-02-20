import XCTest
@testable import MapboxMaps

final class PuckManagerTests: XCTestCase {
    var make2DRenderer: Stub<Void, MockPuckRenderer>!
    var make3DRenderer: Stub<Void, MockPuckRenderer>!
    var renderer2D: MockPuckRenderer!
    @TestSignal var onPuckRenderState: Signal<PuckRendererState>
    var me: PuckManager!

    override func setUp() {
        super.setUp()
        renderer2D = MockPuckRenderer()
        make2DRenderer = Stub(defaultReturnValue: renderer2D)
        make3DRenderer = Stub(defaultReturnValue: MockPuckRenderer())
        me = PuckManager(
            onPuckRenderState: onPuckRenderState,
            make2DRenderer: make2DRenderer.call,
            make3DRenderer: make3DRenderer.call
        )
    }

    override func tearDown() {
        make2DRenderer = nil
        make3DRenderer = nil
        renderer2D = nil
        me = nil
        super.tearDown()
    }

    func test_Start_SubscribesOnRenderingData() {
        me.start()

        XCTAssertEqual(_onPuckRenderState.subscribers.count, 1)
    }

    func test_Start_SeveralTimes_SubscribesOnRenderingData_Once() {
        me.start()
        me.start()

        XCTAssertEqual(_onPuckRenderState.subscribers.count, 1)
    }

    func test_Stop_UnsubscribesFromRenderingData() {
        me.start()

        me.stop()

        XCTAssertEqual(_onPuckRenderState.subscribers.count, 0)
    }

    func test_ReceivesState_WithNilPuckType_UnsubscribesFromRenderingData() {
        me.start()

        $onPuckRenderState.send(.fixture(locationOptions: .init(puckType: nil)))

        XCTAssertEqual(_onPuckRenderState.subscribers.count, 0)
    }

    func test_ReceivesState_With2DPuckType_Creates2DRenderer() {
        me.start()

        $onPuckRenderState.send(.fixture(locationOptions: .init(puckType: .fixture2D)))

        XCTAssertEqual(_onPuckRenderState.subscribers.count, 1)
        XCTAssertEqual(make2DRenderer.invocations.count, 1)
        XCTAssertEqual(make3DRenderer.invocations.count, 0)
    }

    func test_ReceivesState_With3DPuckType_Creates3DRenderer() {
        me.start()

        $onPuckRenderState.send(.fixture(locationOptions: .init(puckType: .fixture3D)))

        XCTAssertEqual(_onPuckRenderState.subscribers.count, 1)
        XCTAssertEqual(make2DRenderer.invocations.count, 0)
        XCTAssertEqual(make3DRenderer.invocations.count, 1)
    }

    func test_ReceivesState_WithNewPuckType_CreatesNewRenderer() {
        me.start()

        $onPuckRenderState.send(.fixture(locationOptions: .init(puckType: .fixture3D)))
        $onPuckRenderState.send(.fixture(locationOptions: .init(puckType: .fixture2D)))

        XCTAssertEqual(_onPuckRenderState.subscribers.count, 1)
        XCTAssertEqual(make2DRenderer.invocations.count, 1)
        XCTAssertEqual(make3DRenderer.invocations.count, 1)
    }

    func test_ReceivesState_WithNewPuckType_NullifiesPreviousRendererState() {
        me.start()

        $onPuckRenderState.send(.fixture(locationOptions: .init(puckType: .fixture2D)))
        renderer2D.state = .fixture()
        $onPuckRenderState.send(.fixture(locationOptions: .init(puckType: .fixture3D)))

        XCTAssertNil(renderer2D.state)
    }

    func test_ReceivesState_SetItToRenderer() {
        me.start()
        $onPuckRenderState.send(.fixture(locationOptions: .init(puckType: .fixture2D)))

        _onPuckRenderState.subscribers.forEach { handler in
            handler(.fixture(coordinate: .fixture, locationOptions: .init(puckType: .fixture2D)))
        }

        XCTAssertEqual(renderer2D.state, .fixture(coordinate: .fixture, locationOptions: .init(puckType: .fixture2D)))
    }
}

private extension CLLocationCoordinate2D {
    static let fixture: Self = .init(latitude: 23, longitude: 11)
}

extension PuckRendererState {
    static func fixture(
        coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0),
        accuracyAuthorization: CLAccuracyAuthorization = .reducedAccuracy,
        locationOptions: LocationOptions = .init()
    ) -> Self {
        PuckRendererState(
            coordinate: coordinate,
            accuracyAuthorization: accuracyAuthorization,
            locationOptions: locationOptions
        )
    }
}

extension PuckType {
    static let fixture3D: Self = .puck3D(Puck3DConfiguration(model: Model()))
    static let fixture2D: Self = .puck2D(Puck2DConfiguration())
}
