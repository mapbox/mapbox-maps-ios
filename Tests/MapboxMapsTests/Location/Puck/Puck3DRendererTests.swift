import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class Puck3DRendererTests: XCTestCase {
    var style: MockStyle!
    var puck3D: Puck3DRenderer!

    override func setUp() {
        super.setUp()
        style = MockStyle()
        puck3D = Puck3DRenderer(style: style)
    }

    override func tearDown() {
        puck3D = nil
        style = nil
        super.tearDown()
    }

    func test_SetNewState_With3DPuck_StartsRendering() throws {
        let configuration = Puck3DConfiguration(model: Model())
        let newState: PuckRendererState = .fixture(configuration: configuration)
        var expectedModel = configuration.model
        expectedModel.position = [newState.coordinate.longitude, newState.coordinate.latitude]
        expectedModel.orientation = [0, 0, 0]

        puck3D.state = newState

        try assertSourceAddedOnce(model: expectedModel)
        try assertLayerAddedOnce(configuration: configuration)
    }

    func test_SetNewDuplicatedState_With3DPuck_DoNothing() throws {
        let configuration = Puck3DConfiguration(model: Model())
        let newState: PuckRendererState = .fixture()
        var expectedModel = configuration.model
        expectedModel.position = [newState.coordinate.longitude, newState.coordinate.latitude]
        expectedModel.orientation = [0, 0, 0]

        puck3D.state = newState
        puck3D.state = newState

        try assertSourceAddedOnce(model: expectedModel)
        try assertLayerAddedOnce(configuration: configuration)
    }

    func test_SetNewState_WithNil_RemovesLayerAndSource() throws {
        let configuration = Puck3DConfiguration(model: Model())
        let newState: PuckRendererState = .fixture(configuration: configuration)
        var expectedModel = configuration.model
        expectedModel.position = [newState.coordinate.longitude, newState.coordinate.latitude]
        expectedModel.orientation = [0, 0, 0]

        puck3D.state = newState
        puck3D.state = nil

        XCTAssertEqual(style.removeLayerStub.invocations.map(\.parameters), ["puck-model-layer"])
        XCTAssertEqual(style.removeSourceStub.invocations.map(\.parameters), ["puck-model-source"])
    }

    func test_SetNewState_WithSameConfiguration_UpdatesOnlySources() throws {
        let configuration = Puck3DConfiguration(model: Model())
        let firstState: PuckRendererState = .fixture(
            accuracyAuthorization: .reducedAccuracy,
            configuration: configuration
        )
        let secondState: PuckRendererState = .fixture(
            accuracyAuthorization: .fullAccuracy,
            configuration: configuration
        )
        var firstModel = configuration.model
        firstModel.position = [firstState.coordinate.longitude, firstState.coordinate.latitude]
        firstModel.orientation = [0, 0, 0]

        var secondModel = configuration.model
        secondModel.position = [firstState.coordinate.longitude, firstState.coordinate.latitude]
        secondModel.orientation = [0, 0, 0]

        puck3D.state = firstState
        style.sourceExistsStub.defaultReturnValue = true
        puck3D.state = secondState

        try assertSourceAddedOnce(model: firstModel)
        try assertLayerAddedOnce(configuration: configuration)
        try assertSourceUpdated(model: secondModel)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 0)

    }
    func test_SetNewState_WithNewConfiguration_UpdatesSourcesAndLayer() throws {
        let firstConfiguration = Puck3DConfiguration(model: Model())
        let firstState: PuckRendererState = .fixture(configuration: firstConfiguration)
        var firstModel = firstConfiguration.model
        firstModel.position = [firstState.coordinate.longitude, firstState.coordinate.latitude]
        firstModel.orientation = [0, 0, 0]

        let secondConfiguration = Puck3DConfiguration(model: Model(), modelScale: .constant([3]))
        let secondState: PuckRendererState = .fixture(configuration: secondConfiguration)
        var secondModel = secondConfiguration.model
        secondModel.position = [secondState.coordinate.longitude, secondState.coordinate.latitude]
        secondModel.orientation = [0, 0, 0]

        puck3D.state = firstState
        style.sourceExistsStub.defaultReturnValue = true
        style.layerExistsStub.defaultReturnValue = true
        puck3D.state = secondState

        try assertSourceAddedOnce(model: firstModel)
        try assertLayerAddedOnce(configuration: firstConfiguration)
        try assertSourceUpdated(model: secondModel)
        try assertLayerUpdated(configuration: secondConfiguration)
    }

    private func assertSourceAddedOnce(model: Model) throws {
        var expectedSource = ModelSource(id: "puck-model-source")
        expectedSource.models = ["puck-model": model]

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        let actualSource = try XCTUnwrap(style.addSourceStub.invocations.first?.parameters.source as? ModelSource)
        XCTAssertEqual(actualSource.type, .model)
        XCTAssertEqual(actualSource.models, expectedSource.models)
        XCTAssertEqual(style.addSourceStub.invocations.first?.parameters.source.id, expectedSource.id)
    }

    private func assertSourceUpdated(model: Model) throws {
        var expectedSource = ModelSource(id: "puck-model-source")
        expectedSource.models = ["puck-model": model]

        XCTAssertEqual(style.setSourcePropertiesStub.invocations.first?.parameters.sourceId, expectedSource.id)
        let actualProperties = try XCTUnwrap(style.setSourcePropertiesStub.invocations.first?.parameters.properties)
        let expectedProperties = try expectedSource.jsonObject()
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
        XCTAssertEqual(style.setSourcePropertiesStub.invocations.first?.parameters.sourceId, "puck-model-source")
    }

    private func assertLayerAddedOnce(configuration: Puck3DConfiguration) throws {
        XCTAssertEqual(style.setLayerPropertyStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.first?.parameters.layerPosition, nil)

        let actualLayer = try XCTUnwrap(style.addPersistentLayerStub.invocations.first?.parameters.layer as? ModelLayer)
        XCTAssertEqual(actualLayer.id, "puck-model-layer")
        XCTAssertEqual(actualLayer.modelType, .constant(.locationIndicator))
        XCTAssertEqual(actualLayer.source, "puck-model-source")
        XCTAssertEqual(actualLayer.modelScale, configuration.modelScale)
        XCTAssertEqual(actualLayer.modelScaleMode, configuration.modelScaleMode)
        XCTAssertEqual(actualLayer.modelCastShadows, configuration.modelCastShadows)
        XCTAssertEqual(actualLayer.modelReceiveShadows, configuration.modelReceiveShadows)
        XCTAssertEqual(actualLayer.modelEmissiveStrength, configuration.modelEmissiveStrength)
        XCTAssertEqual(actualLayer.slot, configuration.slot)
    }

    private func assertLayerUpdated(configuration: Puck3DConfiguration) throws {
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.first?.parameters.layerId, "puck-model-layer")
    }
}

extension PuckRendererState where Configuration == Puck3DConfiguration {
    static func fixture(
        coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 10, longitude: 20),
        accuracyAuthorization: CLAccuracyAuthorization = .reducedAccuracy,
        configuration: Puck3DConfiguration = Puck3DConfiguration(model: Model()),
        bearingEnabled: Bool = false,
        bearingType: PuckBearing = .heading
    ) -> Self {
        PuckRendererState(
            coordinate: coordinate,
            accuracyAuthorization: accuracyAuthorization,
            configuration: configuration,
            bearingEnabled: bearingEnabled,
            bearingType: bearingType
        )
    }
}
