import XCTest
import MapboxCommon
@_spi(Experimental) @testable import MapboxMaps

final class TileStoreEventSignalTests: XCTestCase {

    var tileStore: MockTileStore!
    var signal: Signal<TileStoreGenericEvent>!

    override func setUp() {
        super.setUp()
        tileStore = MockTileStore()
        signal = tileStoreEventSignal(tileStore, .metadataMigrationFailed)
    }

    override func tearDown() {
        signal = nil
        tileStore = nil
        super.tearDown()
    }

    func testDoesNotSubscribeUntilObserved() {
        XCTAssertTrue(tileStore.__subscribeForEventStub.invocations.isEmpty)
    }

    func testSubscribesWithEventName() {
        let token = signal.observe { _ in }

        XCTAssertEqual(tileStore.__subscribeForEventStub.invocations.count, 1)
        XCTAssertEqual(tileStore.__subscribeForEventStub.invocations.first?.parameters.eventName, "metadata-migration-failed")
        token.cancel()
    }

    func testForwardsEventToObserver() throws {
        var received = [TileStoreGenericEvent]()
        let token = signal.observe { received.append($0) }

        let event = TileStoreGenericEvent(name: "metadata-migration-failed", text: "failure reason", data: "/path/metadata.db")
        let callback = try XCTUnwrap(tileStore.__subscribeForEventStub.invocations.first?.parameters.callback)
        callback(event)

        XCTAssertEqual(received.count, 1)
        XCTAssertTrue(received.first === event)
        token.cancel()
    }

    func testEachObserverSubscribesSeparately() {
        let token1 = signal.observe { _ in }
        let token2 = signal.observe { _ in }

        XCTAssertEqual(tileStore.__subscribeForEventStub.invocations.count, 2)
        token1.cancel()
        token2.cancel()
    }

    func testCancelCancelsSubscription() {
        let cancelable = MockCancelable()
        tileStore.__subscribeForEventStub.defaultReturnValue = cancelable

        let token = signal.observe { _ in }
        token.cancel()

        XCTAssertEqual(cancelable.cancelStub.invocations.count, 1)
    }

    func testDeinitCancelsSubscription() {
        let cancelable = MockCancelable()
        tileStore.__subscribeForEventStub.defaultReturnValue = cancelable

        var token: AnyCancelable? = signal.observe { _ in }
        XCTAssertNotNil(token)
        token = nil

        XCTAssertEqual(cancelable.cancelStub.invocations.count, 1)
    }
}
