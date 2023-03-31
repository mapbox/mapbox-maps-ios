import Foundation
import XCTest
@testable import MapboxMaps

final class AnnotationOrchestratorImplTests: XCTestCase {
    var tapGestureRecognizer: MockGestureRecognizer!
    var longPressGestureRecognizer: MockLongPressGestureRecognizer!
    var mapFeatureQueryable: MockMapFeatureQueryable!
    var style: MockStyle!
    var displayLinkCoordinator: MockDisplayLinkCoordinator!
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
        displayLinkCoordinator = MockDisplayLinkCoordinator()
        offsetPointCalculator = OffsetPointCalculator(mapboxMap: MockMapboxMap())
        offsetLineStringCalculator = OffsetLineStringCalculator(mapboxMap: MockMapboxMap())
        offsetPolygonCalculator = OffsetPolygonCalculator(mapboxMap: MockMapboxMap())
        factory = MockAnnotationManagerFactory()
        impl = AnnotationOrchestratorImpl(
            tapGestureRecognizer: tapGestureRecognizer,
            longPressGestureRecognizer: longPressGestureRecognizer,
            mapFeatureQueryable: mapFeatureQueryable,
            factory: factory)
    }

    override func tearDown() {
        super.tearDown()

        tapGestureRecognizer = nil
        longPressGestureRecognizer = nil
        mapFeatureQueryable = nil
        style = nil
        displayLinkCoordinator = nil
        offsetPointCalculator = nil
        offsetLineStringCalculator = nil
        offsetPolygonCalculator = nil
        factory = nil
        impl = nil
    }

    func testGesturesDisabledOnInit() {
        XCTAssertFalse(tapGestureRecognizer.isEnabled)
        XCTAssertFalse(longPressGestureRecognizer.isEnabled)
    }

    func testGesturesEnabled() {
        let managerId = "test-manager"

        let factories: [(String, LayerPosition?) -> AnnotationManagerInternal] = [
            impl.makeCircleAnnotationManager,
            impl.makePolygonAnnotationManager,
            impl.makePolylineAnnotationManager,
            impl.makePointAnnotationManager,
        ]

        for factory in factories {
            _ = factory(managerId, nil)
        }

        XCTAssertTrue(tapGestureRecognizer.isEnabled)
        XCTAssertTrue(longPressGestureRecognizer.isEnabled)

        for _ in factories {
            impl.removeAnnotationManager(withId: managerId)
        }

        XCTAssertFalse(tapGestureRecognizer.isEnabled)
        XCTAssertFalse(longPressGestureRecognizer.isEnabled)
    }

    func testSingleTapRecognizesSimultaneouslyWithOtherTapRecognizer() {
        let shouldRecognizeSimultaneously = impl.gestureRecognizer(
            tapGestureRecognizer,
            shouldRecognizeSimultaneouslyWith: UITapGestureRecognizer()
        )

        XCTAssertTrue(shouldRecognizeSimultaneously)
    }

    func testLongPressRecognizesSimultaneouslyWithOtherLongPressRecognizer() {
        let shouldRecognizeSimultaneously = impl.gestureRecognizer(
            longPressGestureRecognizer,
            shouldRecognizeSimultaneouslyWith: UILongPressGestureRecognizer()
        )

        XCTAssertTrue(shouldRecognizeSimultaneously)
    }

    func testLongPressRecognizesSimultaneouslyWithMapboxLongPressRecognizer() {
        let shouldRecognizeSimultaneously = impl.gestureRecognizer(
            longPressGestureRecognizer,
            shouldRecognizeSimultaneouslyWith: MapboxLongPressGestureRecognizer()
        )

        XCTAssertTrue(shouldRecognizeSimultaneously)
    }

    func testSingleTapShouldNotRecognizeSimultaneouslyWithNonTapGesture() {
        let recognizers = [
            UIPanGestureRecognizer(),
            UILongPressGestureRecognizer(),
            UISwipeGestureRecognizer(),
            UIScreenEdgePanGestureRecognizer(),
            UIPinchGestureRecognizer(),
            UIRotationGestureRecognizer()
        ]

        for recognizer in recognizers {
            let shouldRecognizeSimultaneously = impl.gestureRecognizer(
                tapGestureRecognizer,
                shouldRecognizeSimultaneouslyWith: recognizer
            )

            XCTAssertFalse(shouldRecognizeSimultaneously)
        }
    }

    func testLongPressShouldNotRecognizeSimultaneouslyWithNonLongPressGesture() {
        let recognizers = [
            UIPanGestureRecognizer(),
            UITapGestureRecognizer(),
            UISwipeGestureRecognizer(),
            UIScreenEdgePanGestureRecognizer(),
            UIPinchGestureRecognizer(),
            UIRotationGestureRecognizer()
        ]

        for recognizer in recognizers {
            let shouldRecognizeSimultaneously = impl.gestureRecognizer(
                longPressGestureRecognizer,
                shouldRecognizeSimultaneouslyWith: recognizer
            )

            XCTAssertFalse(shouldRecognizeSimultaneously)
        }
    }

    func testShouldNotRecognizeSimultaneouslyWithUnrecognizedGestureRecognizer() {
        let recognizers = [
            UILongPressGestureRecognizer(),
            UIPanGestureRecognizer(),
            UITapGestureRecognizer(),
            UISwipeGestureRecognizer(),
            UIScreenEdgePanGestureRecognizer(),
            UIPinchGestureRecognizer(),
            UIRotationGestureRecognizer()
        ]

        for outerRecognizer in recognizers {
            for innerRecognizer in recognizers {
                let shouldRecognizeSimultaneously = impl.gestureRecognizer(
                    outerRecognizer,
                    shouldRecognizeSimultaneouslyWith: innerRecognizer
                )

                XCTAssertFalse(shouldRecognizeSimultaneously)
            }
        }
    }

    func testMakePointAnnotationManagers() {
        //given
        let annotationManagerId = UUID().uuidString
        let clusterOptions: ClusterOptions? = .random(ClusterOptions())

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

    func testAnnotationOrchestratorProxiesGestureDragEnd() {
        // given
        let annotationManagerLayerId = "managerId"
        let annotationManager = MockAnnotationManager()
        factory.makePolygonAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makePolylineAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makeCircleAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makePointAnnotationManagerStub.defaultReturnValue = annotationManager
        longPressGestureRecognizer.getStateStub.defaultReturnValue = .ended
        let factories: [(String, LayerPosition?) -> AnnotationManagerInternal] = [
            impl.makeCircleAnnotationManager,
            impl.makePolygonAnnotationManager,
            impl.makePolylineAnnotationManager,
            impl.makePointAnnotationManager,
        ]

        for factory in factories {
            _ = factory(annotationManagerLayerId, nil)

            // when
            longPressGestureRecognizer.sendActions()
        }

        // then
        XCTAssertEqual(annotationManager.handleDragEndedStub.invocations.count, 4)
    }

    func testAnnotationOrchestratorDragGestureBeginInvokesQueriesRenderedFeatures() {
        // given
        let annotationManagerLayerId = "managerId"
        let annotationManager = MockAnnotationManager()
        annotationManager.$allLayerIds.getStub.defaultReturnValue = [annotationManagerLayerId]
        factory.makePolygonAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makeCircleAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makePolylineAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makePointAnnotationManagerStub.defaultReturnValue = annotationManager
        longPressGestureRecognizer.getStateStub.defaultReturnValue = .began
        let factories: [(String, LayerPosition?) -> AnnotationManagerInternal] = [
            impl.makeCircleAnnotationManager,
            impl.makePolygonAnnotationManager,
            impl.makePolylineAnnotationManager,
            impl.makePointAnnotationManager,
        ]

        for factory in factories {
            _ = factory(annotationManagerLayerId, nil)

            // when
            longPressGestureRecognizer.sendActions()
        }

        // then
        XCTAssertEqual(mapFeatureQueryable.queryRenderedFeaturesAtStub.invocations.count, 4)
        XCTAssertEqual(mapFeatureQueryable.queryRenderedFeaturesAtStub.invocations.first?.parameters.options?.layerIds, [annotationManagerLayerId])
    }

    func testAnnotationOrchestratorDragGestureBeginNotifiesAnnotationManagersAboutQRFSuccess() {
        // given
        let annotationManagerLayerId = "managerId"
        let annotationManager = MockAnnotationManager()
        let featureIdentifier = "feature"
        factory.makePolygonAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makeCircleAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makePolylineAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makePointAnnotationManagerStub.defaultReturnValue = annotationManager
        longPressGestureRecognizer.getStateStub.defaultReturnValue = .began
        let factories: [(String, LayerPosition?) -> AnnotationManagerInternal] = [
            impl.makeCircleAnnotationManager,
            impl.makePolygonAnnotationManager,
            impl.makePolylineAnnotationManager,
            impl.makePointAnnotationManager,
        ]

        for factory in factories {
            _ = factory(annotationManagerLayerId, nil)

            // when
            longPressGestureRecognizer.sendActions()
            let qrfCompletions: (Result<[QueriedFeature], Error>) -> Void = try! XCTUnwrap(mapFeatureQueryable.queryRenderedFeaturesAtStub.invocations.first?.parameters.completion)
            let feature = QueriedFeature.init(
                __feature: MapboxCommon.Feature.init(
                    identifier: featureIdentifier as NSObject,
                    geometry: MapboxCommon.Geometry(Point(.init(latitude: 0, longitude: 0))),
                    properties: [:]),
                source: "feature-source",
                sourceLayer: nil,
                state: "feature-state"
            )

            qrfCompletions(.success([feature]))

        }

        // then
        XCTAssertEqual(annotationManager.handleDragBeginStub.invocations.count, 4)
        XCTAssertEqual(annotationManager.handleDragBeginStub.invocations.first!.parameters.first, featureIdentifier)
    }

    enum TestError: Error {
        case test
    }
    func testAnnotationOrchestratorDragGestureBeginIgnoresQRFFailure() {
        // given
        let annotationManagerLayerId = "managerId"
        let annotationManager = MockAnnotationManager()
        factory.makeCircleAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makePolygonAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makePolylineAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makePointAnnotationManagerStub.defaultReturnValue = annotationManager
        longPressGestureRecognizer.getStateStub.defaultReturnValue = .began
        let factories: [(String, LayerPosition?) -> AnnotationManagerInternal] = [
            impl.makeCircleAnnotationManager,
            impl.makePolygonAnnotationManager,
            impl.makePolylineAnnotationManager,
            impl.makePointAnnotationManager,
        ]

        for factory in factories {
            _ = factory(annotationManagerLayerId, nil)

            // when
            longPressGestureRecognizer.sendActions()
            let qrfCompletions: (Result<[QueriedFeature], Error>) -> Void = (mapFeatureQueryable.queryRenderedFeaturesAtStub.invocations.first?.parameters.completion)!

            qrfCompletions(.failure(TestError.test))

            // then
            XCTAssertEqual(annotationManager.handleDragBeginStub.invocations.count, 0)
        }

    }

}

extension AnnotationOrchestratorImpl {
    func makePointAnnotationManager(id: String, layerPosition: LayerPosition?) -> AnnotationManagerInternal {
        return makePointAnnotationManager(id: id, layerPosition: layerPosition, clusterOptions: nil)
    }
}
