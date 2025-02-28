import XCTest
@testable import MapboxMaps

final class TransitionOptionsTests: XCTestCase {
    func testInitWithNils() {
        let options = TransitionOptions(
            duration: nil,
            delay: nil,
            enablePlacementTransitions: nil)

        XCTAssertNil(options.coreOptions.__duration)
        XCTAssertNil(options.coreOptions.__delay)
        XCTAssertNil(options.coreOptions.__enablePlacementTransitions)
    }

    func testInitWithNonNils() {
        let duration = TimeInterval.random(in: 0...10)
        let delay = TimeInterval.random(in: 0...10)
        let enablePlacementTransition = Bool.random()

        let options = TransitionOptions(
            duration: duration,
            delay: delay,
            enablePlacementTransitions: enablePlacementTransition)

        XCTAssertEqual(options.coreOptions.__duration, NSNumber(value: duration))
        XCTAssertEqual(options.coreOptions.__delay, NSNumber(value: delay))
        XCTAssertEqual(options.coreOptions.__enablePlacementTransitions, NSNumber(value: enablePlacementTransition))
    }

    func testRefinedPropertiesWithNonNils() {
        let duration = TimeInterval.random(in: 0...10)
        let delay = TimeInterval.random(in: 0...10)
        let enablePlacementTransition = Bool.random()
        let options = TransitionOptions(duration: duration,
                                        delay: delay,
                                        enablePlacementTransitions: enablePlacementTransition)

        XCTAssertEqual(options.duration, duration)
        XCTAssertEqual(options.delay, delay)
        XCTAssertEqual(options.enablePlacementTransitions, enablePlacementTransition)
    }

    func testRefinedPropertiesWithNils() {
        let options = TransitionOptions(
                        duration: nil,
                        delay: nil,
                        enablePlacementTransitions: nil)

        XCTAssertNil(options.duration)
        XCTAssertNil(options.delay)
        XCTAssertNil(options.enablePlacementTransitions)
    }

    func testTransitionOptionsEquality() {
        let options = TransitionOptions(duration: 12, delay: 3, enablePlacementTransitions: true)
        let options2 = TransitionOptions(duration: 12, delay: 3, enablePlacementTransitions: true)

        XCTAssertEqual(options.duration, options2.duration)
        XCTAssertEqual(options.delay, options2.delay)
        XCTAssertEqual(options.enablePlacementTransitions, options2.enablePlacementTransitions)
        XCTAssertEqual(options, options2)
    }

}
