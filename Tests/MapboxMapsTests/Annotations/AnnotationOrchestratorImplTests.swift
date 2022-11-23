import Foundation
import XCTest
@testable import MapboxMaps

final class AnnotationOrchestratorImplTests: XCTestCase {
    var tapGestureRecognizer: MockGestureRecognizer!
    var longPressGestureRecognizer: MapboxLongPressGestureRecognizer!
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
        longPressGestureRecognizer = MapboxLongPressGestureRecognizer()
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
            style: style,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetPointCalculator: offsetPointCalculator,
            offsetLineStringCalculator: offsetLineStringCalculator,
            offsetPolygonCalculator: offsetPolygonCalculator,
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

    func testAnnotationOrchestratorProxiesGestureDragEnd() {
        // given
        let annotationManager = MockAnnotationManager()
        let factory = MockAnnotationManagerFactory()
        factory.makePolygonAnnotationManagerStub.defaultReturnValue = annotationManager
        let recognizer = MockLongPressGestureRecognizer()
        let impl = impl
        recognizer.getStateStub.defaultReturnValue = .ended
        _ = impl?.makePolygonAnnotationManager(id: "sfsdf", layerPosition: nil)

        // when
        recognizer.sendActions()

        // then
        XCTAssertEqual(annotationManager.handleDragEndedStub.invocations.count, 1)
    }

    func testAnnotationOrchestratorDragGestureBeginInvokesQueriesRenderedFeatures() {
        // given
        let annotationManagerLayerId = "sdfsdfdsf"
        let annotationManager = MockAnnotationManager()
        let factory = MockAnnotationManagerFactory()
        factory.makePolygonAnnotationManagerStub.defaultReturnValue = annotationManager
        let recognizer = MockLongPressGestureRecognizer()
        let mapFeatureQueryable = MockMapFeatureQueryable()
        let impl = impl
        recognizer.getStateStub.defaultReturnValue = .began
        _ = impl?.makePolygonAnnotationManager(id: annotationManagerLayerId, layerPosition: nil)

        // when
        recognizer.sendActions()

        // then
        XCTAssertEqual(mapFeatureQueryable.queryRenderedFeaturesAtStub.invocations.count, 1)
        XCTAssertEqual(mapFeatureQueryable.queryRenderedFeaturesAtStub.invocations.first?.parameters.options?.layerIds, [annotationManagerLayerId])
    }

    func testAnnotationOrchestratorDragGestureBeginNotifiesAnnotationManagersAboutQRFSuccess() {
        // given
        let annotationManagerLayerId = "sdfsdfdsf"
        let annotationManager = MockAnnotationManager()
        let factory = MockAnnotationManagerFactory()
        factory.makePolygonAnnotationManagerStub.defaultReturnValue = annotationManager
        let recognizer = MockLongPressGestureRecognizer()
        let mapFeatureQueryable = MockMapFeatureQueryable()
        let impl = impl
        recognizer.getStateStub.defaultReturnValue = .began
        _ = impl?.makePolygonAnnotationManager(id: annotationManagerLayerId, layerPosition: nil)

        // when
        recognizer.sendActions()
        let qrfCompletions: (Result<[QueriedFeature], Error>) -> Void = (mapFeatureQueryable.queryRenderedFeaturesAtStub.invocations.first?.parameters.completion)!
        let featureIdentifier = "dsfsdfsdfdsfdsf"
        let feature = QueriedFeature.init(
            __feature: MapboxCommon.Feature.init(
                identifier: featureIdentifier as NSObject,
                geometry: MapboxCommon.Geometry(Point(.init(latitude: 0, longitude: 0))),
                properties: [:]),
            source: "sdfdssf",
            sourceLayer: nil,
            state: "dsfsf"
        )

        qrfCompletions(.success([feature]))

        // then
        XCTAssertEqual(annotationManager.handleDragBeginStub.invocations.count, 1)
        XCTAssertEqual(annotationManager.handleDragBeginStub.invocations.first?.parameters.featureIdentifier, featureIdentifier)

    }

    enum TestError: Error {
        case test
    }
    func testAnnotationOrchestratorDragGestureBeginIgnoresQRFFailure() {
        // given
        let annotationManagerLayerId = "sdfsdfdsf"
        let annotationManager = MockAnnotationManager()
        let factory = MockAnnotationManagerFactory()
        factory.makePolygonAnnotationManagerStub.defaultReturnValue = annotationManager
        let recognizer = MockLongPressGestureRecognizer()
        let mapFeatureQueryable = MockMapFeatureQueryable()
        let impl = impl
        recognizer.getStateStub.defaultReturnValue = .began
        _ = impl?.makePolygonAnnotationManager(id: annotationManagerLayerId, layerPosition: nil)


        // when
        recognizer.sendActions()
        let qrfCompletions: (Result<[QueriedFeature], Error>) -> Void = (mapFeatureQueryable.queryRenderedFeaturesAtStub.invocations.first?.parameters.completion)!
        let featureIdentifier = "dsfsdfsdfdsfdsf"

        qrfCompletions(.failure(TestError.test))

        // then
        XCTAssertEqual(annotationManager.handleDragBeginStub.invocations.count, 0)

    }

}
