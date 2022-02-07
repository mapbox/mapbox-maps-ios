import XCTest
import CarPlay
@testable import MapboxMaps

final class UIWindowParentSizeTests: XCTestCase {

    @available(iOS 13.0, *)
    func testCarPlayWindowReturnsCorrectParentScene() {
        let window = CPWindow()

        XCTAssertEqual(window.parentScene, window.templateApplicationScene)
    }

    @available(iOS 13.0, *)
    func testUIWindowReturnsCorrectParentScene() {
        let window = UIWindow()

        XCTAssertEqual(window.parentScene, window.windowScene)
    }
}
