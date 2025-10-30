@_spi(Experimental) @testable import MapboxMaps
import XCTest

final class MapStyleReconcilerTests: XCTestCase {
    var me: MapStyleReconciler!
    var styleManager: MockStyleManager!
    var sourceManager: MockStyleSourceManager!

    override func setUp() {
        super.setUp()
        styleManager = MockStyleManager()
        sourceManager = MockStyleSourceManager()
        styleManager.isStyleLoadedStub.defaultReturnValue = true
        me = MapStyleReconciler(styleManager: styleManager)
    }

    override func tearDown() {
        super.tearDown()
        resetAllStubs()
        me = nil
        styleManager = nil
        sourceManager = nil
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
        me.mapStyle = .init(json: json, configuration: JSONObject(turfRawValue: ["bar": "baz"])!)

        XCTAssertEqual(styleManager.setStyleJSONStub.invocations.count, 1)
        let params = try XCTUnwrap(styleManager.setStyleJSONStub.invocations.last).parameters
        XCTAssertEqual(params.value, json)

        XCTAssertEqual(styleManager.setStyleImportConfigPropertyForImportIdStub.invocations.count, 0, "don't apply import config before load")

        // style is loaded
        simulateLoad(callbacks: params.callbacks, result: .success)

        let inv = styleManager.setStyleImportConfigPropertyForImportIdStub.invocations
        XCTAssertEqual(inv.count, 1)
        XCTAssertEqual(inv.last?.parameters.importId, "basemap")
        XCTAssertEqual(inv.last?.parameters.config, "bar")
        XCTAssertEqual(inv.last?.parameters.value as? String, "baz")
    }

    func testLoadsURIStyle() throws {
        styleManager.setStyleURIStub.defaultSideEffect = { _ in
            self.styleManager.isStyleLoadedStub.defaultReturnValue = false
        }

        me.mapStyle = .init(uri: .streets, configuration: JSONObject(turfRawValue: ["bar": "baz"])!)

        XCTAssertEqual(styleManager.setStyleURIStub.invocations.count, 1)
        let params = try XCTUnwrap(styleManager.setStyleURIStub.invocations.last).parameters
        XCTAssertEqual(params.value, StyleURI.streets.rawValue)

        XCTAssertEqual(styleManager.setStyleImportConfigPropertyForImportIdStub.invocations.count, 0, "don't apply import config before load")

        // style is loaded
        simulateLoad(callbacks: params.callbacks, result: .success)

        let inv = styleManager.setStyleImportConfigPropertyForImportIdStub.invocations
        XCTAssertEqual(inv.count, 1)
        XCTAssertEqual(inv.last?.parameters.importId, "basemap")
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

        me.mapStyle = .init(uri: .outdoors, configuration: JSONObject(turfRawValue: ["k-1": "v-1", "a": "b"])!)
        me.mapStyle = .init(uri: .streets, configuration: JSONObject(turfRawValue: ["k-2": "v-2"])!)

        XCTAssertEqual(styleManager.setStyleURIStub.invocations.map(\.parameters.value), [
            StyleURI.outdoors.rawValue,
            StyleURI.streets.rawValue
        ])

        // style is loaded
        simulateLoad(callbacks: try XCTUnwrap(callbacks), result: .success)

        // the first style update is skipped.
        let inv = styleManager.setStyleImportConfigPropertyForImportIdStub.invocations
        XCTAssertEqual(inv.count, 1)
        XCTAssertEqual(inv.last?.parameters.importId, "basemap")
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

        let coreTransitionOptions = try XCTUnwrap(styleManager.setStyleTransitionStub.invocations.last?.parameters)
        XCTAssertEqual(TransitionOptions(coreTransitionOptions), transition)

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
        me.mapStyle = MapStyle(uri: .outdoors, configuration: JSONObject(turfRawValue: ["k-1": "v-1", "a": "b"])!)

        let s2 = MapStyle(uri: .outdoors, configuration: JSONObject(turfRawValue: ["k-2": "v-2"])!)

        var count = 0
        me.loadStyle(s2, transition: nil) { error in
            XCTAssertNil(error)
            count += 1
        }
        XCTAssertEqual(count, 1)

        let inv = styleManager.setStyleImportConfigPropertyForImportIdStub.invocations
        XCTAssertEqual(inv.count, 1)
        XCTAssertEqual(inv.last?.parameters.importId, "basemap")
        XCTAssertEqual(inv.last?.parameters.config, "k-2")
        XCTAssertEqual(inv.last?.parameters.value as? String, "v-2")
    }

    func testReconcileWhenLoadedNewStyle() throws {
        styleManager.setStyleURIStub.defaultSideEffect = { invoc in
            self.simulateLoad(callbacks: invoc.parameters.callbacks, result: .success)
        }
        me.mapStyle = MapStyle(uri: .outdoors, configuration: JSONObject(turfRawValue: ["k-1": "v-1", "a": "b"])!)

        self.styleManager.setStyleImportConfigPropertyForImportIdStub.reset()

        me.mapStyle = MapStyle(uri: .standard, configuration: JSONObject(turfRawValue: ["k-1": "v-1", "k-2": "v-2"])!)

        let inv = styleManager.setStyleImportConfigPropertyForImportIdStub.invocations
        XCTAssertEqual(inv.count, 2)
        let k1Params = try XCTUnwrap(inv.first(where: { $0.parameters.config == "k-1"})).parameters
        let k2Params = try XCTUnwrap(inv.first(where: { $0.parameters.config == "k-2"})).parameters
        XCTAssertEqual(k1Params.importId, "basemap")
        XCTAssertEqual(k2Params.importId, "basemap")
        XCTAssertEqual(k1Params.value as? String, "v-1")
        XCTAssertEqual(k2Params.value as? String, "v-2")
    }

    func testStyleImportsReconcileFromNil() {
            MapStyleReconciler.reconcileBasemapConfiguration(
            from: nil,
            to: .init(["bar": "baz"])!,
            styleManager: styleManager)

        let inv = styleManager.setStyleImportConfigPropertyForImportIdStub.invocations
        XCTAssertEqual(inv.count, 1)
        XCTAssertEqual(inv.last?.parameters.importId, "basemap")
        XCTAssertEqual(inv.last?.parameters.config, "bar")
        XCTAssertEqual(inv.last?.parameters.value as? String, "baz")
    }

    func testStyleImportsReconcilePartialUpdate() {
        MapStyleReconciler.reconcileBasemapConfiguration(
            from: JSONObject(turfRawValue: [
                "bar": "baz",
                "x": "y"
            ])!,
            to: JSONObject(turfRawValue: [
                "bar": "foo",
                "x": "y"
            ])!,
            styleManager: styleManager)

        let inv = styleManager.setStyleImportConfigPropertyForImportIdStub.invocations
        XCTAssertEqual(inv.count, 1)
        XCTAssertEqual(inv.last?.parameters.importId, "basemap")
        XCTAssertEqual(inv.last?.parameters.config, "bar")
        XCTAssertEqual(inv.last?.parameters.value as? String, "foo")
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

    // MARK: - Always Reload Tests

    func testAlwaysReloadWithSameURI() throws {
        styleManager.setStyleURIStub.defaultSideEffect = { _ in
            self.styleManager.isStyleLoadedStub.defaultReturnValue = false
        }

        // Load initial style
        me.mapStyle = MapStyle(uri: .standard)
        XCTAssertEqual(styleManager.setStyleURIStub.invocations.count, 1)

        // Load same URI with default policy (should skip)
        me.mapStyle = MapStyle(uri: .standard)
        XCTAssertEqual(styleManager.setStyleURIStub.invocations.count, 1, "Should not reload with same URI")

        // Always reload with same URI
        me.mapStyle = MapStyle(uri: .standard, reloadPolicy: .always)
        XCTAssertEqual(styleManager.setStyleURIStub.invocations.count, 2, "Should reload with .always policy")
    }

    func testAlwaysReloadWithSameJSON() throws {
        let json = "{\"layers\": [], \"sources\": {}}"
        styleManager.setStyleJSONStub.defaultSideEffect = { _ in
            self.styleManager.isStyleLoadedStub.defaultReturnValue = false
        }

        // Load initial style
        me.mapStyle = MapStyle(json: json)
        XCTAssertEqual(styleManager.setStyleJSONStub.invocations.count, 1)

        // Load same JSON with default policy (should skip)
        me.mapStyle = MapStyle(json: json)
        XCTAssertEqual(styleManager.setStyleJSONStub.invocations.count, 1, "Should not reload with same JSON")

        // Always reload with same JSON
        me.mapStyle = MapStyle(json: json, reloadPolicy: .always)
        XCTAssertEqual(styleManager.setStyleJSONStub.invocations.count, 2, "Should reload with .always policy")
    }

    func testAlwaysReloadCancelsPendingLoads() throws {
        var callbacks: RuntimeStylingCallbacks?
        styleManager.setStyleURIStub.defaultSideEffect = { invoc in
            self.styleManager.isStyleLoadedStub.defaultReturnValue = false
            // Cancel previous load when new load starts
            if let callbacks {
                self.simulateLoad(callbacks: callbacks, result: .cancel)
            }
            callbacks = invoc.parameters.callbacks
        }

        // Start loading a style
        var firstCallbackReceived = false
        me.loadStyle(MapStyle(uri: .standard)) { error in
            XCTAssertTrue(error is CancelError, "First load should be cancelled")
            firstCallbackReceived = true
        }

        // Always reload should cancel the first load
        me.loadStyle(MapStyle(uri: .standard, reloadPolicy: .always)) { error in
            XCTAssertNil(error)
        }

        // Simulate the second load completing
        simulateLoad(callbacks: try XCTUnwrap(callbacks), result: .success)

        XCTAssertTrue(firstCallbackReceived, "First completion should have been called with CancelError")
    }

    func testOnlyIfChangedPolicyDoesNotReloadSameStyle() {
        styleManager.setStyleURIStub.defaultSideEffect = { _ in
            self.styleManager.isStyleLoadedStub.defaultReturnValue = false
        }

        me.mapStyle = MapStyle(uri: .standard, reloadPolicy: .onlyIfChanged)
        XCTAssertEqual(styleManager.setStyleURIStub.invocations.count, 1)

        me.mapStyle = MapStyle(uri: .standard, reloadPolicy: .onlyIfChanged)
        XCTAssertEqual(styleManager.setStyleURIStub.invocations.count, 1, ".onlyIfChanged should not reload same style")
    }

    func testNilPolicyBehavesLikeOnlyIfChanged() {
        styleManager.setStyleURIStub.defaultSideEffect = { _ in
            self.styleManager.isStyleLoadedStub.defaultReturnValue = false
        }

        me.mapStyle = MapStyle(uri: .standard, reloadPolicy: nil)
        XCTAssertEqual(styleManager.setStyleURIStub.invocations.count, 1)

        me.mapStyle = MapStyle(uri: .standard, reloadPolicy: nil)
        XCTAssertEqual(styleManager.setStyleURIStub.invocations.count, 1, "nil policy should behave like .onlyIfChanged")
    }

    func testAlwaysReloadTriggersStyleLoadedEvent() throws {
        var callbacks: RuntimeStylingCallbacks?
        styleManager.setStyleURIStub.defaultSideEffect = { invoc in
            self.styleManager.isStyleLoadedStub.defaultReturnValue = false
            callbacks = invoc.parameters.callbacks
        }

        // Load and complete initial style
        me.mapStyle = MapStyle(uri: .standard)
        simulateLoad(callbacks: try XCTUnwrap(callbacks), result: .success)

        // Always reload should trigger another load
        var reloadCompleted = false
        me.loadStyle(MapStyle(uri: .standard, reloadPolicy: .always)) { error in
            XCTAssertNil(error)
            reloadCompleted = true
        }

        simulateLoad(callbacks: try XCTUnwrap(callbacks), result: .success)
        XCTAssertTrue(reloadCompleted, "Always reload completion should be called")
    }
}
