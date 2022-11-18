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
        impl = AnnotationOrchestratorImpl(
            tapGestureRecognizer: tapGestureRecognizer,
            longPressGestureRecognizer: longPressGestureRecognizer,
            mapFeatureQueryable: mapFeatureQueryable,
            style: style,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetPointCalculator: offsetPointCalculator,
            offsetLineStringCalculator: offsetLineStringCalculator,
            offsetPolygonCalculator: offsetPolygonCalculator
        )
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
}
