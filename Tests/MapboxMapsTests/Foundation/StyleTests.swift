import Foundation
import XCTest
@testable import MapboxMaps
@_implementationOnly import MapboxCommon_Private

final class StyleTests: XCTestCase {
    var mapClient: MockMapClient!
    var style: Style!
    var map: Map!

    override func setUpWithError() throws {
        mapClient = MockMapClient()
        map = Map(
            client: mapClient,
            mapOptions: MapOptions(),
            resourceOptions: MapboxCoreMaps.ResourceOptions(ResourceOptions(accessToken: "")))
        style = Style(with: map)
    }

    override func tearDown() {
        mapClient = nil
        style = nil
        map = nil
    }

    func testSetProjection() throws {
        XCTAssertEqual(style.styleManager.getStyleProjectionProperty(forProperty: "name").kind, .undefined)
        try style.setProjection(StyleProjection(name: .globe))
        XCTAssertEqual(style.styleManager.getStyleProjectionProperty(forProperty: "name").value as? String, "globe")
    }

    func testProjection() {
        // defaults to mercator if it's undefined
        XCTAssertEqual(style.styleManager.getStyleProjectionProperty(forProperty: "name").kind, .undefined)
        XCTAssertEqual(style.projection.name, .mercator)

        style.styleManager.setStyleProjectionForProperties(["name": "mercator"])
        XCTAssertEqual(style.projection.name, .mercator)

        style.styleManager.setStyleProjectionForProperties(["name": "globe"])
        XCTAssertEqual(style.projection.name, .globe)
    }

    func testGetStyleURI() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        // Empty URI
        XCTAssertNil(sut.uri)

        // Valid URL
        mockStyleManager.stubStyleURI = "test://testStyle"
        XCTAssertNotNil(sut.uri)
    }

    func testSetStyleURI() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        // Invalid (nil) URI -> will not update StyleURI
        sut.uri = StyleURI(rawValue: "Not A Valid Style URL")
        XCTAssertNotEqual(sut.uri?.rawValue, "Not A Valid Style URL")

        // Valid URI
        sut.uri = StyleURI(rawValue: "test://newTestStyle")
        XCTAssertEqual(sut.uri?.rawValue, "test://newTestStyle")
    }

    func testGetSetStyleJSON() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        mockStyleManager.stubStyleJSON = "{\"foo\":\"bar\"}"
        XCTAssertEqual(sut.JSON, mockStyleManager.stubStyleJSON)

        sut.JSON = "{\"foo\":\"foo\"}"
        XCTAssertEqual(mockStyleManager.getStyleJSON(), "{\"foo\":\"foo\"}")
    }

    func testDefaultCamera() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        let stubCamera = MapboxMaps.CameraOptions.random()
        mockStyleManager.stubDefaultCamera = MapboxCoreMaps.CameraOptions(stubCamera)

        XCTAssertEqual(sut.defaultCamera, stubCamera)
    }

    func testGetStyleTransition() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        let stubTransition = MapboxCoreMaps.TransitionOptions(
            duration: .random(in: 0...300),
            delay: .random(in: 0...300),
            enablePlacementTransitions: .random())
        mockStyleManager.stubStyleTransition = stubTransition

        XCTAssertEqual(sut.transition, stubTransition)
    }

    func testSetStyleTransition() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        let stubTransition = MapboxCoreMaps.TransitionOptions(
            duration: .random(in: 0...300),
            delay: .random(in: 0...300),
            enablePlacementTransitions: .random())
        sut.transition = stubTransition

        XCTAssertEqual(mockStyleManager.getStyleTransition(), stubTransition)
    }

    func testStyleLayerExistence() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        let layerID = String.randomAlphanumeric(withLength: 12)
        XCTAssertEqual(sut.layerExists(withId: layerID), mockStyleManager.styleLayerExists(forLayerId: layerID))
    }

    func testGetAllLayerIdentifiers() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        XCTAssertTrue(sut.allLayerIdentifiers.allSatisfy { layerInfo in
            mockStyleManager.getStyleLayers().contains(where: { $0.id == layerInfo.id && $0.type == layerInfo.type.rawValue })
        })
    }

    func testGetAllSourceIdentifiers() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        XCTAssertTrue(sut.allSourceIdentifiers.allSatisfy { sourceInfo in
            mockStyleManager.getStyleSources().contains(where: { $0.id == sourceInfo.id && $0.type == sourceInfo.type.rawValue })
        })
    }

    func testStyleCanAddLayer() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        XCTAssertThrowsError(try sut.addLayer(NonEncodableLayer()))

        mockStyleManager.mockery.registerStub(
            name: "addStyleLayer(forProperties:layerPosition:)",
            for: MockStyleManager.addStyleLayer,
            stubbedValue: { _, _ in Expected(value: NSNull()) }
        )
        XCTAssertNoThrow(try sut.addLayer(with: ["foo": "bar"], layerPosition: .at(0)))

        mockStyleManager.mockery.registerStub(
            name: "addStyleLayer(forProperties:layerPosition:)",
            for: MockStyleManager.addStyleLayer,
            stubbedValue: { _, _ in Expected(error: "Cannot add style layer") }
        )
        XCTAssertThrowsError(try sut.addLayer(with: ["foo": "bar"], layerPosition: .at(0)))
    }

    func testStyleCanAddPersistentLayer() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        XCTAssertThrowsError(try sut.addPersistentLayer(NonEncodableLayer(), layerPosition: .at(0)))

        mockStyleManager.mockery.registerStub(
            name: "addPersistentStyleLayer(forProperties:layerPosition:)",
            for: MockStyleManager.addPersistentStyleLayer,
            stubbedValue: { _, _ in Expected(value: NSNull()) }
        )
        XCTAssertNoThrow(try sut.addPersistentLayer(with: ["foo": "bar"], layerPosition: .at(0)))

        mockStyleManager.mockery.registerStub(
            name: "addPersistentStyleLayer(forProperties:layerPosition:)",
            for: MockStyleManager.addPersistentStyleLayer,
            stubbedValue: { _, _ in Expected(error: "Cannot add style layer") }
        )
        XCTAssertThrowsError(try sut.addPersistentLayer(with: ["foo": "bar"], layerPosition: .at(0)))
    }

    func testStyleGetLayerCanFail() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        mockStyleManager.mockery.registerStub(
            name: "getStyleLayerProperties(forLayerId:)",
            for: MockStyleManager.getStyleLayerProperties,
            stubbedValue: { layerID in
                if layerID == "dummy-layer-id1" {
                    return Expected(error: "Cannot get layer properties")
                } else {
                    return Expected(value: NSDictionary(dictionary: ["type": "Not a valid type"]))
                }
            })

        XCTAssertThrowsError(try sut.layer(withId: "dummy-style-id1"))
        XCTAssertThrowsError(try sut.layer(withId: "dummy-style-id2"))
    }
}
