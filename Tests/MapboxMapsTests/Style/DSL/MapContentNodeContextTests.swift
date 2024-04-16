import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class MapContentNodeContextTests: XCTestCase {
    var sut: MapContentNodeContext!
    var styleManager: MockStyleManager!
    var sourceManager: MockStyleSourceManager!

    @TestPublished var styleIsLoaded = true

    override func setUp() {
        styleManager = MockStyleManager()
        sourceManager = MockStyleSourceManager()
        sut = MapContentNodeContext(styleManager: styleManager, sourceManager: sourceManager, isEqualContent: { _, _ in false })
    }

    override func tearDown() {
        sut = nil
        sourceManager = nil
        styleManager = nil
    }

    func testResolvePosition_LastLayerIdExists_ResolvesAboveLast() {
        sut.lastLayerId = "test1"

        let layerPosition = sut.resolveLayerPosition()

        XCTAssertEqual(layerPosition, .above("test1"))
    }

    func testResolvePosition_LastLayerIdNil_StyleLayersNotEmpty_ResolvesAboveLastInitialStyleLayerThatExists() {
        sut.lastLayerId = nil
        sut.initialStyleLayers = ["test1", "test2"]

        styleManager.styleLayerExistsStub.returnValueQueue = [false, true]

        let layerPosition = sut.resolveLayerPosition()

        XCTAssertEqual(layerPosition, .above("test1"))
    }

    func testResolvePosition_LastLayerIdNil_StyleLayersEmpty_ResolvesZeroPosition() {
        sut.lastLayerId = nil
        styleManager.getStyleLayersStub.defaultReturnValue = []

        let layerPosition = sut.resolveLayerPosition()

        XCTAssertEqual(layerPosition, .at(0))
    }
}
