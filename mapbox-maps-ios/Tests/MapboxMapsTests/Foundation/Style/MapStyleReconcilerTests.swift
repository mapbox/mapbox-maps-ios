@_spi(Experimental) @testable import MapboxMaps
import XCTest

final class MapStyleReconcilerTests: XCTestCase {
    var me: MapStyleReconciler!
    var styleManager: MockStyleManager!

    @TestSignal var styleDataLoaded: Signal<StyleDataLoaded>

    override func setUp() {
        super.setUp()
        styleManager = MockStyleManager()
        styleManager.isStyleLoadedStub.defaultReturnValue = true
        me = MapStyleReconciler(coreStyleManager: styleManager, onStyleDataLoaded: styleDataLoaded)
    }

    override func tearDown() {
        super.tearDown()
        resetAllStubs()
        me = nil
        styleManager = nil
    }

    func testLoadsJSONStyle() {
        styleManager.setStyleJSONForJsonStub.defaultSideEffect = { _ in
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

        XCTAssertEqual(styleManager.setStyleJSONForJsonStub.invocations.count, 1)
        XCTAssertEqual(styleManager.setStyleJSONForJsonStub.invocations.last?.parameters, json)

        XCTAssertEqual(styleManager.setStyleImportConfigPropertyForImportIdStub.invocations.count, 0, "don't apply import config before load")

        // style is loaded
        $styleDataLoaded.send(StyleDataLoaded(type: .style, timeInterval: EventTimeInterval(begin: Date(), end: Date())))

        let inv = styleManager.setStyleImportConfigPropertyForImportIdStub.invocations
        XCTAssertEqual(inv.count, 1)
        XCTAssertEqual(inv.last?.parameters.importId, "foo")
        XCTAssertEqual(inv.last?.parameters.config, "bar")
        XCTAssertEqual(inv.last?.parameters.value as? String, "baz")
    }

    func testLoadsURIStyle() {
        styleManager.setStyleURIForUriStub.defaultSideEffect = { _ in
            self.styleManager.isStyleLoadedStub.defaultReturnValue = false
        }

        me.mapStyle = .init(uri: .streets, importConfigurations: [
            .init(importId: "foo", config: [
                "bar": "baz"
            ])
        ])

        XCTAssertEqual(styleManager.setStyleURIForUriStub.invocations.count, 1)
        XCTAssertEqual(styleManager.setStyleURIForUriStub.invocations.last?.parameters, StyleURI.streets.rawValue)

        XCTAssertEqual(styleManager.setStyleImportConfigPropertyForImportIdStub.invocations.count, 0, "don't apply import config before load")

        // style is loaded
        $styleDataLoaded.send(StyleDataLoaded(type: .style, timeInterval: EventTimeInterval(begin: Date(), end: Date())))

        let inv = styleManager.setStyleImportConfigPropertyForImportIdStub.invocations
        XCTAssertEqual(inv.count, 1)
        XCTAssertEqual(inv.last?.parameters.importId, "foo")
        XCTAssertEqual(inv.last?.parameters.config, "bar")
        XCTAssertEqual(inv.last?.parameters.value as? String, "baz")
    }

    func testDoubleLoad() {

        styleManager.setStyleURIForUriStub.defaultSideEffect = { _ in
            self.styleManager.isStyleLoadedStub.defaultReturnValue = false
        }

        me.mapStyle = MapStyle(uri: .outdoors, importConfigurations: [
            .init(importId: "foo-1", config: ["k-1": "v-1", "a": "b"])
        ])
        me.mapStyle = MapStyle(uri: .streets, importConfigurations: [
            .init(importId: "foo-2", config: ["k-2": "v-2"])
        ])

        XCTAssertEqual(styleManager.setStyleURIForUriStub.invocations.map(\.parameters), [
            StyleURI.outdoors.rawValue,
            StyleURI.streets.rawValue
        ])

        // style is loaded
        $styleDataLoaded.send(StyleDataLoaded(type: .style, timeInterval: EventTimeInterval(begin: Date(), end: Date())))

        // the first style update is skipped.
        let inv = styleManager.setStyleImportConfigPropertyForImportIdStub.invocations
        XCTAssertEqual(inv.count, 1)
        XCTAssertEqual(inv.last?.parameters.importId, "foo-2")
        XCTAssertEqual(inv.last?.parameters.config, "k-2")
        XCTAssertEqual(inv.last?.parameters.value as? String, "v-2")
    }

    func testStyleImportsReconcileFromNil() {
        MapStyleReconciler.reconcileStyleImports(
            from: nil,
            to: [
                StyleImportConfiguration(
                    importId: "foo",
                    config: ["bar": "baz"])
            ],
            coreStyleManager: styleManager)

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
            coreStyleManager: styleManager)

        let inv = styleManager.setStyleImportConfigPropertyForImportIdStub.invocations
        XCTAssertEqual(inv.count, 1)
        XCTAssertEqual(inv.last?.parameters.importId, "foo")
        XCTAssertEqual(inv.last?.parameters.config, "qux")
        XCTAssertEqual(inv.last?.parameters.value as? String, "quux")
    }
}
