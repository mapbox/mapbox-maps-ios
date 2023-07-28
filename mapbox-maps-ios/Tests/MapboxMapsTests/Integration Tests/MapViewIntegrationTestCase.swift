import XCTest
@testable import MapboxMaps

internal class MapViewIntegrationTestCase: IntegrationTestCase {
    internal var mapView: MapView!
    internal var dataPathURL: URL!

    /// Closures for map view delegate
    internal var didFinishLoadingStyle: ((MapView) -> Void)?
    internal var didBecomeIdle: ((MapView) -> Void)?
    internal var didLoadMap: ((MapView) -> Void)?

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
        MapboxMapsOptions.clearData { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)

        didFinishLoadingStyle = nil
        didBecomeIdle = nil
        didLoadMap = nil

        try super.tearDownWithError()
    }
}
