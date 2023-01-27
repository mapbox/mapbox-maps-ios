import XCTest
import MapboxMaps

internal class MapViewIntegrationTestCase: IntegrationTestCase {
    internal var mapView: MapView!
    internal var style: Style!
    internal var dataPathURL: URL!

    /// Closures for map view delegate 
    internal var didFinishLoadingStyle: ((MapView) -> Void)?
    internal var didBecomeIdle: ((MapView) -> Void)?

    internal override func setUpWithError() throws {
        try guardForMetalDevice()

        try super.setUpWithError()

        dataPathURL = try temporaryCacheDirectory()

        guard let window = window,
              let rootView = rootViewController?.view else {
            XCTFail("No valid UIWindow or root view controller")
            return
        }

        let resourceOptions = ResourceOptions(accessToken: accessToken,
                                              dataPathURL: dataPathURL)
        let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions,
                                            styleURI: nil)
        let view = MapView(frame: window.bounds, mapInitOptions: mapInitOptions)

        view.mapboxMap.onEvery(event: .styleLoaded) { [weak self] _ in
            guard let self = self, let mapView = self.mapView else { return }
            self.didFinishLoadingStyle?(mapView)
        }

        view.mapboxMap.onEvery(event: .mapIdle) { [weak self] _ in
            guard let self = self, let mapView = self.mapView else { return }
            self.didBecomeIdle?(mapView)
        }

        style = view.mapboxMap.style

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
        let resourceOptions = mapView?.mapboxMap.resourceOptions

        mapView?.removeFromSuperview()
        mapView = nil
        style = nil

        if let resourceOptions = resourceOptions {
            let expectation = self.expectation(description: "Clear map data")
            MapboxMap.clearData(for: resourceOptions) { _ in
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10.0)
        }

        didFinishLoadingStyle = nil
        didBecomeIdle = nil

        try super.tearDownWithError()
    }
}
