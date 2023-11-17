import XCTest
@testable import MapboxMaps

class UIEdgeInsetsTests: XCTestCase {

    func testAddition() {
        let insets1 = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        let insets2 = UIEdgeInsets(top: 5, left: 10, bottom: 15, right: 20)
        let expected = UIEdgeInsets(top: 15, left: 30, bottom: 45, right: 60)
        XCTAssertEqual(insets1 + insets2, expected)
    }

    func testOptionalAddition() {
        let insets1: UIEdgeInsets? = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        let insets2: UIEdgeInsets? = UIEdgeInsets(top: 5, left: 10, bottom: 15, right: 20)
        let expected: UIEdgeInsets? = UIEdgeInsets(top: 15, left: 30, bottom: 45, right: 60)
        XCTAssertEqual(insets1 + insets2, expected)

        let insets3: UIEdgeInsets? = nil
        let insets4: UIEdgeInsets? = UIEdgeInsets(top: 5, left: 10, bottom: 15, right: 20)
        XCTAssertEqual(insets3 + insets4, insets4)

        let insets5: UIEdgeInsets? = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        let insets6: UIEdgeInsets? = nil
        XCTAssertEqual(insets5 + insets6, insets5)

        let insets7: UIEdgeInsets? = nil
        let insets8: UIEdgeInsets? = nil
        XCTAssertNil(insets7 + insets8)
    }

    func testSubtraction() {
        let insets1 = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        let insets2 = UIEdgeInsets(top: 5, left: 10, bottom: 15, right: 20)
        let expected = UIEdgeInsets(top: 5, left: 10, bottom: 15, right: 20)
        XCTAssertEqual(insets1 - insets2, expected)
    }

    func testOptionalSubtraction() {
        let insets1: UIEdgeInsets? = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        let insets2: UIEdgeInsets? = UIEdgeInsets(top: 5, left: 10, bottom: 15, right: 20)
        let expected: UIEdgeInsets? = UIEdgeInsets(top: 5, left: 10, bottom: 15, right: 20)
        XCTAssertEqual(insets1 - insets2, expected)

        let insets3: UIEdgeInsets? = nil
        let insets4: UIEdgeInsets? = UIEdgeInsets(top: 5, left: 10, bottom: 15, right: 20)
        XCTAssertEqual(insets3 - insets4, -insets4)

        let insets5: UIEdgeInsets? = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        let insets6: UIEdgeInsets? = nil
        XCTAssertEqual(insets5 - insets6, insets5)

        let insets7: UIEdgeInsets? = nil
        let insets8: UIEdgeInsets? = nil
        XCTAssertNil(insets7 - insets8)
    }

    func testNegation() {
        let insets = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        let expected = UIEdgeInsets(top: -10, left: -20, bottom: -30, right: -40)
        XCTAssertEqual(-insets, expected)
    }

    func testOptionalNegation() {
        let insets: UIEdgeInsets? = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        let expected: UIEdgeInsets? = UIEdgeInsets(top: -10, left: -20, bottom: -30, right: -40)
        XCTAssertEqual(-insets, expected)

        let insets2: UIEdgeInsets? = nil
        XCTAssertNil(-insets2)
    }
}
