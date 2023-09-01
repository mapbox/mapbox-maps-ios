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
}
