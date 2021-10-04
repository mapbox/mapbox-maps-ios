import XCTest
@testable import MapboxMaps

final class TileStoreObserverCancelableTests: XCTestCase {

    var observer: MockMapboxCommonTileStoreObserver!
    var tileStore: MockTileStore!
    var cancelable: TileStoreObserverCancelable!

    override func setUp() {
        super.setUp()
        observer = MockMapboxCommonTileStoreObserver()
        tileStore = MockTileStore()
        cancelable = TileStoreObserverCancelable(
            observer: observer,
            tileStore: tileStore)
    }

    override func tearDown() {
        cancelable = nil
        tileStore = nil
        observer = nil
        super.tearDown()
    }

    func testCancel() {
        cancelable.cancel()

        XCTAssertEqual(tileStore.__removeObserverStub.invocations.count, 1)
        XCTAssertTrue(tileStore.__removeObserverStub.parameters.first === observer)
    }

    func testSecondCancel() {
        cancelable.cancel()
        tileStore.__removeObserverStub.reset()

        cancelable.cancel()

        XCTAssertTrue(tileStore.__removeObserverStub.invocations.isEmpty)
    }
}
