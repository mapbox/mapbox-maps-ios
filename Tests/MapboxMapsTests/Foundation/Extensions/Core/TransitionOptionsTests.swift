import XCTest
import MapboxMaps

final class TransitionOptionsTests: XCTestCase {
    func testInitWithNils() {
        let options = TransitionOptions(duration: nil, delay: nil, enablePlacementTransitions: nil)
        XCTAssertNil(options.__duration)
        XCTAssertNil(options.__delay)
        XCTAssertNil(options.__enablePlacementTransitions)
    }
    func testInitWithNonNils() {
        let duration = TimeInterval.random(in: 0...10)
        let delay = TimeInterval.random(in: 0...10)
        let enablePlacementTransition = Bool.random()

        let options = TransitionOptions(duration: duration, delay: delay, enablePlacementTransitions: enablePlacementTransition)
        XCTAssertEqual(options.__duration, NSNumber(value: duration))
        XCTAssertEqual(options.__delay, NSNumber(value: delay))
        XCTAssertEqual(options.__enablePlacementTransitions, NSNumber(value: enablePlacementTransition))
    }

    // add refinements for properties and write the opposite tests
    // usee unrefined initializer and testing the refined properties 
}
