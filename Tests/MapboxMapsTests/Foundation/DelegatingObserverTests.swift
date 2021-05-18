import XCTest
@testable import MapboxMaps

final class DelegatingObserverTests: XCTestCase {

    var delegatingObserver: DelegatingObserver!
    // swiftlint:disable:next weak_delegate
    var delegate: MockDelegatingObserverDelegate!

    override func setUp() {
        super.setUp()
        delegatingObserver = DelegatingObserver()
        delegate = MockDelegatingObserverDelegate()
        delegatingObserver.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        delegatingObserver = nil
        super.tearDown()
    }

    func testNotifyForwardsToDelegate() {
        let expectedEvent = Event(type: "test", data: "test")

        delegatingObserver.notify(for: expectedEvent)

        XCTAssertEqual(delegate.notifyStub.invocations.count, 1)
        XCTAssertEqual(delegate.notifyStub.parameters.first, expectedEvent)
    }
}
