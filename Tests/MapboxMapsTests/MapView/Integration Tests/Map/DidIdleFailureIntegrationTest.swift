import XCTest
import MapboxMaps
import MapboxCoreMaps
import MapboxCommon

//            * .
//            * ├── data-source - String ("resource-loader" | "network" | "database" | "asset" | "file-system")
//            * ├── request - Object
//            * │   ├── url - String
//            * │   ├── kind - String ("unknown" | "style" | "source" | "tile" | "glyphs" | "sprite-image" | "sprite-json" | "image")
//            * │   ├── priority - String ("regular" | "low")
//            * │   └── loading-method - Array ["cache" | "network"]
//            * ├── response - optional Object
//            * │   ├── no-content - Boolean
//            * │   ├── not-modified - Boolean
//            * │   ├── must-revalidate - Boolean
//            * │   ├── offline-data - Boolean
//            * │   ├── size - Number (size in bytes)
//            * │   ├── modified - optional String, rfc1123 timestamp
//            * │   ├── expires - optional String, rfc1123 timestamp
//            * │   ├── etag - optional String
//            * │   └── error - optional Object
//            * │       ├── reason - String ("success" | "not-found" | "server" | "connection" | "rate-limit" | "other")
//            * │       └── message - String
//            * └── cancelled - Boolean

internal struct ResourceEventResponseError: Decodable {
    var reason: String
    var message: String
}

internal struct ResourceEventResponse: Decodable {
    var noContent: Bool
    var notModified: Bool
    var mustRevalidate: Bool
    var offlineData: Bool
    var size: Int
    var modified: String?
    var expires: String?
    var etag: String?
    var error: ResourceEventResponseError?

    enum CodingKeys: String, CodingKey {
        case noContent = "no-content"
        case notModified = "not-modified"
        case mustRevalidate = "must-revalidate"
        case offlineData = "offline-data"
        case size
        case modified
        case expires
        case etag
        case error
    }
}

internal struct ResourceEventRequest: Decodable {
    var url: String
    var kind: String
    var priority: String
    var loadingMethod: [String]

    enum CodingKeys: String, CodingKey {
        case url
        case kind
        case priority
        case loadingMethod = "loading-method"
    }
}

internal struct ResourceEvent: Decodable {
    var dataSource: String
    var request: ResourceEventRequest
    var response: ResourceEventResponse?
    var cancelled: Bool

    enum CodingKeys: String, CodingKey {
        case dataSource = "data-source"
        case request = "request"
        case response
        case cancelled
    }
}

// Modified from MapViewIntegrationTestCase
internal class DidIdleFailureIntegrationTest: IntegrationTestCase {

    internal var mapView: MapView?
    internal var style: Style?
    internal var observer: ObservableIntegrationTestsObserver?

    internal var hadResourceEventError: ((MapView, ResourceEventResponseError) -> Void)?

    internal override func setUpWithError() throws {
        try super.setUpWithError()

        guard let window = window,
              let rootView = rootViewController?.view else {
            throw XCTSkip("No valid UIWindow or root view controller")
        }

        guard MTLCreateSystemDefaultDevice() != nil else {
            throw XCTSkip("No valid Metal device (OS version or VM?)")
        }

        let resourceOptions = ResourceOptions(accessToken: accessToken)
        let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions)
        let view = MapView(frame: window.bounds, mapInitOptions: mapInitOptions)

        let observer = ObservableIntegrationTestsObserver(with: { [weak self] (resourceEvent) in
            guard let self = self else {
                return
            }

            guard let eventData = resourceEvent.data as? [String: Any],
                  let jsonData = try? JSONSerialization.data(withJSONObject: eventData) else {
                return
            }

            let event: ResourceEvent
            do {
                event = try JSONDecoder().decode(ResourceEvent.self, from: jsonData)
            } catch let error {
                Log.error(forMessage: "Failed to decode to ResourceEvent: \(error)", category: "Map")
                return
            }

            guard let eventError = event.response?.error else {
                return
            }

            self.hadResourceEventError?(self.mapView!, eventError)
        })

        view.mapboxMap.__map.subscribe(for: observer, events: ["resource-request"])

        self.observer = observer

        style = view.style

        rootView.addSubview(view)

        view.topAnchor.constraint(equalTo: rootView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: rootView.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: rootView.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rootView.rightAnchor).isActive = true

        mapView = view
    }

    internal override func tearDownWithError() throws {

        if let observer = observer {
            mapView?.mapboxMap.__map.unsubscribe(for: observer, events: ["resource-request"])
        }

        mapView?.removeFromSuperview()
        mapView = nil
        style = nil

        rootViewController?.viewWillDisappear(false)
        rootViewController?.viewDidDisappear(false)
        rootViewController = nil
        window = nil
    }

    internal func testWaitForIdle() throws {
        guard
            let mapView = mapView,
            let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let expectation = XCTestExpectation(description: "Wait for map to idle")
        expectation.expectedFulfillmentCount = 2

        style.uri = .streets

        mapView.centerCoordinate = CLLocationCoordinate2D(latitude: 42.0, longitude: -71.0)
        mapView.zoom = 8.0

        mapView.on(.mapLoadingError) { event in
            let userInfo: [String: Any] = (event.data as? [String: Any]) ?? [:]
            Log.error(forMessage: "Map failed to load with error: \(userInfo)", category: "Map")
            XCTFail("Failed to load map with \(userInfo)")
        }

        mapView.on(.styleLoaded) { _ in
            expectation.fulfill()
        }

        mapView.on(.mapIdle) { _ in
            expectation.fulfill()
        }

        var eventError: ResourceEventResponseError?
        hadResourceEventError = { _, error in
            eventError = error
        }

        let result = XCTWaiter().wait(for: [expectation], timeout: 5.0)
        switch result {
        case .completed:
            break

        case .timedOut:
            if let error = eventError {
                Log.error(forMessage: "Timed out, test had a resource error: \(error.reason) - \(error.message)", category: "Map")
            } else {
                Log.error(forMessage: "Timed out, but no resource error", category: "Map")
            }
            fallthrough

        default:
            XCTFail("Test failed with \(result)")
        }
    }
}
