@testable import MapboxMaps
import XCTest

final class PropertiesEqualityTests: XCTestCase {
    func testEquality() {
        class Ref {}
        struct Subject {
            var int: Int
            var string: String
            var ref: Ref
            var computed: String {
                // The computed properties don't participate in equality check.
                String.randomASCII(withLength: 10)
            }
        }

        let ref1 = Ref()
        let ref2 = Ref()

        XCTAssertTrue(arePropertiesEqual(
            Subject(int: 0, string: "foo", ref: ref1),
            Subject(int: 0, string: "foo", ref: ref1)))

        XCTAssertFalse(arePropertiesEqual(
            Subject(int: 0, string: "foo", ref: ref1),
            Subject(int: 1, string: "foo", ref: ref1)))

        XCTAssertFalse(arePropertiesEqual(
            Subject(int: 0, string: "foo", ref: ref1),
            Subject(int: 0, string: "bar", ref: ref1)))

        XCTAssertFalse(arePropertiesEqual(
            Subject(int: 0, string: "foo", ref: ref1),
            Subject(int: 0, string: "foo", ref: ref2)))
    }

    func testEqualityWithClosure() {
        struct Subject {
            var closure: () -> Void
        }

        XCTAssertFalse(arePropertiesEqual(
            Subject {},
            Subject {}))

        let s = Subject(closure: {})
        XCTAssertFalse(arePropertiesEqual(s, s))
    }

    func testEqualityEquatableType() {
        struct EquatableType: Equatable {
            var a: Int
        }
        struct Subject {
            var child: EquatableType
        }

        XCTAssertTrue(arePropertiesEqual(
            Subject(child: EquatableType(a: 1)),
            Subject(child: EquatableType(a: 1))))

        XCTAssertFalse(arePropertiesEqual(
            Subject(child: EquatableType(a: 1)),
            Subject(child: EquatableType(a: 2))))
    }
}
