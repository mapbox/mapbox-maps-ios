import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class Puck3DTests: XCTestCase {

    var configuration: Puck3DConfiguration!
    var style: MockStyle!
    var puckRenderDataSubject: CurrentValueSignalSubject<PuckRenderingData?>!
    var renderDataObserved = false
    var puck3D: Puck3D!

    override func setUp() {
        super.setUp()
        configuration = Puck3DConfiguration(model: Model())
        style = MockStyle()
        puckRenderDataSubject = .init()
        puckRenderDataSubject.onObserved = { [weak self] in self?.renderDataObserved = $0 }
        recreatePuck()
    }

    override func tearDown() {
        puck3D = nil
        puckRenderDataSubject = nil
        renderDataObserved = false
        style = nil
        configuration = nil
        super.tearDown()
    }

    func recreatePuck() {
        puck3D = Puck3D(
            configuration: configuration,
            style: style,
            renderingData: puckRenderDataSubject.signal.skipNil())
    }

    func testDefaultPropertyValues() {
        XCTAssertFalse(puck3D.isActive)
        XCTAssertEqual(puck3D.puckBearing, .heading)
        XCTAssertEqual(puck3D.puckBearingEnabled, true)
    }

    func testActivatingPuckBeginsAndsStopsObserving() throws {
        XCTAssertEqual(renderDataObserved, false, "no observing by default")

        puck3D.isActive = true
        XCTAssertEqual(renderDataObserved, true, "starts observing upon activation")

        puck3D.isActive = false
        XCTAssertEqual(renderDataObserved, false, "stops observing upon deactivation")
    }

    func testSourceAndLayerAreNotAddedAtInitialization() {
        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }

    func testActivatingPuckDoesNotAddSourceAndLayerIfLatestLocationIsNil() {
        puckRenderDataSubject.value = nil

        puck3D.isActive = true

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }

    func testActivatingPuckAddsSourceAndLayerIfLatestLocationIsNonNil() throws {
        var data = PuckRenderingData.random()
        data.heading = nil
        let coordinate = data.location.coordinate
        puckRenderDataSubject.value = data

        style.sourceExistsStub.defaultReturnValue = false
        style.layerExistsStub.defaultReturnValue = false

        puck3D.isActive = true

        var expectedModel = configuration.model
        expectedModel.position = [coordinate.longitude, coordinate.latitude]
        expectedModel.orientation = [0, 0, 0]
        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        let actualSource = try XCTUnwrap(style.addSourceStub.invocations.first?.parameters.source as? ModelSource)
        XCTAssertEqual(actualSource.type, .model)
        XCTAssertEqual(actualSource.models, ["puck-model": expectedModel])
        XCTAssertEqual(style.addSourceStub.invocations.first?.parameters.source.id, "puck-model-source")

        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 1)
        let actualLayer = try XCTUnwrap(style.addPersistentLayerStub.invocations.first?.parameters.layer as? ModelLayer)
        XCTAssertEqual(actualLayer.id, "puck-model-layer")
        XCTAssertEqual(actualLayer.modelType, .constant(.locationIndicator))
        XCTAssertEqual(actualLayer.source, "puck-model-source")
        XCTAssertEqual(actualLayer.modelScale, configuration.modelScale)
        XCTAssertEqual(actualLayer.modelScaleMode, configuration.modelScaleMode)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.first?.parameters.layerPosition, nil)
    }

    func testModelOrientationBasedOnHeading() throws {
        configuration.model.orientation = [
            .random(in: 0..<360),
            .random(in: 0..<360),
            .random(in: 0..<360)]
        recreatePuck()
        let data = PuckRenderingData.random()
        let heading = try XCTUnwrap(data.heading).direction

        puckRenderDataSubject.value = data
        style.sourceExistsStub.defaultReturnValue = false
        puck3D.puckBearing = .heading

        puck3D.isActive = true

        var expectedOrientation = configuration.model.orientation!
        expectedOrientation[2] += heading
        let actualSource = try XCTUnwrap(style.addSourceStub.invocations.first?.parameters.source as? ModelSource)
        XCTAssertEqual(actualSource.models?["puck-model"]?.orientation, expectedOrientation)
    }

    func testModelOrientationBasedOnCourse() throws {
        configuration.model.orientation = [
            .random(in: 0..<360),
            .random(in: 0..<360),
            .random(in: 0..<360)]
        recreatePuck()

        let data = PuckRenderingData.random()

        puckRenderDataSubject.value = data
        style.sourceExistsStub.defaultReturnValue = false
        puck3D.puckBearing = .course

        puck3D.isActive = true

        var expectedOrientation = try XCTUnwrap(configuration.model.orientation)
        expectedOrientation[2] += try XCTUnwrap(data.location.bearing)
        let actualSource = try XCTUnwrap(style.addSourceStub.invocations.first?.parameters.source as? ModelSource)
        XCTAssertEqual(actualSource.models?["puck-model"]?.orientation, expectedOrientation)
    }

    func testPuckBearingDisabledForHeading() throws {
        configuration.model.orientation = [
            .random(in: 0..<360),
            .random(in: 0..<360),
            .random(in: 0..<360)]
        recreatePuck()

        puckRenderDataSubject.value = .random()

        style.sourceExistsStub.defaultReturnValue = false
        puck3D.puckBearing = .heading
        puck3D.puckBearingEnabled = false
        puck3D.isActive = true

        let expectedOrientation = configuration.model.orientation!
        let actualSource = try XCTUnwrap(style.addSourceStub.invocations.first?.parameters.source as? ModelSource)
        XCTAssertEqual(actualSource.models?["puck-model"]?.orientation, expectedOrientation)
    }

    func testPuckBearingDisabledForCourse() throws {
        configuration.model.orientation = [
            .random(in: 0..<360),
            .random(in: 0..<360),
            .random(in: 0..<360)]
        recreatePuck()

        puckRenderDataSubject.value = .random()

        style.sourceExistsStub.defaultReturnValue = false
        puck3D.puckBearing = .course
        puck3D.puckBearingEnabled = false
        puck3D.isActive = true

        let expectedOrientation = configuration.model.orientation!
        let actualSource = try XCTUnwrap(style.addSourceStub.invocations.first?.parameters.source as? ModelSource)
        XCTAssertEqual(actualSource.models?["puck-model"]?.orientation, expectedOrientation)
    }

    func testModelRotation() throws {
        configuration.modelRotation = .constant(.random(withLength: 3, generator: { .random(in: 0..<360) }))
        recreatePuck()
        puckRenderDataSubject.value = .random()
        style.layerExistsStub.defaultReturnValue = false

        puck3D.isActive = true

        let actualLayer = try XCTUnwrap(style.addPersistentLayerStub.invocations.first?.parameters.layer as? ModelLayer)
        XCTAssertEqual(actualLayer.modelRotation, configuration.modelRotation)
    }

    func testModelOpacity() throws {
        configuration.modelOpacity = .constant(.random(in: 0.0...1.0))
        recreatePuck()
        puckRenderDataSubject.value = .random()
        style.layerExistsStub.defaultReturnValue = false

        puck3D.isActive = true

        let actualLayer = try XCTUnwrap(style.addPersistentLayerStub.invocations.first?.parameters.layer as? ModelLayer)
        XCTAssertEqual(actualLayer.modelOpacity, configuration.modelOpacity)
    }

    func testUpdateExistingSourceAndLayer() throws {
        let location = Location.random()
        puckRenderDataSubject.value = PuckRenderingData(location: location)

        style.sourceExistsStub.defaultReturnValue = true
        style.layerExistsStub.defaultReturnValue = true

        puck3D.isActive = true

        var expectedModel = configuration.model
        expectedModel.position = [
            location.coordinate.longitude,
            location.coordinate.latitude]
        expectedModel.orientation = [0, 0, 0]

        // Source
        var expectedSource = ModelSource(id: "puck-model-source")
        expectedSource.models = ["puck-model": expectedModel]
        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.setSourcePropertiesStub.invocations.count, 1)
        let actualProperties = try XCTUnwrap(style.setSourcePropertiesStub.invocations.first?.parameters.properties)
        let expectedProperties = try expectedSource.jsonObject()
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
        XCTAssertEqual(style.setSourcePropertiesStub.invocations.first?.parameters.sourceId, "puck-model-source")

        /// Layer
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)

        puckRenderDataSubject.value = PuckRenderingData(location: .random())
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1, "doesn't update layer without config change")

        puck3D.configuration.modelOpacity = .constant(0.5)
        puckRenderDataSubject.value = PuckRenderingData(location: .random())
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2, "updates layer with config change")
    }

    func testSettingPuckBearingWhenInactive() {
        puckRenderDataSubject.value = .random()
        style.sourceExistsStub.defaultReturnValue = false
        style.layerExistsStub.defaultReturnValue = false
        puck3D.isActive = false

        puck3D.puckBearing = [.heading, .course].randomElement()!

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }

    func testLocationUpdateWhenActive() throws {
        puckRenderDataSubject.value = .random()
        puck3D.isActive = true

        style.sourceExistsStub.defaultReturnValue = true
        style.layerExistsStub.defaultReturnValue = true
        style.addSourceStub.reset()
        style.setSourcePropertiesStub.reset()
        style.addPersistentLayerStub.reset()

        puckRenderDataSubject.value = .random()

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.setSourcePropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }
}
