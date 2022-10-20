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

        let sign = Bool.random() ? 1 : -1
        let increment = Int.random(in: 1...10) * sign
        nextValue += increment
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

    func testValueUpdatedBeforeNotifyingObservers() {
        let handlerStub = Stub<Int, Bool>(defaultReturnValue: true)
        handlerStub.defaultSideEffect = { invocation in
            XCTAssertEqual(self.observableValue.value, invocation.parameters)
        }
        _ = observableValue.observe(with: handlerStub.call(with:))

        update()
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

        XCTAssertEqual(handlerStub1.invocations.count, 1)
        XCTAssertEqual(handlerStub2.invocations.count, 2)
        XCTAssertEqual(handlerStub3.invocations.count, 3)
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

    func testOnFirstSubscribe() {
        let onFirstSubscribeStub = Stub<Void, Void>()
        observableValue.onFirstSubscribe = onFirstSubscribeStub.call

        for _ in 0...Int.random(in: 1...10) {
            _ = observableValue.observe(with: { _ in true })
        }

        XCTAssertEqual(onFirstSubscribeStub.invocations.count, 1)
    }

    func testOnLastUnsubscribe() {
        let onLastUnsubscribeStub = Stub<Void, Void>()
        observableValue.onLastUnsubscribe = onLastUnsubscribeStub.call

        let cancelables = (0...Int.random(in: 1...10)).map { i in
            observableValue.observe(with: { _ in i.isMultiple(of: 2) })
        }

        cancelables.enumerated().forEach { (i, cancelable) in
            if i.isMultiple(of: 2) {
                cancelable.cancel()
            }
        }

        observableValue.notify(with: 0)

        XCTAssertEqual(onLastUnsubscribeStub.invocations.count, 1)
    }
}
