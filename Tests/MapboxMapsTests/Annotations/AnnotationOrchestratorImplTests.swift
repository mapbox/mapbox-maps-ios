import Foundation
import XCTest
@testable import MapboxMaps

final class AnnotationOrchestratorImplTests: XCTestCase {
    var tapGestureRecognizer: MockGestureRecognizer!
    var longPressGestureRecognizer: MockLongPressGestureRecognizer!
    var mapFeatureQueryable: MockMapFeatureQueryable!
    var style: MockStyle!
    var offsetPointCalculator: OffsetPointCalculator!
    var offsetLineStringCalculator: OffsetLineStringCalculator!
    var offsetPolygonCalculator: OffsetPolygonCalculator!
    var factory: MockAnnotationManagerFactory!
    var impl: AnnotationOrchestratorImpl!

    override func setUp() {
        super.setUp()

        tapGestureRecognizer = MockGestureRecognizer()
        longPressGestureRecognizer = MockLongPressGestureRecognizer()
        mapFeatureQueryable = MockMapFeatureQueryable()
        style = MockStyle()
        offsetPointCalculator = OffsetPointCalculator(mapboxMap: MockMapboxMap())
        offsetLineStringCalculator = OffsetLineStringCalculator(mapboxMap: MockMapboxMap())
        offsetPolygonCalculator = OffsetPolygonCalculator(mapboxMap: MockMapboxMap())
        factory = MockAnnotationManagerFactory()
        impl = AnnotationOrchestratorImpl(factory: factory)
    }

    override func tearDown() {
        super.tearDown()

        tapGestureRecognizer = nil
        longPressGestureRecognizer = nil
        mapFeatureQueryable = nil
        style = nil
        offsetPointCalculator = nil
        offsetLineStringCalculator = nil
        offsetPolygonCalculator = nil
        factory = nil
        impl = nil
    }

    func testMakePointAnnotationManagers() {
        //given
        let annotationManagerId = UUID().uuidString
        let clusterOptions: ClusterOptions? = ClusterOptions()

        //when
        let manager = impl.makePointAnnotationManager(
            id: annotationManagerId,
            layerPosition: .default,
            clusterOptions: clusterOptions)

        //then
        XCTAssertNotNil(impl.annotationManagersById[annotationManagerId] === manager)
        XCTAssertEqual(impl.annotationManagersById.count, 1)
        XCTAssertEqual(factory.makePointAnnotationManagerStub.invocations.count, 1)

        let parameters = factory.makePointAnnotationManagerStub.invocations.last?.parameters
        XCTAssertEqual(parameters?.layerPosition, .default)
        XCTAssertEqual(parameters?.clusterOptions, clusterOptions)
        XCTAssertEqual(parameters?.id, annotationManagerId)
    }

    func testMakePolygonAnnotationManagers() {
        //given
        let annotationManagerId = UUID().uuidString

        //when
        let manager = impl.makePolygonAnnotationManager(id: annotationManagerId, layerPosition: .default)

        //then
        XCTAssertNotNil(impl.annotationManagersById[annotationManagerId] === manager)
        XCTAssertEqual(impl.annotationManagersById.count, 1)
        XCTAssertEqual(factory.makePolygonAnnotationManagerStub.invocations.count, 1)
    }

    func testMakePolylineAnnotationManagers() {
        //given
        let annotationManagerId = UUID().uuidString

        //when
        let manager = impl.makePolylineAnnotationManager(id: annotationManagerId, layerPosition: .default)

        //then
        XCTAssertNotNil(impl.annotationManagersById[annotationManagerId] === manager)
        XCTAssertEqual(impl.annotationManagersById.count, 1)
        XCTAssertEqual(factory.makePolylineAnnotationManagerStub.invocations.count, 1)
    }

    func testMakeCircleAnnotationManagers() {
        //given
        let annotationManagerId = UUID().uuidString

        //when
        let manager = impl.makeCircleAnnotationManager(id: annotationManagerId, layerPosition: .default)

        //then
        XCTAssertNotNil(impl.annotationManagersById[annotationManagerId] === manager)
        XCTAssertEqual(impl.annotationManagersById.count, 1)
        XCTAssertEqual(factory.makeCircleAnnotationManagerStub.invocations.count, 1)
    }

    func testRemovePointAnnotationManager() throws {
        let manager = MockAnnotationManager()
        factory.makePointAnnotationManagerStub.defaultReturnValue = manager
        var ids = Array.random(withLength: 10, generator: { UUID().uuidString })

        for id in ids {
            _ = impl.makePointAnnotationManager(id: id, layerPosition: nil)

            // when

            let idToRemove = ids.removeFirst()
            impl.removeAnnotationManager(withId: idToRemove)

            // then
            XCTAssertNil(impl.annotationManagersById[idToRemove])
        }
        XCTAssertEqual(manager.destroyStub.invocations.count, 10)
    }

    func testRemovePolygonAnnotationManager() throws {
        let manager = MockAnnotationManager()
        factory.makePolygonAnnotationManagerStub.defaultReturnValue = manager
        var ids = Array.random(withLength: 10, generator: { UUID().uuidString })
        for id in ids {
            _ = impl.makePolygonAnnotationManager(id: id, layerPosition: nil)

            // when
            let idToRemove = ids.removeFirst()
            impl.removeAnnotationManager(withId: idToRemove)

            // then
            XCTAssertNil(impl.annotationManagersById[idToRemove])
        }
        XCTAssertEqual(manager.destroyStub.invocations.count, 10)
    }

    func testRemovePolylineAnnotationManager() throws {
        let manager = MockAnnotationManager()
        factory.makePolylineAnnotationManagerStub.defaultReturnValue = manager
        var ids = Array.random(withLength: 10, generator: { UUID().uuidString })
        for id in ids {
            _ = impl.makePolylineAnnotationManager(id: id, layerPosition: nil)

            // when
            let idToRemove = ids.removeFirst()
            impl.removeAnnotationManager(withId: idToRemove)

            // then
            XCTAssertNil(impl.annotationManagersById[idToRemove])
        }
        XCTAssertEqual(manager.destroyStub.invocations.count, 10)
    }

    func testRemoveCircleAnnotationManager() throws {
        let manager = MockAnnotationManager()
        factory.makeCircleAnnotationManagerStub.defaultReturnValue = manager
        var ids = Array.random(withLength: 10, generator: { UUID().uuidString })
        for id in ids {
            _ = impl.makeCircleAnnotationManager(id: id, layerPosition: nil)

            // when
            let idToRemove = ids.removeFirst()
            impl.removeAnnotationManager(withId: idToRemove)

            // then
            XCTAssertNil(impl.annotationManagersById[idToRemove])
        }
        XCTAssertEqual(manager.destroyStub.invocations.count, 10)
    }

    func testManagersDestroy() {
        //given
        let id = "managerId"
        let manager = MockAnnotationManager()
        factory.makePointAnnotationManagerStub.defaultReturnValue = manager

        _ = impl.makePointAnnotationManager(id: id, layerPosition: nil, clusterOptions: nil)

        //when
        impl.removeAnnotationManager(withId: id)

        //then
        XCTAssertEqual(manager.destroyStub.invocations.count, 1)
    }
}

extension AnnotationOrchestratorImpl {
    func makePointAnnotationManager(id: String, layerPosition: LayerPosition?) -> AnnotationManagerInternal {
        return makePointAnnotationManager(id: id, layerPosition: layerPosition, clusterOptions: nil)
    }
}
