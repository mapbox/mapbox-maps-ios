import Foundation
import XCTest
@testable import MapboxMaps

final class StyleSourceManagerTests: XCTestCase {
    var sourceManager: StyleSourceManager!
    var styleManager: MockStyleManager!
    var mainQueue: MockDispatchQueue!
    var backgroundQueue: MockDispatchQueue!

    override func setUpWithError() throws {
        styleManager = MockStyleManager()
        mainQueue = MockDispatchQueue()
        backgroundQueue = MockDispatchQueue()
        sourceManager = StyleSourceManager(styleManager: Style, mainQueue: mainQueue, backgroundQueue: backgroundQueue)
    }

    override func tearDown() {
        styleManager = nil
        mainQueue = nil
        backgroundQueue = nil
        sourceManager = nil
    }
}
