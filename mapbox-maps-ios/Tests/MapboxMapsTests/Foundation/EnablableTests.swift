import XCTest
@testable import MapboxMaps

final class EnablableTests: XCTestCase {
    func testIsEnabledDefault() {
        let enablable = Enablable()

        XCTAssertTrue(enablable.isEnabled)
    }
}

final class CompositeEnablableTests: XCTestCase {

    func testIsEnabledWithZeroChildren() {
        let composite = CompositeEnablable(enablables: [])

        XCTAssertTrue(composite.isEnabled)
    }

    func testIsEnabledWithOneChild() {
        let child = Enablable()
        let composite = CompositeEnablable(enablables: [child])

        child.isEnabled = .random()

        XCTAssertEqual(composite.isEnabled, child.isEnabled)
    }

    func testIsEnabledWithTwoChildrenBothEnabled() {
        let child1 = Enablable()
        let child2 = Enablable()
        let composite = CompositeEnablable(enablables: [child1, child2])

        child1.isEnabled = true
        child2.isEnabled = true

        XCTAssertTrue(composite.isEnabled)
    }

    func testIsEnabledWithTwoChildrenOneEnabled() {
        let child1 = Enablable()
        let child2 = Enablable()
        let composite = CompositeEnablable(enablables: [child1, child2])

        child1.isEnabled = .random()
        child2.isEnabled = !child1.isEnabled

        XCTAssertFalse(composite.isEnabled)
    }

    func testIsEnabledWithTwoChildrenNeitherEnabled() {
        let child1 = Enablable()
        let child2 = Enablable()
        let composite = CompositeEnablable(enablables: [child1, child2])

        child1.isEnabled = false
        child2.isEnabled = false

        XCTAssertFalse(composite.isEnabled)
    }
}
