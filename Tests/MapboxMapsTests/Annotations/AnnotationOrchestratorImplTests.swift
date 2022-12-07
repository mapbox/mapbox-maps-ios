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

    func testGesturesEnableAndDisableForPointManager() {
        let managerId = "test-manager"
        _ = impl.makePointAnnotationManager(id: managerId, layerPosition: nil, clusterOptions: nil)

        XCTAssertTrue(tapGestureRecognizer.isEnabled)
        XCTAssertTrue(longPressGestureRecognizer.isEnabled)

        impl.removeAnnotationManager(withId: managerId)

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

    func testMakeAnnotationManagers() {
        //given
        let annotationManagerId = "managerId"
        let factories: [(String, LayerPosition?) -> AnnotationManager] = [
            impl.makeCircleAnnotationManager,
            impl.makePolygonAnnotationManager,
            impl.makePolylineAnnotationManager,
            impl.makePointAnnotationManager,
        ]

        for factory in factories {
            let newAnnotationManager = factory(annotationManagerId, nil)

            XCTAssertNotNil(impl.annotationManagersById[annotationManagerId] === newAnnotationManager)
            XCTAssertEqual(impl.annotationManagersById.count, 1)
        }
    }

    func testRemoveAnnotationManager() throws {
        var ids = Array.random(withLength: 10, generator: { UUID().uuidString })
        for id in ids {
            _ = impl.makeCircleAnnotationManager(id: id, layerPosition: nil)
            _ = impl.makePolygonAnnotationManager(id: id, layerPosition: nil)
            _ = impl.makePolylineAnnotationManager(id: id, layerPosition: nil)
            _ = impl.makePointAnnotationManager(id: id, layerPosition: nil)
        }

        // when
        impl.removeAnnotationManager(withId: UUID().uuidString)
        // then
        XCTAssertTrue(ids.allSatisfy(impl.annotationManagersById.keys.contains(_:)))

        // when
        let idToRemove = ids.removeFirst()
        impl.removeAnnotationManager(withId: idToRemove)

        // then
        XCTAssertNil(impl.annotationManagersById[idToRemove])
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
        annotationManager.$layerId.getStub.defaultReturnValue = annotationManagerLayerId
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
