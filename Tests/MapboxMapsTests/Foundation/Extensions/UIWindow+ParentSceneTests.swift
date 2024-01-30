import XCTest
#if canImport(CarPlay)
import CarPlay
#endif
@testable import MapboxMaps

final class UIWindowParentSizeTests: XCTestCase {

    #if canImport(CarPlay)
    func testCarPlayWindowReturnsCorrectParentScene() throws {
        guard #available(iOS 13.0, *) else {
            throw XCTSkip("Test requires iOS 13 or higher.")
        }
        let window = CPWindow()

        XCTAssertEqual(window.parentScene, window.templateApplicationScene)
    }
    #endif

    func testUIWindowReturnsCorrectParentScene() throws {
        guard #available(iOS 13.0, *) else {
            throw XCTSkip("Test requires iOS 13 or higher.")
        }
        let window = UIWindow()

        XCTAssertEqual(window.parentScene, window.windowScene)
    }
}
