import XCTest
@testable import MapboxMaps

internal class MapViewIntegrationTestCase: IntegrationTestCase {
    internal var mapView: MapView!
    internal var dataPathURL: URL!

    /// Closures for map view delegate
    internal var didFinishLoadingStyle: ((MapView) -> Void)?
    internal var didBecomeIdle: ((MapView) -> Void)?
    internal var didLoadMap: ((MapView) -> Void)?

    /// Budget for a network-bound style and tile load; waits for the logic under test stay short.
    internal let mapLoadTimeout: TimeInterval = 30.0

    /// Map events since the map view was created, appended to every failure message.
    private var eventTimeline: [String] = []
    private var timelineStart = Date()

    internal override func setUpWithError() throws {
        try guardForMetalDevice()

        try super.setUpWithError()

        dataPathURL = try temporaryCacheDirectory()

        guard let window = window,
              let rootView = rootViewController?.view else {
            XCTFail("No valid UIWindow or root view controller")
            return
        }

        MapboxMapsOptions.dataPath = dataPathURL
        let mapInitOptions = MapInitOptions(styleURI: nil)
        eventTimeline = []
        timelineStart = Date()
        let view = MapView(frame: window.bounds, mapInitOptions: mapInitOptions)

        view.mapboxMap.onStyleLoaded.observeNext { [weak self] _ in
            guard let self = self, let mapView = self.mapView else { return }
            self.didFinishLoadingStyle?(mapView)
        }.store(in: &cancelables)

        view.mapboxMap.onMapIdle.observe { [weak self] _ in
            guard let self = self, let mapView = self.mapView else { return }
            self.didBecomeIdle?(mapView)
        }.store(in: &cancelables)

        view.mapboxMap.onMapLoaded.observe { [weak self] _ in
            guard let self = self, let mapView = self.mapView else { return }
            self.didLoadMap?(mapView)
        }.store(in: &cancelables)

        observeTimeline(of: view)

        rootView.addSubview(view)

        view.topAnchor.constraint(equalTo: rootView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: rootView.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: rootView.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rootView.rightAnchor).isActive = true

        // Label
        let label = UILabel()
        label.text = name
        label.sizeToFit()
        label.frame.origin = CGPoint(x: 0, y: 60)
        view.addSubview(label)

        mapView = view
    }

    internal override func tearDownWithError() throws {
        mapView?.removeFromSuperview()
        mapView = nil

        let expectation = self.expectation(description: "Clear map data")
        let clearStart = Date()
        MapboxMapsOptions.clearData { [weak self] error in
            self?.log("clearData finished in \(Self.format(Date().timeIntervalSince(clearStart)))" +
                      (error.map { ", error: \($0)" } ?? ""))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)

        didFinishLoadingStyle = nil
        didBecomeIdle = nil
        didLoadMap = nil

        try super.tearDownWithError()
    }

    // MARK: - Event timeline

    private func observeTimeline(of view: MapView) {
        let map: MapboxMap = view.mapboxMap
        map.onStyleDataLoaded.observe { [weak self] event in
            self?.log("styleDataLoaded(\(event.type))")
        }.store(in: &cancelables)
        map.onStyleLoaded.observe { [weak self] _ in
            self?.log("styleLoaded")
        }.store(in: &cancelables)
        map.onMapLoaded.observe { [weak self] _ in
            self?.log("mapLoaded")
        }.store(in: &cancelables)
        map.onMapIdle.observeNext { [weak self] _ in
            self?.log("first mapIdle")
        }.store(in: &cancelables)
        map.onMapLoadingError.observe { [weak self] error in
            self?.log("mapLoadingError(\(error.type)): \(error.message)")
        }.store(in: &cancelables)
        map.onResourceRequest.observe { [weak self] request in
            guard let error = request.response?.error else { return }
            self?.log("resourceRequestError(\(error.reason)): \(error.message) <\(request.request.url)>")
        }.store(in: &cancelables)
    }

    private func log(_ message: String) {
        eventTimeline.append("+\(Self.format(Date().timeIntervalSince(timelineStart))) \(message)")
    }

    private static func format(_ interval: TimeInterval) -> String {
        String(format: "%.2fs", interval)
    }

    internal override func record(_ issue: XCTIssue) {
        guard !eventTimeline.isEmpty else {
            return super.record(issue)
        }
        var issue = issue
        issue.compactDescription += " [map events: \(eventTimeline.joined(separator: "; "))]"
        super.record(issue)
    }
}
