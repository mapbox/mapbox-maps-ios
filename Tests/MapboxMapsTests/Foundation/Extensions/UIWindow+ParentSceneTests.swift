import XCTest
import CarPlay
@testable import MapboxMaps

final class UIWindowParentSizeTests: XCTestCase {

    func testCarPlayWindowReturnsCorrectParentScene() throws {
        guard #available(iOS 13.0, *) else {
            throw XCTSkip("Test requires iOS 13 or higher.")
        }
        let window = CPWindow()

        XCTAssertEqual(window.parentScene, window.templateApplicationScene)
    }

    func testUIWindowReturnsCorrectParentScene() throws {
        guard #available(iOS 13.0, *) else {
            throw XCTSkip("Test requires iOS 13 or higher.")
        }
        let window = UIWindow()

        XCTAssertEqual(window.parentScene, window.windowScene)
    }
}
