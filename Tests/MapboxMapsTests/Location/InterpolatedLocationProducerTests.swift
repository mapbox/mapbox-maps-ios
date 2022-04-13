import XCTest
@testable import MapboxMaps

final class InterpolatedLocationProducerTests: XCTestCase {

    var observableInterpolatedLocation: MockObservableInterpolatedLocation!
    var locationInterpolator: MockLocationInterpolator!
    var dateProvider: MockDateProvider!
    var locationProducer: MockLocationProducer!
    var displayLinkCoordinator: MockDisplayLinkCoordinator!
    var interpolatedLocationProducer: InterpolatedLocationProducer!

    override func setUp() {
        super.setUp()
        observableInterpolatedLocation = MockObservableInterpolatedLocation()
        locationInterpolator = MockLocationInterpolator()
        dateProvider = MockDateProvider()
        locationProducer = MockLocationProducer()
        displayLinkCoordinator = MockDisplayLinkCoordinator()
        interpolatedLocationProducer = InterpolatedLocationProducer(
            observableInterpolatedLocation: observableInterpolatedLocation,
            locationInterpolator: locationInterpolator,
            dateProvider: dateProvider,
            locationProducer: locationProducer,
            displayLinkCoordinator: displayLinkCoordinator)
    }

    override func tearDown() {
        interpolatedLocationProducer = nil
        displayLinkCoordinator = nil
        locationProducer = nil
        dateProvider = nil
        locationInterpolator = nil
        observableInterpolatedLocation = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertEqual(locationProducer.addStub.invocations.count, 0)
        XCTAssertEqual(displayLinkCoordinator.addStub.invocations.count, 0)
    }

    func testOnFirstSubscribe() {
        observableInterpolatedLocation.onFirstSubscribe?()

        XCTAssertEqual(locationProducer.addStub.invocations.count, 1)
        XCTAssertIdentical(locationProducer.addStub.invocations.first?.parameters, interpolatedLocationProducer)
        XCTAssertEqual(displayLinkCoordinator.addStub.invocations.count, 1)
        XCTAssertIdentical(displayLinkCoordinator.addStub.invocations.first?.parameters, interpolatedLocationProducer)
    }

    func testOnLastUnsubscribe() {
        observableInterpolatedLocation.onLastUnsubscribe?()

        XCTAssertEqual(locationProducer.removeStub.invocations.count, 1)
        XCTAssertIdentical(locationProducer.removeStub.invocations.first?.parameters, interpolatedLocationProducer)
        XCTAssertEqual(displayLinkCoordinator.removeStub.invocations.count, 1)
        XCTAssertIdentical(displayLinkCoordinator.removeStub.invocations.first?.parameters, interpolatedLocationProducer)
    }

    func testLocation() {
        observableInterpolatedLocation.value = .random(.random())

        XCTAssertEqual(interpolatedLocationProducer.location, observableInterpolatedLocation.value)
    }

    func testObserve() throws {
        let handler = Stub<InterpolatedLocation, Bool>(defaultReturnValue: .random())

        let cancelable = interpolatedLocationProducer.observe(with: handler.call(with:))

        XCTAssertEqual(observableInterpolatedLocation.observeStub.invocations.count, 1)
        let returnedCancelable = try XCTUnwrap(observableInterpolatedLocation.observeStub.invocations.first?.returnValue as? MockCancelable)
        let receivedHandler = try XCTUnwrap(observableInterpolatedLocation.observeStub.invocations.first?.parameters)
        let location = InterpolatedLocation.random()

        let continueObserving = receivedHandler(location)

        XCTAssertEqual(handler.invocations.map(\.parameters), [location])
        XCTAssertEqual(handler.invocations.map(\.returnValue), [continueObserving])

        cancelable.cancel()

        XCTAssertEqual(returnedCancelable.cancelStub.invocations.count, 1)
    }

    func testParticipateBeforeInitialLocationDelivery() {
        interpolatedLocationProducer.participate()

        XCTAssertEqual(observableInterpolatedLocation.notifyStub.invocations.count, 0)
    }

    func testParticipateAfterSingleLocationDelivery() {
        let location = Location.random()
        let interpolatedLocation = InterpolatedLocation(location: location)
        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 0)
        interpolatedLocationProducer.locationUpdate(newLocation: location)

        for timeInterval: TimeInterval in [0, 0.5, 1, 2] {
            dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: timeInterval)
            interpolatedLocationProducer.participate()
            XCTAssertEqual(locationInterpolator.interpolateStub.invocations.count, 0)
            XCTAssertEqual(observableInterpolatedLocation.notifyStub.invocations.map(\.parameters), [interpolatedLocation])
            observableInterpolatedLocation.notifyStub.reset()
        }
    }

    func testParticipateAfterSecondLocationDelviery() throws {
        let location0 = Location.random()
        let location1 = Location.random()
        let interpolatedLocation0 = InterpolatedLocation(location: location0)
        let interpolatedLocation1 = InterpolatedLocation(location: location1)
        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 0)
        interpolatedLocationProducer.locationUpdate(newLocation: location0)
        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 1)
        interpolatedLocationProducer.locationUpdate(newLocation: location1)

        func verifyParticipate(withTimeInterval timeInterval: TimeInterval, expectedFraction: Double) throws {
            dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: timeInterval)
            locationInterpolator.interpolateStub.defaultReturnValue = .random()
            interpolatedLocationProducer.participate()
            XCTAssertEqual(locationInterpolator.interpolateStub.invocations.count, 1)
            let interpolateInvocation = try XCTUnwrap(locationInterpolator.interpolateStub.invocations.first)
            XCTAssertEqual(interpolateInvocation.parameters.fromLocation, interpolatedLocation0)
            XCTAssertEqual(interpolateInvocation.parameters.toLocation, interpolatedLocation1)
            XCTAssertEqual(interpolateInvocation.parameters.fraction, expectedFraction, accuracy: 1e-10)
            XCTAssertEqual(observableInterpolatedLocation.notifyStub.invocations.map(\.parameters), [interpolateInvocation.returnValue])
            observableInterpolatedLocation.notifyStub.reset()
            locationInterpolator.interpolateStub.reset()
        }

        try verifyParticipate(withTimeInterval: 1, expectedFraction: 0)
        try verifyParticipate(withTimeInterval: 1.55, expectedFraction: 0.5)
        try verifyParticipate(withTimeInterval: 1.99, expectedFraction: 0.9)

        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 2.1)
        interpolatedLocationProducer.participate()
        XCTAssertEqual(locationInterpolator.interpolateStub.invocations.count, 0)
        XCTAssertEqual(observableInterpolatedLocation.notifyStub.invocations.map(\.parameters), [interpolatedLocation1])
        observableInterpolatedLocation.notifyStub.reset()

        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 3)
        interpolatedLocationProducer.participate()
        XCTAssertEqual(locationInterpolator.interpolateStub.invocations.count, 0)
        XCTAssertEqual(observableInterpolatedLocation.notifyStub.invocations.map(\.parameters), [interpolatedLocation1])
    }

    func testParticipateAfterThirdLocationDelivery() throws {
        let location0 = Location.random()
        let location1 = Location.random()
        let location2 = Location.random()
        let interpolatedLocation0 = InterpolatedLocation(location: location0)
        let interpolatedLocation1 = InterpolatedLocation(location: location1)
        let interpolatedLocation2 = InterpolatedLocation(location: location2)
        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 0)
        interpolatedLocationProducer.locationUpdate(newLocation: location0)
        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 1)
        interpolatedLocationProducer.locationUpdate(newLocation: location1)

        // third location delivered while still interpolating from first to second
        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 1.55)
        locationInterpolator.interpolateStub.defaultReturnValue = .random()
        interpolatedLocationProducer.locationUpdate(newLocation: location2)

        // new start location calculated via interpolation
        XCTAssertEqual(locationInterpolator.interpolateStub.invocations.count, 1)
        let interpolateInvocation = try XCTUnwrap(locationInterpolator.interpolateStub.invocations.first)
        XCTAssertEqual(interpolateInvocation.parameters.fromLocation, interpolatedLocation0)
        XCTAssertEqual(interpolateInvocation.parameters.toLocation, interpolatedLocation1)
        XCTAssertEqual(interpolateInvocation.parameters.fraction, 0.5, accuracy: 1e-10)
        let newStartLocation = interpolateInvocation.returnValue
        locationInterpolator.interpolateStub.reset()

        // now participation will interpolate from interpolated start to location 2
        func verifyParticipate(withTimeInterval timeInterval: TimeInterval, expectedFraction: Double) throws {
            dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: timeInterval)
            locationInterpolator.interpolateStub.defaultReturnValue = .random()
            interpolatedLocationProducer.participate()
            XCTAssertEqual(locationInterpolator.interpolateStub.invocations.count, 1)
            let interpolateInvocation = try XCTUnwrap(locationInterpolator.interpolateStub.invocations.first)
            XCTAssertEqual(interpolateInvocation.parameters.fromLocation, newStartLocation)
            XCTAssertEqual(interpolateInvocation.parameters.toLocation, interpolatedLocation2)
            XCTAssertEqual(interpolateInvocation.parameters.fraction, expectedFraction, accuracy: 1e-10)
            XCTAssertEqual(observableInterpolatedLocation.notifyStub.invocations.map(\.parameters), [interpolateInvocation.returnValue])
            observableInterpolatedLocation.notifyStub.reset()
            locationInterpolator.interpolateStub.reset()
        }

        try verifyParticipate(withTimeInterval: 1.55, expectedFraction: 0)
        try verifyParticipate(withTimeInterval: 2.1, expectedFraction: 0.5)
        try verifyParticipate(withTimeInterval: 2.54, expectedFraction: 0.9)

        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 2.66)
        interpolatedLocationProducer.participate()
        XCTAssertEqual(locationInterpolator.interpolateStub.invocations.count, 0)
        XCTAssertEqual(observableInterpolatedLocation.notifyStub.invocations.map(\.parameters), [interpolatedLocation2])
        observableInterpolatedLocation.notifyStub.reset()

        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 3.5)
        interpolatedLocationProducer.participate()
        XCTAssertEqual(locationInterpolator.interpolateStub.invocations.count, 0)
        XCTAssertEqual(observableInterpolatedLocation.notifyStub.invocations.map(\.parameters), [interpolatedLocation2])
    }
}
