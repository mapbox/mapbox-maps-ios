import XCTest
@_spi(Experimental) @testable import MapboxMaps

@available(iOS 13.0, *)
final class AnnotationGroupTests: XCTestCase {
    private var orchestrator: AnnotationOrchestrator!
    private var orchestratorImpl: MockAnnotationOrchestatorImpl!

    override func setUp() {
        super.setUp()

        orchestratorImpl = MockAnnotationOrchestatorImpl()
        orchestrator = AnnotationOrchestrator(impl: orchestratorImpl)
    }

    override func tearDown() {
        resetAllStubs()
        orchestratorImpl = nil
        orchestrator = nil
        super.tearDown()
    }

    func testGroup() throws {
        let layerId = "layer-id"
        let resolvedId = "resolved-id"
        let layerPos = LayerPosition.at(42)
        var annotationIds = [AnyHashable: String]()

        // swiftlint:disable:next large_tuple
        var makeParams: (AnnotationOrchestrator, String, LayerPosition?)?
        var _manager: DummyAnnotationManager?

        // Create
        let store = ForEvery(data: [1], id: \.self) { _ in
            DummyAnnotation(property: "foo")
        }
        var group = AnnotationGroup(
            positionalId: 0,
            layerId: "layer-id",
            layerPosition: layerPos,
            store: store,
            make: {
                makeParams = ($0, $1, $2)
                _manager = DummyAnnotationManager(id: $1)
                return _manager!
            },
            updateProperties: { $0.property += 1 })

        XCTAssertEqual(group.layerId, layerId)

        group.update(orchestrator, resolvedId, &annotationIds)

        XCTAssertIdentical(makeParams?.0, orchestrator)
        XCTAssertEqual(makeParams?.1, resolvedId)
        XCTAssertEqual(makeParams?.2, layerPos)

        let manager = try XCTUnwrap(_manager)

        XCTAssertEqual(manager.isSwiftUI, true)
        XCTAssertEqual(manager.property, 1)
        XCTAssertEqual(manager.annotations.count, 1)
        let a1 = manager.annotations[0]
        XCTAssertEqual(a1.isSelected, false)
        XCTAssertEqual(a1.isDraggable, false)
        XCTAssertEqual(a1.property, "foo")

        // Update
        orchestratorImpl.annotationManagersById[resolvedId] = manager

        let store2 = ForEvery(data: [1, 2], id: \.self) { _ in
            DummyAnnotation(property: "bar")
        }
        group = AnnotationGroup(
            positionalId: 0,
            layerId: "layer-id",
            layerPosition: layerPos,
            store: store2,
            make: { _, _, _ in
                XCTFail("should reuse manager")
                return DummyAnnotationManager(id: "error")
            },
            updateProperties: { $0.property += 1 })

        group.update(orchestrator, resolvedId, &annotationIds)

        XCTAssertEqual(manager.isSwiftUI, true)
        XCTAssertEqual(manager.property, 2)
        XCTAssertEqual(manager.annotations.count, 2)
        let newA1 = try XCTUnwrap(manager.annotations.first)
        let newA2 = try XCTUnwrap(manager.annotations.last)
        XCTAssertEqual(newA1.id, a1.id)
        XCTAssertEqual(newA1.isSelected, false)
        XCTAssertEqual(newA1.isDraggable, false)
        XCTAssertEqual(newA1.property, "bar")
        XCTAssertEqual(newA2.isSelected, false)
        XCTAssertEqual(newA2.isDraggable, false)
        XCTAssertEqual(newA2.property, "bar")
    }
}

private class DummyAnnotation: MapContentAnnotation {
    var id: String = UUID().uuidString
    var property: String
    var isDraggable: Bool = true
    var isSelected: Bool = true
    init(property: String) {
        self.property = property
    }
}

private class DummyAnnotationManager: MapContentAnnotationManager, AnnotationManager {
    var id: String
    var sourceId: String { id }
    var layerId: String { id }

    var slot: String?

    var annotations = [DummyAnnotation]()
    var isSwiftUI: Bool = false
    var property: Int = 0
    init(id: String) {
        self.id = id
    }
}
