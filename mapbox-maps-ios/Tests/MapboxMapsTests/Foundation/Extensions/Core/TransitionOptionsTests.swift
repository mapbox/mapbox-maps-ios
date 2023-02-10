import XCTest
import MapboxMaps

final class TransitionOptionsTests: XCTestCase {
    func testInitWithNils() {
        let options = TransitionOptions(
            duration: nil,
            delay: nil,
            enablePlacementTransitions: nil)

        XCTAssertNil(options.__duration)
        XCTAssertNil(options.__delay)
        XCTAssertNil(options.__enablePlacementTransitions)
    }

    func testInitWithNonNils() {
        let duration = TimeInterval.random(in: 0...10)
        let delay = TimeInterval.random(in: 0...10)
        let enablePlacementTransition = Bool.random()

        let options = TransitionOptions(
            duration: duration,
            delay: delay,
            enablePlacementTransitions: enablePlacementTransition)

        XCTAssertEqual(options.__duration, NSNumber(value: duration))
        XCTAssertEqual(options.__delay, NSNumber(value: delay))
        XCTAssertEqual(options.__enablePlacementTransitions, NSNumber(value: enablePlacementTransition))
    }

    func testRefinedPropertiesWithNonNils() {
        let duration = TimeInterval.random(in: 0...10)
        let delay = TimeInterval.random(in: 0...10)
        let enablePlacementTransition = Bool.random()
        let options = TransitionOptions(
            __duration: NSNumber(value: duration),
            delay: NSNumber(value: delay),
            enablePlacementTransitions: NSNumber(value: enablePlacementTransition))

        XCTAssertEqual(options.duration, duration)
        XCTAssertEqual(options.delay, delay)
        XCTAssertEqual(options.enablePlacementTransitions, enablePlacementTransition)
    }

    func testRefinedPropertiesWithNils() {
        let options = TransitionOptions(
            __duration: nil,
            delay: nil,
            enablePlacementTransitions: nil)

        XCTAssertNil(options.duration)
        XCTAssertNil(options.delay)
        XCTAssertNil(options.enablePlacementTransitions)
    }
}
