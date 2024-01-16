@testable import MapboxMaps
import XCTest

final class UIViewControllerExtensionsTests: XCTestCase {
    func testTopmostPresentedViewController() {
        let vc1 = MockViewController()
        let vc2 = MockViewController()
        let vc3 = MockViewController()

        XCTAssertIdentical(vc1.topmostPresentedViewController, vc1)

        vc1.simulatePresent(vc2)
        XCTAssertIdentical(vc1.topmostPresentedViewController, vc2)

        vc2.simulatePresent(vc3)
        XCTAssertIdentical(vc1.topmostPresentedViewController, vc3)
    }
}

private class MockViewController: UIViewController {
    private var _presentedViewControllerOverride: UIViewController?
    override var presentedViewController: UIViewController? {
        return _presentedViewControllerOverride
    }
    func simulatePresent(_ vc: UIViewController) {
        _presentedViewControllerOverride = vc
    }
}
