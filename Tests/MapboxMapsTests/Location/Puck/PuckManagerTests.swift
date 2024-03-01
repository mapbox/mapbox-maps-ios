import XCTest
@testable import MapboxMaps

final class PuckManagerTests: XCTestCase {
    var make2DRenderer: Stub<Void, Mock2DPuckRenderer>!
    var make3DRenderer: Stub<Void, Mock3DPuckRenderer>!
    var renderer2D: Mock2DPuckRenderer!
    var renderer3D: Mock3DPuckRenderer!
    @TestSignal var onPuckRender: Signal<PuckRenderingData>
    var me: PuckManager<Mock2DPuckRenderer, Mock3DPuckRenderer>!

    override func setUp() {
        super.setUp()
        renderer2D = Mock2DPuckRenderer()
        renderer3D = Mock3DPuckRenderer()
        make2DRenderer = Stub(defaultReturnValue: renderer2D)
        make3DRenderer = Stub(defaultReturnValue: renderer3D)
        me = PuckManager(
            locationOptionsSubject: CurrentValueSignalSubject(LocationOptions()),
            onPuckRender: onPuckRender,
            make2DRenderer: make2DRenderer.call,
            make3DRenderer: make3DRenderer.call
        )
    }

    override func tearDown() {
        make2DRenderer = nil
        make3DRenderer = nil
        renderer2D = nil
        renderer3D = nil
        me = nil
        super.tearDown()
    }

    func test_Send2DData_SeveralTimes_MakeRenderer_Once() {
        me.locationOptions = LocationOptions(puckType: .puck2D(.makeDefault()))
        $onPuckRender.send(.random())

        me.locationOptions = LocationOptions(puckType: .puck2D(.makeDefault()), puckBearingEnabled: true)
        $onPuckRender.send(.random())

        XCTAssertEqual(make2DRenderer.invocations.count, 1)
    }

    func test_SetLocationOptions_WithNilPuckType_StopsRendering() {
        let data = PuckRenderingData.random()
        let locationOptions = LocationOptions(puckType: .puck2D(.makeDefault()))

        me.locationOptions = locationOptions
        $onPuckRender.send(data)
        me.locationOptions = LocationOptions(puckType: nil)
        $onPuckRender.send(.random())
        me.locationOptions = locationOptions
        $onPuckRender.send(data)

        XCTAssertEqual(renderer2D.$state.setStub.invocations.map(\.parameters), [
            PuckRendererState(
                data: data,
                bearingEnabled: locationOptions.puckBearingEnabled,
                bearingType: locationOptions.puckBearing,
                configuration: .makeDefault()
            ),
            nil,
            PuckRendererState(
                data: data,
                bearingEnabled: locationOptions.puckBearingEnabled,
                bearingType: locationOptions.puckBearing,
                configuration: .makeDefault()
            )
        ])
        XCTAssertEqual(renderer3D.$state.setStub.invocations.map(\.parameters), [])
    }

    func test_SetLocationOptions_With2DPuckType_Uses2DRenderer() {
        let data = PuckRenderingData.random()
        let locationOptions = LocationOptions(puckType: .puck2D(.makeDefault()))

        me.locationOptions = locationOptions
        $onPuckRender.send(data)

        XCTAssertEqual(renderer2D.state, PuckRendererState(
            data: data,
            bearingEnabled: locationOptions.puckBearingEnabled,
            bearingType: locationOptions.puckBearing,
            configuration: .makeDefault()
        ))
        XCTAssertEqual(renderer3D.state, nil)
    }

    func test_SetLocationOptions_With3DPuckType_Uses3DRenderer() {
        let data = PuckRenderingData.random()
        let configuration = Puck3DConfiguration(model: Model())
        let locationOptions = LocationOptions(puckType: .puck3D(configuration))

        me.locationOptions = locationOptions
        $onPuckRender.send(data)

        XCTAssertEqual(renderer3D.state, PuckRendererState(
            data: data,
            bearingEnabled: locationOptions.puckBearingEnabled,
            bearingType: locationOptions.puckBearing,
            configuration: configuration
        ))
        XCTAssertEqual(renderer2D.state, nil)
    }

    func test_SetLocationOptions_WithNewPuckType_UsesNewRendererAndStopsPrevious() {
        let data = PuckRenderingData.random()
        let configuration = Puck3DConfiguration(model: Model())
        let locationOptions3D = LocationOptions(puckType: .puck3D(configuration))
        let locationOptions2D = LocationOptions(puckType: .puck2D(.makeDefault()))

        me.locationOptions = locationOptions3D
        $onPuckRender.send(data)
        me.locationOptions = locationOptions2D
        $onPuckRender.send(data)
        me.locationOptions = locationOptions3D
        $onPuckRender.send(data)

        XCTAssertEqual(renderer3D.$state.setStub.invocations.map(\.parameters), [
            PuckRendererState(
                data: data,
                bearingEnabled: locationOptions3D.puckBearingEnabled,
                bearingType: locationOptions3D.puckBearing,
                configuration: configuration
            ),
            nil,
            PuckRendererState(
                data: data,
                bearingEnabled: locationOptions3D.puckBearingEnabled,
                bearingType: locationOptions3D.puckBearing,
                configuration: configuration
            ),
        ])

        XCTAssertEqual(renderer2D.$state.setStub.invocations.map(\.parameters), [
            PuckRendererState(
                data: data,
                bearingEnabled: locationOptions2D.puckBearingEnabled,
                bearingType: locationOptions2D.puckBearing,
                configuration: .makeDefault()
            ),
            nil
        ])
    }
}
