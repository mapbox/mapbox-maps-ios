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

    func testAnnotationOrchestratorProxiesGestureDragEndForAllManagersButPoint() {
        // given
        let annotationManagerLayerId = "managerId"
        let annotationManager = MockAnnotationManager()
        factory.makePolygonAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makePolylineAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makeCircleAnnotationManagerStub.defaultReturnValue = annotationManager
        longPressGestureRecognizer.getStateStub.defaultReturnValue = .ended
        let factories: [(String, LayerPosition?) -> AnnotationManagerInternal] = [
            impl.makeCircleAnnotationManager,
            impl.makePolygonAnnotationManager,
            impl.makePolylineAnnotationManager,
        ]

        for factory in factories {
            _ = factory(annotationManagerLayerId, nil)
        }

        // when
        longPressGestureRecognizer.sendActions()

        // then
        XCTAssertEqual(annotationManager.handleDragEndedStub.invocations.count, 1)
    }

    func testAnnotationOrchestratorProxiesGestureDragEndForPointManager() {
        // given
        let annotationManagerLayerId = "managerId"
        let annotationManager = MockAnnotationManager()
        factory.makePointAnnotationManagerStub.defaultReturnValue = annotationManager
        longPressGestureRecognizer.getStateStub.defaultReturnValue = .ended
        _ = impl.makePointAnnotationManager(id: annotationManagerLayerId, layerPosition: nil, clusterOptions: nil)

        // when
        longPressGestureRecognizer.sendActions()

        // then
        XCTAssertEqual(annotationManager.handleDragEndedStub.invocations.count, 1)
    }

    func testAnnotationOrchestratorDragGestureBeginInvokesQueriesRenderedFeaturesForAllManagersExceptPoint() {
        // given
        let annotationManagerLayerId = "managerId"
        let annotationManager = MockAnnotationManager()
        annotationManager.$layerId.getStub.defaultReturnValue = annotationManagerLayerId
        factory.makePolygonAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makeCircleAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makePolylineAnnotationManagerStub.defaultReturnValue = annotationManager
        longPressGestureRecognizer.getStateStub.defaultReturnValue = .began
        _ = impl?.makePolygonAnnotationManager(id: annotationManagerLayerId, layerPosition: nil)

        // when
        longPressGestureRecognizer.sendActions()

        // then
        XCTAssertEqual(mapFeatureQueryable.queryRenderedFeaturesAtStub.invocations.count, 1)
        XCTAssertEqual(mapFeatureQueryable.queryRenderedFeaturesAtStub.invocations.first?.parameters.options?.layerIds, [annotationManagerLayerId])
    }

    func testAnnotationOrchestratorDragGestureBeginInvokesQueriesRenderedFeaturesForPointManager() {
        // given
        let annotationManagerLayerId = "managerId"
        let annotationManager = MockAnnotationManager()
        annotationManager.$layerId.getStub.defaultReturnValue = annotationManagerLayerId
        factory.makePointAnnotationManagerStub.defaultReturnValue = annotationManager
        longPressGestureRecognizer.getStateStub.defaultReturnValue = .began
        _ = impl?.makePointAnnotationManager(id: annotationManagerLayerId, layerPosition: nil, clusterOptions: nil)

        // when
        longPressGestureRecognizer.sendActions()

        // then
        XCTAssertEqual(mapFeatureQueryable.queryRenderedFeaturesAtStub.invocations.count, 1)
        XCTAssertEqual(mapFeatureQueryable.queryRenderedFeaturesAtStub.invocations.first?.parameters.options?.layerIds, [annotationManagerLayerId])
    }

    func testAnnotationOrchestratorDragGestureBeginNotifiesAnnotationManagersAboutQRFSuccessForAllManagersExceptPoint() {
        // given
        let annotationManagerLayerId = "managerId"
        let annotationManager = MockAnnotationManager()
        factory.makePolygonAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makeCircleAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makePolylineAnnotationManagerStub.defaultReturnValue = annotationManager
        longPressGestureRecognizer.getStateStub.defaultReturnValue = .began
        _ = impl?.makePolygonAnnotationManager(id: annotationManagerLayerId, layerPosition: nil)

        // when
        longPressGestureRecognizer.sendActions()
        let qrfCompletions: (Result<[QueriedFeature], Error>) -> Void = (mapFeatureQueryable.queryRenderedFeaturesAtStub.invocations.first?.parameters.completion)!
        let featureIdentifier = "feature"
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

        // then
        XCTAssertEqual(annotationManager.handleDragBeginStub.invocations.count, 1)
        XCTAssertEqual(annotationManager.handleDragBeginStub.invocations.first!.parameters.first, featureIdentifier)
    }

    func testAnnotationOrchestratorDragGestureBeginNotifiesAnnotationManagersAboutQRFSuccessForPointManager() {
        // given
        let annotationManagerLayerId = "managerId"
        let annotationManager = MockAnnotationManager()

        factory.makePointAnnotationManagerStub.defaultReturnValue = annotationManager
        longPressGestureRecognizer.getStateStub.defaultReturnValue = .began
        _ = impl?.makePointAnnotationManager(id: annotationManagerLayerId, layerPosition: nil, clusterOptions: nil)

        // when
        longPressGestureRecognizer.sendActions()
        let qrfCompletions: (Result<[QueriedFeature], Error>) -> Void = (mapFeatureQueryable.queryRenderedFeaturesAtStub.invocations.first?.parameters.completion)!
        let featureIdentifier = "feature"
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

        // then
        XCTAssertEqual(annotationManager.handleDragBeginStub.invocations.count, 1)
        XCTAssertEqual(annotationManager.handleDragBeginStub.invocations.first!.parameters.first, featureIdentifier)
    }

    enum TestError: Error {
        case test
    }
    func testAnnotationOrchestratorDragGestureBeginIgnoresQRFFailureForAllManagersExceptPoint() {
        // given
        let annotationManagerLayerId = "managerId"
        let annotationManager = MockAnnotationManager()
        factory.makeCircleAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makePolygonAnnotationManagerStub.defaultReturnValue = annotationManager
        factory.makePolylineAnnotationManagerStub.defaultReturnValue = annotationManager
        longPressGestureRecognizer.getStateStub.defaultReturnValue = .began
        let factories: [(String, LayerPosition?) -> AnnotationManagerInternal] = [
            impl.makeCircleAnnotationManager,
            impl.makePolygonAnnotationManager,
            impl.makePolylineAnnotationManager,
        ]

        for factory in factories {
            //            factoryStubs = annotationManager
            _ = factory(annotationManagerLayerId, nil)

            // when
            longPressGestureRecognizer.sendActions()
            let qrfCompletions: (Result<[QueriedFeature], Error>) -> Void = (mapFeatureQueryable.queryRenderedFeaturesAtStub.invocations.first?.parameters.completion)!
            let featureIdentifier = "feature"

            qrfCompletions(.failure(TestError.test))

            // then
            XCTAssertEqual(annotationManager.handleDragBeginStub.invocations.count, 0)
        }

    }

    func testAnnotationOrchestratorDragGestureBeginIgnoresQRFFailureForPointManager() {
        // given
        let annotationManagerLayerId = "managerId"
        let annotationManager = MockAnnotationManager()
        factory.makePointAnnotationManagerStub.defaultReturnValue = annotationManager
        longPressGestureRecognizer.getStateStub.defaultReturnValue = .began
        _ = impl?.makePointAnnotationManager(id: annotationManagerLayerId, layerPosition: nil, clusterOptions: nil)

        // when
        longPressGestureRecognizer.sendActions()
        let qrfCompletions: (Result<[QueriedFeature], Error>) -> Void = (mapFeatureQueryable.queryRenderedFeaturesAtStub.invocations.first?.parameters.completion)!

        qrfCompletions(.failure(TestError.test))

        // then
        XCTAssertEqual(annotationManager.handleDragBeginStub.invocations.count, 0)

    }

}
