import XCTest
import MapboxMaps

class ObservableIntegrationTestsObserver: Observer {
    var peer: MBXPeerWrapper?
    var notificationHandler: (MapboxCoreMaps.Event) -> Void

    init(with notificationHandler: @escaping (MapboxCoreMaps.Event) -> Void) {
        self.notificationHandler = notificationHandler
    }

    func notify(for event: MapboxCoreMaps.Event) {
        notificationHandler(event)
    }
}

class ObservableIntegrationTests: MapViewIntegrationTestCase {

    func testResourceRequestEvent() throws {
        guard
            let mapView = mapView,
            let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let eventExpectation = XCTestExpectation(description: "Event should have been received")
        eventExpectation.assertForOverFulfill = false

        let observer = ObservableIntegrationTestsObserver { (event) in
            XCTAssertEqual(event.type, "resource-request")

            guard let info = event.data as? [String: Any] else {
                XCTFail("Invalid data format")
                return
            }

            guard let dataSource = info["data-source"] as? String else {
                XCTFail("dataSource should be a String")
                return
            }

            let validDatasources = ["resource-loader", "network", "database", "asset", "file-system"]
            XCTAssert(validDatasources.contains(dataSource))

            eventExpectation.fulfill()
        }

        try! mapView.__map.subscribe(for: observer, events: ["resource-request"])

        style.styleURI = .streets

        let styleLoadExpectation = XCTestExpectation(description: "Style should have been loaded")

        didFinishLoadingStyle = { _ in
            styleLoadExpectation.fulfill()
        }

        wait(for: [styleLoadExpectation, eventExpectation], timeout: 5.0)

        try! mapView.__map.unsubscribe(for: observer)
    }
}
