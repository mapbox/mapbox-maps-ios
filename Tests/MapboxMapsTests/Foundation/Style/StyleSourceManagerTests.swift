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
        sourceManager = StyleSourceManager(
            styleManager: styleManager,
            mainQueue: mainQueue,
            backgroundQueue: backgroundQueue
        )
    }

    override func tearDown() {
        styleManager = nil
        mainQueue = nil
        backgroundQueue = nil
        sourceManager = nil
    }

    func testGetAllSourceIdentifiers() {
        let stubbedStyleSources: [StyleObjectInfo] = .random(withLength: 3) {
            StyleObjectInfo(id: .randomAlphanumeric(withLength: 12), type: LayerType.random().rawValue)
        }
        styleManager.getStyleSourcesStub.defaultReturnValue = stubbedStyleSources
        XCTAssertTrue(sourceManager.allSourceIdentifiers.allSatisfy { sourceInfo in
            stubbedStyleSources.contains(where: { $0.id == sourceInfo.id && $0.type == sourceInfo.type.rawValue })
        })
    }

}
