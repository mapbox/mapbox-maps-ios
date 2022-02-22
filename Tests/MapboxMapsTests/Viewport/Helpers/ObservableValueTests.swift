import XCTest
@testable import MapboxMaps

final class ObservableValueTests: XCTestCase {

    var nextValue: Int!
    var observableValue: ObservableValue<Int>!

    override func setUp() {
        super.setUp()
        nextValue = .random(in: 0...10)
        observableValue = ObservableValue()
    }

    override func tearDown() {
        observableValue = nil
        nextValue = nil
        super.tearDown()
    }

    @discardableResult
    func update() -> Int {
        let value = nextValue!
        nextValue += Bool.random() ? Int.random(in: 1...10) : Int.random(in: (-10)...(-1))
        observableValue.notify(with: value)
        return value
    }

    func testValue() {
        XCTAssertNil(observableValue.value)

        let value = update()

        XCTAssertEqual(observableValue.value, value)
    }

    func testObservePriorToFirstUpdate() {
        let handlerStub = Stub<Int, Bool>(defaultReturnValue: true)

        _ = observableValue.observe(with: handlerStub.call(with:))

        XCTAssertTrue(handlerStub.invocations.isEmpty)

        let value = update()

        XCTAssertEqual(handlerStub.invocations.map(\.parameters), [value])
    }

    func testObserveAfterFirstUpdate() {
        let value = update()

        let handlerStub = Stub<Int, Bool>(defaultReturnValue: true)

        _ = observableValue.observe(with: handlerStub.call(with:))

        XCTAssertEqual(handlerStub.invocations.map(\.parameters), [value])
    }

    func testHandlerReturnsTrueToContinueAndFalseToUnsubscribe() {
        let handlerStub = Stub<Int, Bool>(defaultReturnValue: false)
        handlerStub.returnValueQueue = [true, true]

        _ = observableValue.observe(with: handlerStub.call(with:))

        let expectedUpdates = [update(), update(), update()]
        update() // should not be received by handler
        XCTAssertEqual(handlerStub.invocations.map(\.parameters), expectedUpdates)
    }

    func testCancelableStopsUpdates() {
        let handlerStub = Stub<Int, Bool>(defaultReturnValue: true)

        let cancelable = observableValue.observe(with: handlerStub.call(with:))

        let expectedUpdates = [update(), update(), update()]
        cancelable.cancel()
        update() // should not be received by handler
        XCTAssertEqual(handlerStub.invocations.map(\.parameters), expectedUpdates)
    }

    func testMultipleObservers() throws {
        let handlerStub1 = Stub<Int, Bool>(defaultReturnValue: false)
        _ = observableValue.observe(with: handlerStub1.call(with:))

        let handlerStub2 = Stub<Int, Bool>(defaultReturnValue: true)
        let cancelable = observableValue.observe(with: handlerStub2.call(with:))

        let handlerStub3 = Stub<Int, Bool>(defaultReturnValue: true)
        _ = observableValue.observe(with: handlerStub3.call(with:))

        update()

        update()

        cancelable.cancel()

        update()

        assertMethodCall(handlerStub1, times: 1)
        assertMethodCall(handlerStub2, times: 2)
        assertMethodCall(handlerStub3, times: 3)
    }

    func testDeduplicatesNotifications() {
        let handlerStub = Stub<Int, Bool>(defaultReturnValue: true)

        _ = observableValue.observe(with: handlerStub.call(with:))

        let value = update()
        observableValue.notify(with: value)
        observableValue.notify(with: value)
        let value2 = update()

        XCTAssertEqual(handlerStub.invocations.map(\.parameters), [value, value2])
    }
}
