import XCTest
import MapboxMaps
import Hammer

final class SingleTapGestureTestCase: GestureTestCase {

    func testIdleEventNotEmittedAfterSingleTap() async throws {
        mapView.mapboxMap.loadStyle(.standard)

        let setupExpectation = expectation(description: "Map setup")
        didBecomeIdle = { [weak self] mapView in
            guard let self else { return }
            let expectation = expectation(description: "Map should not report idling after a single tap")
            expectation.isInverted = true
            mapView.mapboxMap.onMapIdle.observe { _ in
                expectation.fulfill()
            }.store(in: &cancelables)

            try! eventGenerator.fingerTap(.rightIndex)

            setupExpectation.fulfill()
            wait(for: [expectation], timeout: 5)
        }

        await fulfillment(of: [setupExpectation], timeout: 10)
    }

    /// Regression test for the SwiftUI `Map.onMapTapGesture` firing when a user taps
    /// a `MapViewAnnotation`. ViewAnnotations must be transparent to drag-like gestures
    /// (pan/pinch/rotate) but opaque to single taps.
    func testSingleTapOnViewAnnotationDoesNotPropagateToMap() async throws {
        mapView.mapboxMap.loadStyle(.standard)

        let setupExpectation = expectation(description: "Map setup")
        didBecomeIdle = { [weak self] mapView in
            guard let self else { return }
            // Prevent re-entry on subsequent idle events.
            didBecomeIdle = nil

            let annotationView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            annotationView.backgroundColor = .red
            let annotation = ViewAnnotation(coordinate: camera.center, view: annotationView)
            annotation.allowOverlap = true

            let visibleExpectation = expectation(description: "View annotation became visible")
            annotation.onVisibilityChanged = { visible in
                if visible { visibleExpectation.fulfill() }
            }
            mapView.viewAnnotations.add(annotation)
            wait(for: [visibleExpectation], timeout: 5)

            let onAnnotationTap = expectation(
                description: "map tap must NOT fire when the tap targets a view annotation"
            )
            onAnnotationTap.isInverted = true
            let offMapTap = expectation(
                description: "map tap must fire when the tap lands outside the view annotation"
            )
            var didTapAnnotation = false
            mapView.mapboxMap.addInteraction(TapInteraction { _ in
                if didTapAnnotation {
                    offMapTap.fulfill()
                } else {
                    onAnnotationTap.fulfill()
                }
                return true
            })

            try! eventGenerator.fingerTap(.rightIndex, at: annotationView)
            wait(for: [onAnnotationTap], timeout: 2)

            didTapAnnotation = true
            // Tap well clear of the 80x80 annotation centered on the screen.
            try! eventGenerator.fingerTap(.rightIndex, at: OffsetLocation(location: annotationView, x: 120, y: 0))
            wait(for: [offMapTap], timeout: 5)

            setupExpectation.fulfill()
        }

        await fulfillment(of: [setupExpectation], timeout: 30)
    }

    /// Sanity check: tapping the bare map (no annotation in the way) still fires `onMapTap`.
    /// Guards against an over-correction that would silence single taps entirely.
    func testSingleTapOnBareMapFiresOnMapTap() async throws {
        mapView.mapboxMap.loadStyle(.standard)

        let setupExpectation = expectation(description: "Map setup")
        didBecomeIdle = { [weak self] mapView in
            guard let self else { return }
            didBecomeIdle = nil

            let mapTapExpectation = expectation(description: "map tap fires on bare map tap")
            mapView.mapboxMap.addInteraction(TapInteraction { _ in
                mapTapExpectation.fulfill()
                return true
            })

            try! eventGenerator.fingerTap(.rightIndex)

            wait(for: [mapTapExpectation], timeout: 5)
            setupExpectation.fulfill()
        }

        await fulfillment(of: [setupExpectation], timeout: 30)
    }
}
