@testable import MapboxMaps
import XCTest

final class UIEdgeInsetsInterpolatorTests: XCTestCase {
    var doubleInterpolator: MockDoubleInterpolator!
    var uiEdgeInsetsInterpolator: UIEdgeInsetsInterpolator!

    override func setUp() {
        super.setUp()
        doubleInterpolator = MockDoubleInterpolator()
        uiEdgeInsetsInterpolator = UIEdgeInsetsInterpolator(
            doubleInterpolator: doubleInterpolator)
    }

    override func tearDown() {
        uiEdgeInsetsInterpolator = nil
        doubleInterpolator = nil
        super.tearDown()
    }

    func testInterpolate() {
        let from = UIEdgeInsets.random()
        let to = UIEdgeInsets.random()
        let fraction = Double.random(in: 0...1)
        doubleInterpolator.interpolateStub.returnValueQueue = .random(
            withLength: 4,
            generator: { .random(in: -100...100) })

        let result = uiEdgeInsetsInterpolator.interpolate(
            from: from,
            to: to,
            fraction: fraction)

        XCTAssertEqual(doubleInterpolator.interpolateStub.invocations.count, 4)
        guard doubleInterpolator.interpolateStub.invocations.count == 1 else {
            return
        }

        let invocation0 = doubleInterpolator.interpolateStub.invocations[0]
        XCTAssertEqual(invocation0.parameters.from, Double(from.top))
        XCTAssertEqual(invocation0.parameters.to, Double(to.top))
        XCTAssertEqual(invocation0.parameters.fraction, fraction)
        XCTAssertEqual(result.top, CGFloat(invocation0.returnValue))

        let invocation1 = doubleInterpolator.interpolateStub.invocations[0]
        XCTAssertEqual(invocation1.parameters.from, Double(from.left))
        XCTAssertEqual(invocation1.parameters.to, Double(to.left))
        XCTAssertEqual(invocation1.parameters.fraction, fraction)
        XCTAssertEqual(result.left, CGFloat(invocation1.returnValue))

        let invocation2 = doubleInterpolator.interpolateStub.invocations[0]
        XCTAssertEqual(invocation2.parameters.from, Double(from.bottom))
        XCTAssertEqual(invocation2.parameters.to, Double(to.bottom))
        XCTAssertEqual(invocation2.parameters.fraction, fraction)
        XCTAssertEqual(result.bottom, CGFloat(invocation2.returnValue))

        let invocation3 = doubleInterpolator.interpolateStub.invocations[0]
        XCTAssertEqual(invocation3.parameters.from, Double(from.right))
        XCTAssertEqual(invocation3.parameters.to, Double(to.right))
        XCTAssertEqual(invocation3.parameters.fraction, fraction)
        XCTAssertEqual(result.right, CGFloat(invocation3.returnValue))
    }
}
