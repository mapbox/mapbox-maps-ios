import XCTest
import SwiftUI
@testable import MapboxMaps

/// `MapContent` mounted before the style loads is first walked on the style-load callback, outside SwiftUI's
/// tracked update — without a fix SwiftUI registers no `@State`/`@Binding` dependencies and later writes are dead.
final class SwiftUIMapContentFirstMountRerenderIntegrationTests: IntegrationTestCase {
    private struct ProbeContent: MapContent {
        @Binding var isHighlighted: Bool

        var body: some MapContent {
            BackgroundLayer(id: "probe-background")
                .backgroundColor(isHighlighted ? StyleColor(.yellow) : StyleColor(.gray))
        }
    }

    private struct ProbeMapView: View {
        @State private var isHighlighted = false
        let onMapReady: (MapboxMap) -> Void
        let onToggleReady: (@escaping () -> Void) -> Void

        var body: some View {
            MapReader { proxy in
                Map(initialViewport: .camera(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), zoom: 2)) {
                    ProbeContent(isHighlighted: $isHighlighted)
                }
                .onAppear {
                    if let map = proxy.map {
                        onMapReady(map)
                    }
                    onToggleReady { isHighlighted.toggle() }
                }
            }
        }
    }

    private var hostingController: UIHostingController<AnyView>?
    private var dataPathURL: URL!

    override func setUpWithError() throws {
        try guardForMetalDevice()
        try super.setUpWithError()
        dataPathURL = try temporaryCacheDirectory()
        MapboxMapsOptions.dataPath = dataPathURL
    }

    override func tearDownWithError() throws {
        // Let in-flight core work (sprite/tile loads) finish while the map is still alive — works around
        // teardown races in core where background replies fire at already-destroyed run loops.
        RunLoop.main.run(until: Date().addingTimeInterval(0.3))

        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        hostingController = nil

        let expectation = self.expectation(description: "Clear map data")
        MapboxMapsOptions.clearData { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)

        try super.tearDownWithError()
    }

    /// Polls `condition` on the main run loop until it returns true or `timeout` elapses.
    @discardableResult
    private func waitUntil(timeout: TimeInterval, condition: () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() && Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        }
        return condition()
    }

    /// The original bug: a layer color depends on `@State` and mounts before the style loads.
    /// Flipping the state after style load must change the actual layer property in the style.
    func testFirstMountMapContentReactsToStateChange() throws {
        guard let rootViewController, let rootView = rootViewController.view else {
            XCTFail("No valid root view controller")
            return
        }
        var capturedMap: MapboxMap?
        var toggle: (() -> Void)?
        let hosting = UIHostingController(rootView: AnyView(ProbeMapView(
            onMapReady: { map in capturedMap = map },
            onToggleReady: { action in toggle = action }
        )))
        hostingController = hosting

        rootViewController.addChild(hosting)
        rootView.addSubview(hosting.view)
        hosting.view.frame = rootView.bounds
        hosting.didMove(toParent: rootViewController)

        XCTAssertTrue(waitUntil(timeout: 5) { capturedMap != nil }, "MapboxMap never became available")
        let mapboxMap = try XCTUnwrap(capturedMap)

        XCTAssertTrue(waitUntil(timeout: 5) { toggle != nil }, "Toggle action never became available")

        // Polling instead of an `onStyleLoaded` subscription: the style may finish loading before any observer could attach.
        XCTAssertTrue(waitUntil(timeout: 10) { mapboxMap.layerExists(withId: "probe-background") }, "probe-background layer was never mounted")

        func currentBackgroundColor() -> String {
            "\(mapboxMap.layerPropertyValue(for: "probe-background", property: "background-color"))"
        }
        let colorBeforeToggle = currentBackgroundColor()

        toggle?()

        let reacted = waitUntil(timeout: 5) { currentBackgroundColor() != colorBeforeToggle }

        XCTAssertTrue(reacted, "MapContent was never re-evaluated after its state changed (stuck at \(colorBeforeToggle))")
    }

    /// Same bug, but the state is read inside a `MapViewAnnotation` view closure (the original demo case) —
    /// after flipping the state the closure must be re-evaluated with the new value.
    func testFirstMountViewAnnotationContentReactsToStateChange() throws {
        struct AnnotationProbeContent: MapContent {
            @Binding var isHighlighted: Bool
            let onEval: (Bool) -> Void

            var body: some MapContent {
                MapViewAnnotation(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)) {
                    Circle()
                        .fill(probeColor())
                        .frame(width: 40, height: 40)
                }
            }

            /// Reports every evaluation of the annotation view closure and the value it saw.
            private func probeColor() -> Color {
                onEval(isHighlighted)
                return isHighlighted ? .yellow : .gray
            }
        }

        struct AnnotationProbeMapView: View {
            @State private var isHighlighted = false
            let onEval: (Bool) -> Void
            let onToggleReady: (@escaping () -> Void) -> Void

            var body: some View {
                Map(initialViewport: .camera(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), zoom: 2)) {
                    AnnotationProbeContent(isHighlighted: $isHighlighted, onEval: onEval)
                }
                .onAppear {
                    onToggleReady { isHighlighted.toggle() }
                }
            }
        }

        guard let rootViewController, let rootView = rootViewController.view else {
            XCTFail("No valid root view controller")
            return
        }
        var toggle: (() -> Void)?
        var lastEvaluated: Bool?
        let hosting = UIHostingController(rootView: AnyView(AnnotationProbeMapView(
            onEval: { lastEvaluated = $0 },
            onToggleReady: { action in toggle = action }
        )))
        hostingController = hosting

        rootViewController.addChild(hosting)
        rootView.addSubview(hosting.view)
        hosting.view.frame = rootView.bounds
        hosting.didMove(toParent: rootViewController)

        XCTAssertTrue(waitUntil(timeout: 5) { toggle != nil }, "Toggle action never became available")
        XCTAssertTrue(waitUntil(timeout: 10) { lastEvaluated != nil }, "Annotation content was never evaluated")

        toggle?()

        XCTAssertTrue(waitUntil(timeout: 5) { lastEvaluated == true }, "Annotation content was never re-evaluated after its state changed")
    }

    /// Regression test: the fix must not schedule updates that self-perpetuate with `reloadPolicy: .always`.
    func testFirstMountFixDoesNotLoopWithAlwaysReloadPolicy() throws {
        struct AlwaysReloadMapView: View {
            let onMapReady: (MapboxMap) -> Void

            var body: some View {
                MapReader { proxy in
                    Map(initialViewport: .camera(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), zoom: 2)) {
                    }
                    .mapStyle(MapStyle(json: #"{"layers":[],"sources":{}}"#, reloadPolicy: .always))
                    .onAppear {
                        if let map = proxy.map {
                            onMapReady(map)
                        }
                    }
                }
            }
        }

        guard let rootViewController, let rootView = rootViewController.view else {
            XCTFail("No valid root view controller")
            return
        }
        var capturedMap: MapboxMap?
        var styleLoadCount = 0
        let hosting = UIHostingController(rootView: AnyView(AlwaysReloadMapView(
            onMapReady: { map in
                capturedMap = map
                map.onStyleLoaded.observe { _ in
                    styleLoadCount += 1
                }.store(in: &self.cancelables)
            }
        )))
        hostingController = hosting

        rootViewController.addChild(hosting)
        rootView.addSubview(hosting.view)
        hosting.view.frame = rootView.bounds
        hosting.didMove(toParent: rootViewController)

        XCTAssertTrue(waitUntil(timeout: 5) { capturedMap != nil }, "MapboxMap never became available")

        // Give a potential loop time to run away.
        RunLoop.main.run(until: Date().addingTimeInterval(3))

        // With a wrong fix it will cause thousands in styleLoadCount.
        XCTAssertLessThanOrEqual(styleLoadCount, 3, "reloadPolicy .always must not combine with the fix into a self-perpetuating reload loop (got \(styleLoadCount) loads)")
    }
}
