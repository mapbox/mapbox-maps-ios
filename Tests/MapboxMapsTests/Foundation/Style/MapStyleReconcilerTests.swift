@_spi(Experimental) @testable import MapboxMaps
import XCTest

final class MapStyleReconcilerTests: XCTestCase {
    var me: MapStyleReconciler!
    var styleManager: MockStyleManager!

    override func setUp() {
        super.setUp()
        styleManager = MockStyleManager()
        styleManager.isStyleLoadedStub.defaultReturnValue = true
        me = MapStyleReconciler(styleManager: styleManager)
    }

    override func tearDown() {
        super.tearDown()
        resetAllStubs()
        me = nil
        styleManager = nil
    }

    enum LoadResult {
        case cancel
        case success
        case error
    }
    private func simulateLoad(callbacks: RuntimeStylingCallbacks, result: LoadResult) {
        styleManager.isStyleLoadedStub.defaultReturnValue = result == .success
        switch result {
        case .cancel:
            callbacks.cancelled?()
        case .error:
            callbacks.error?(StyleError(message: "test error"))
        case .success:
            callbacks.layers?()
            callbacks.sources?()
            callbacks.images?()
            callbacks.completed?()
        }
    }

    func testNil() {
        XCTAssertNil(me.mapStyle)
        me.mapStyle = nil
        XCTAssertNil(me.mapStyle)
    }

    func testLoadsJSONStyle() throws {
        styleManager.setStyleJSONStub.defaultSideEffect = { _ in
            self.styleManager.isStyleLoadedStub.defaultReturnValue = false
        }

        let json = """
        {"foo": "bar"}
        """
        me.mapStyle = .init(json: json, importConfigurations: [
            .init(importId: "foo", config: [
                "bar": "baz"
            ])
        ])

        XCTAssertEqual(styleManager.setStyleJSONStub.invocations.count, 1)
        let params = try XCTUnwrap(styleManager.setStyleJSONStub.invocations.last).parameters
        XCTAssertEqual(params.value, json)

        XCTAssertEqual(styleManager.setStyleImportConfigPropertyForImportIdStub.invocations.count, 0, "don't apply import config before load")

        // style is loaded
        simulateLoad(callbacks: params.callbacks, result: .success)

        let inv = styleManager.setStyleImportConfigPropertyForImportIdStub.invocations
        XCTAssertEqual(inv.count, 1)
        XCTAssertEqual(inv.last?.parameters.importId, "foo")
        XCTAssertEqual(inv.last?.parameters.config, "bar")
        XCTAssertEqual(inv.last?.parameters.value as? String, "baz")
    }

    func testLoadsURIStyle() throws {
        styleManager.setStyleURIStub.defaultSideEffect = { _ in
            self.styleManager.isStyleLoadedStub.defaultReturnValue = false
        }

        me.mapStyle = .init(uri: .streets, importConfigurations: [
            .init(importId: "foo", config: [
                "bar": "baz"
            ])
        ])

        XCTAssertEqual(styleManager.setStyleURIStub.invocations.count, 1)
        let params = try XCTUnwrap(styleManager.setStyleURIStub.invocations.last).parameters
        XCTAssertEqual(params.value, StyleURI.streets.rawValue)

        XCTAssertEqual(styleManager.setStyleImportConfigPropertyForImportIdStub.invocations.count, 0, "don't apply import config before load")

        // style is loaded
        simulateLoad(callbacks: params.callbacks, result: .success)

        let inv = styleManager.setStyleImportConfigPropertyForImportIdStub.invocations
        XCTAssertEqual(inv.count, 1)
        XCTAssertEqual(inv.last?.parameters.importId, "foo")
        XCTAssertEqual(inv.last?.parameters.config, "bar")
        XCTAssertEqual(inv.last?.parameters.value as? String, "baz")
    }

    func testDoubleLoad() throws {
        var callbacks: RuntimeStylingCallbacks?
        styleManager.setStyleURIStub.defaultSideEffect = { invoc in
            self.styleManager.isStyleLoadedStub.defaultReturnValue = false
            if let callbacks {
                self.simulateLoad(callbacks: callbacks, result: .cancel)
            }
            callbacks = invoc.parameters.callbacks
        }

        me.mapStyle = MapStyle(uri: .outdoors, importConfigurations: [
            .init(importId: "foo-1", config: ["k-1": "v-1", "a": "b"])
        ])
        me.mapStyle = MapStyle(uri: .streets, importConfigurations: [
            .init(importId: "foo-2", config: ["k-2": "v-2"])
        ])

        XCTAssertEqual(styleManager.setStyleURIStub.invocations.map(\.parameters.value), [
            StyleURI.outdoors.rawValue,
            StyleURI.streets.rawValue
        ])

        // style is loaded
        simulateLoad(callbacks: try XCTUnwrap(callbacks), result: .success)

        // the first style update is skipped.
        let inv = styleManager.setStyleImportConfigPropertyForImportIdStub.invocations
        XCTAssertEqual(inv.count, 1)
        XCTAssertEqual(inv.last?.parameters.importId, "foo-2")
        XCTAssertEqual(inv.last?.parameters.config, "k-2")
        XCTAssertEqual(inv.last?.parameters.value as? String, "v-2")
    }

    func testLoadStyleSuccess() throws {
        var callbacks: RuntimeStylingCallbacks?
        styleManager.setStyleURIStub.defaultSideEffect = { invoc in
            self.styleManager.isStyleLoadedStub.defaultReturnValue = false
            callbacks = invoc.parameters.callbacks
        }

        let style1 = MapStyle.standard(lightPreset: .dawn)
        let style2 = MapStyle.standard(lightPreset: .dusk)
        let transition = TransitionOptions(duration: 1, delay: 2, enablePlacementTransitions: true)
        var calls = 0
        me.loadStyle(style1, transition: transition) { error in
            XCTAssertNil(error)
            calls += 1
        }
        me.loadStyle(style2, transition: transition) { error in
            XCTAssertNil(error)
            calls += 1
        }

        simulateLoad(callbacks: try XCTUnwrap(callbacks), result: .success)

        XCTAssertEqual(styleManager.setStyleURIStub.invocations.count, 1)
        XCTAssertEqual(styleManager.setStyleTransitionStub.invocations.count, 1)
        XCTAssertEqual(styleManager.setStyleTransitionStub.invocations.last?.parameters, transition)

        XCTAssertEqual(calls, 2)
    }

    func testLoadStyleError() throws {
        var callbacks: RuntimeStylingCallbacks?
        styleManager.setStyleURIStub.defaultSideEffect = { invoc in
            self.styleManager.isStyleLoadedStub.defaultReturnValue = false
            callbacks = invoc.parameters.callbacks
        }

        let style1 = MapStyle.standard(lightPreset: .dawn)
        let style2 = MapStyle.standard(lightPreset: .dusk)
        let transition = TransitionOptions(duration: 1, delay: 2, enablePlacementTransitions: true)
        var calls = 0
        me.loadStyle(style1, transition: transition) { error in
            XCTAssertTrue(error is StyleError)
            XCTAssertTrue((error as? StyleError)?.rawValue == "test error")
            calls += 1
        }
        me.loadStyle(style2, transition: transition) { error in
            XCTAssertTrue(error is StyleError)
            XCTAssertTrue((error as? StyleError)?.rawValue == "test error")
            calls += 1
        }

        simulateLoad(callbacks: try XCTUnwrap(callbacks), result: .error)

        XCTAssertEqual(styleManager.setStyleURIStub.invocations.count, 1)
        XCTAssertEqual(styleManager.setStyleTransitionStub.invocations.count, 0)

        XCTAssertEqual(calls, 2)
    }

    func testReconcileWhenLoaded() {
        styleManager.setStyleURIStub.defaultSideEffect = { invoc in
            self.simulateLoad(callbacks: invoc.parameters.callbacks, result: .success)
            self.styleManager.setStyleImportConfigPropertyForImportIdStub.reset()
        }
        me.mapStyle = MapStyle(uri: .outdoors, importConfigurations: [
            .init(importId: "foo-1", config: ["k-1": "v-1", "a": "b"])
        ])

        let s2 = MapStyle(uri: .outdoors, importConfigurations: [
            .init(importId: "foo-1", config: ["k-2": "v-2"])
        ])

        var count = 0
        me.loadStyle(s2, transition: nil) { error in
            XCTAssertNil(error)
            count += 1
        }
        XCTAssertEqual(count, 1)

        let inv = styleManager.setStyleImportConfigPropertyForImportIdStub.invocations
        XCTAssertEqual(inv.count, 1)
        XCTAssertEqual(inv.last?.parameters.importId, "foo-1")
        XCTAssertEqual(inv.last?.parameters.config, "k-2")
        XCTAssertEqual(inv.last?.parameters.value as? String, "v-2")
    }

    func testReconcileMapContentOnLoad() {
        styleManager.setStyleURIStub.defaultSideEffect = { invoc in
            self.simulateLoad(callbacks: invoc.parameters.callbacks, result: .success)
        }
        var lineLayer = LineLayer(id: "testLine", source: "testLineSource")
        me.mapStyle = .standard {
            lineLayer
        }

        lineLayer.lineColor = .constant(StyleColor.init(.brown))

        var count = 0
        me.loadStyle(.standard {
            lineLayer
        }) { error in
            XCTAssertNil(error)
            count += 1
        }
        XCTAssertEqual(count, 1)

        let addLayerInv = styleManager.addStyleLayerStub.invocations
        XCTAssertEqual(addLayerInv.count, 1)
        guard let layerProperties = addLayerInv.last?.parameters.properties as? [String: Any] else {
            XCTFail("Failed to get layerProperties")
            return
        }
        XCTAssertEqual(layerProperties["type"] as? String, "line")
        XCTAssertEqual(layerProperties["id"] as? String, "testLine")
        XCTAssertEqual(layerProperties["source"] as? String, "testLineSource")

        let updateLayerInv = styleManager.setStyleLayerPropertiesStub.invocations
        XCTAssertEqual(updateLayerInv.count, 1)
        guard let layer2Properties = updateLayerInv.last?.parameters.properties as? [String: Any] else {
            XCTFail("Failed to get layer properties")
            return
        }
        XCTAssertEqual(layer2Properties["type"] as? String, "line")
        XCTAssertEqual(layer2Properties["id"] as? String, "testLine")
        XCTAssertEqual(layer2Properties["source"] as? String, "testLineSource")
        guard let layer2Print = layer2Properties["paint"] as? [String: Any],
            let layer2Color = layer2Print["line-color"] as? String else {
            XCTFail("Failed to get layer color")
            return
        }
        XCTAssertEqual(layer2Color, "rgba(153.00, 102.00, 51.00, 1.00)")
    }

    func testReconcileMapContentOnLoadWithNewBaseStyle() {
        styleManager.setStyleURIStub.defaultSideEffect = { invoc in
            self.simulateLoad(callbacks: invoc.parameters.callbacks, result: .success)
        }
        var lineLayer = LineLayer(id: "testLine", source: "testLineSource")
        me.mapStyle = .standard {
            lineLayer
        }

        lineLayer.lineColor = .constant(StyleColor.init(.brown))

        var count = 0
        me.loadStyle(.streets {
            lineLayer
        }) { error in
            XCTAssertNil(error)
            count += 1
        }
        XCTAssertEqual(count, 1)

        // because Standard was changed to Streets a new layer should be added rather than updated
        let addLayerInv = styleManager.addStyleLayerStub.invocations
        XCTAssertEqual(addLayerInv.count, 2)
        guard let layerProperties = addLayerInv.first?.parameters.properties as? [String: Any] else {
            XCTFail("Failed to get layerProperties")
            return
        }
        XCTAssertEqual(layerProperties["type"] as? String, "line")
        XCTAssertEqual(layerProperties["id"] as? String, "testLine")
        XCTAssertEqual(layerProperties["source"] as? String, "testLineSource")

        let updateLayerInv = styleManager.setStyleLayerPropertiesStub.invocations
        XCTAssertEqual(updateLayerInv.count, 0)

        guard let layer2Properties = addLayerInv.last?.parameters.properties as? [String: Any] else {
            XCTFail("Failed to get layer properties")
            return
        }
        XCTAssertEqual(layer2Properties["type"] as? String, "line")
        XCTAssertEqual(layer2Properties["id"] as? String, "testLine")
        XCTAssertEqual(layer2Properties["source"] as? String, "testLineSource")
        guard let layer2Print = layer2Properties["paint"] as? [String: Any],
              let layer2Color = layer2Print["line-color"] as? String else {
            XCTFail("Failed to get layer color")
            return
        }
        XCTAssertEqual(layer2Color, "rgba(153.00, 102.00, 51.00, 1.00)")
    }

    func testReconcileAddRemoveContent() {
        styleManager.setStyleURIStub.defaultSideEffect = { invoc in
            self.simulateLoad(callbacks: invoc.parameters.callbacks, result: .success)
        }

        let terrain = Terrain(sourceId: "testTerrain")
        let atmosphere = Atmosphere()
        let symbolLayer = SymbolLayer(id: "testSymbol", source: "testSymbolSource")
        let styleImage = StyleImage(id: "testStyleImage", image: UIImage.empty)
        let projection = StyleProjection(name: .globe)

        let testMapStyle = MapStyle.streets {
            terrain
            atmosphere
            symbolLayer
            styleImage
            projection
        }

        me.mapStyle = testMapStyle

        // test remove elements when base style kept the same, but map content removed
        me.mapStyle = .streets

        // terrain
        let setTerrainInv = styleManager.setStyleTerrainForPropertiesStub.invocations
        XCTAssertEqual(setTerrainInv.count, 2) // one for add and one for remove
        guard let terrainParameters = setTerrainInv.first?.parameters as? [String: Any] else {
            XCTFail("Failed to get terrainParameters")
            return
        }
        XCTAssertEqual(terrainParameters["source"] as? String, "testTerrain")
        guard setTerrainInv.last?.parameters is NSNull else {
            XCTFail("terrain should be null")
            return
        }

        // atmosphere
        let addAtmosphereInv = styleManager.setStyleAtmosphereForPropertiesStub.invocations
        XCTAssertEqual(addAtmosphereInv.count, 2)
        guard let atmosphereParameters = addAtmosphereInv.first?.parameters as? [String: Any] else {
            XCTFail("Failed to get atmosphereParameters")
            return
        }
        XCTAssertEqual(atmosphereParameters.count, 0)
        guard addAtmosphereInv.last?.parameters is NSNull else {
            XCTFail("atmosphere should be null")
            return
        }

        // layers
        let addLayerInv = styleManager.addStyleLayerStub.invocations
        XCTAssertEqual(addLayerInv.count, 1)
        let removeLayerInv = styleManager.removeStyleLayerStub.invocations
        XCTAssertEqual(removeLayerInv.count, 1)
        guard let removeLayerParameters = removeLayerInv.first?.parameters as? String else {
            XCTFail("Failed to get removeLayerParameters")
            return
        }
        XCTAssertEqual(removeLayerParameters, "testSymbol")

        // style image
        let addStyleImageInv = styleManager.addStyleImageStub.invocations
        XCTAssertEqual(addStyleImageInv.count, 1)
        guard let imageParameters = addStyleImageInv.first?.parameters else {
            XCTFail("Failed to get imageProperties")
            return
        }
        XCTAssertEqual(imageParameters.imageId, "testStyleImage")
        let removeStyleImageInv = styleManager.removeStyleImageStub.invocations
        XCTAssertEqual(removeStyleImageInv.count, 1)
        guard let removeImageParameters = removeStyleImageInv.first?.parameters as? String else {
            XCTFail("Failed to get removeImageParameters")
            return
        }
        XCTAssertEqual(removeImageParameters, "testStyleImage")

        // projection
        let addGlobeProjectionInv = styleManager.setStyleProjectionPropertiesStub.invocations
        XCTAssertEqual(addGlobeProjectionInv.count, 2)
        guard let projectionParameters = addGlobeProjectionInv.first?.parameters as? [String: Any] else {
            XCTFail("Failed to get projection")
            return
        }
        XCTAssertEqual(projectionParameters["name"] as? String, "globe")
        guard addGlobeProjectionInv.last?.parameters is NSNull else {
            XCTFail("Projection should be null")
            return
        }
    }

    func testAddSources() {
        styleManager.setStyleURIStub.defaultSideEffect = { invoc in
            self.simulateLoad(callbacks: invoc.parameters.callbacks, result: .success)
        }

        me.mapStyle = .standard {
            VectorSource(id: "vectorSource")
            RasterSource(id: "rasterSource")
            RasterDemSource(id: "rasterDemSource")
            ImageSource(id: "imageSource")
            GeoJSONSource(id: "geoJSONSource")
        }

        XCTAssertEqual(styleManager.addStyleSourceStub.invocations.count, 5)

        var sourceIDs = [String]()
        for invocation in styleManager.addStyleSourceStub.invocations {
            sourceIDs.append(invocation.parameters.sourceId)
        }

        XCTAssertTrue(sourceIDs.contains("vectorSource"))
        XCTAssertTrue(sourceIDs.contains("rasterSource"))
        XCTAssertTrue(sourceIDs.contains("rasterDemSource"))
        XCTAssertTrue(sourceIDs.contains("imageSource"))
        XCTAssertTrue(sourceIDs.contains("geoJSONSource"))
    }

    func testRemoveSource() {
        styleManager.setStyleURIStub.defaultSideEffect = { invoc in
            self.simulateLoad(callbacks: invoc.parameters.callbacks, result: .success)
        }

        me.mapStyle = .standard {
            VectorSource(id: "vectorSource")
        }

        XCTAssertEqual(styleManager.addStyleSourceStub.invocations.count, 1)

        me.mapStyle = .standard

        XCTAssertEqual(styleManager.removeStyleSourceStub.invocations.count, 1)
        guard let removeSourceParameters = styleManager.removeStyleSourceStub.invocations.first?.parameters as? String else {
            XCTFail("Failed to get removeSourceParameters")
            return
        }
        XCTAssertEqual(removeSourceParameters, "vectorSource")
    }

    func testStyleImportsReconcileFromNil() {
        MapStyleReconciler.reconcileStyleImports(
            from: nil,
            to: [
                StyleImportConfiguration(
                    importId: "foo",
                    config: ["bar": "baz"])
            ],
            styleManager: styleManager)

        let inv = styleManager.setStyleImportConfigPropertyForImportIdStub.invocations
        XCTAssertEqual(inv.count, 1)
        XCTAssertEqual(inv.last?.parameters.importId, "foo")
        XCTAssertEqual(inv.last?.parameters.config, "bar")
        XCTAssertEqual(inv.last?.parameters.value as? String, "baz")
    }

    func testStyleImportsReconcilePartialUpdate() {
        MapStyleReconciler.reconcileStyleImports(
            from: [
                StyleImportConfiguration(
                    importId: "foo",
                    config: ["bar": "baz"]),
                StyleImportConfiguration(
                    importId: "x",
                    config: ["y": "z"])
            ],
            to: [
                StyleImportConfiguration(
                    importId: "foo",
                    config: [
                        "bar": "baz",
                        "qux": "quux"
                    ])
            ],
            styleManager: styleManager)

        let inv = styleManager.setStyleImportConfigPropertyForImportIdStub.invocations
        XCTAssertEqual(inv.count, 1)
        XCTAssertEqual(inv.last?.parameters.importId, "foo")
        XCTAssertEqual(inv.last?.parameters.config, "qux")
        XCTAssertEqual(inv.last?.parameters.value as? String, "quux")
    }

    func testIsStyleRootLoaded() {
        var observed = [Bool]()
        let token = me.isStyleRootLoaded.observe {
            observed.append($0)
        }
        XCTAssertEqual(observed, [false], "default")

        func simulate(result: LoadResult, style: MapStyle) {
            styleManager.setStyleURIStub.defaultSideEffect = { invoc in
                self.simulateLoad(callbacks: invoc.parameters.callbacks, result: result)
            }
            me.mapStyle = style
        }

        // success
        simulate(result: .success, style: .light)
        XCTAssertEqual(observed, [false, true])

        // no load
        simulate(result: .success, style: .light)
        XCTAssertEqual(observed, [false, true])

        // error
        simulate(result: .error, style: .streets)
        XCTAssertEqual(observed, [false, true, false])

        // reset to success
        simulate(result: .success, style: .light)
        XCTAssertEqual(observed, [false, true, false, true])

        // cancel
        simulate(result: .cancel, style: .dark)
        XCTAssertEqual(observed, [false, true, false, true, false])

        token.cancel()
    }
}
