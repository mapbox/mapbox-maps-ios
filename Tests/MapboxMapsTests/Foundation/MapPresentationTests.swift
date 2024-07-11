import XCTest
@testable import MapboxMaps

class MapPresentationTests: XCTestCase {
    @TestPublished var displaysAnnotations = false

    func testSyncAsync() {
        let metalView = MetalView(frame: .zero, device: nil)
        let me = MapPresentation()
        XCTAssertEqual(me.presentsWithTransaction, false)
        XCTAssertEqual(me.mode, .automatic)
        XCTAssertEqual(metalView.presentsWithTransaction, false)

        me.presentsWithTransaction = true
        XCTAssertEqual(me.presentsWithTransaction, true)
        XCTAssertEqual(me.mode, .sync)

        me.metalView = metalView
        XCTAssertEqual(metalView.presentsWithTransaction, true)

        me.presentsWithTransaction = false
        XCTAssertEqual(metalView.presentsWithTransaction, false)
        XCTAssertEqual(me.presentsWithTransaction, false)
        XCTAssertEqual(me.mode, .async)
    }

    func testAutomatic() {
        let metalView = MetalView(frame: .zero, device: nil)
        let me = MapPresentation()
        me.metalView = metalView
        me.displaysAnnotations = $displaysAnnotations

        XCTAssertEqual(metalView.presentsWithTransaction, false)

        displaysAnnotations = true
        XCTAssertEqual(metalView.presentsWithTransaction, true)

        displaysAnnotations = false
        XCTAssertEqual(metalView.presentsWithTransaction, false)

        me.mode = .async
        XCTAssertEqual(metalView.presentsWithTransaction, false)

        displaysAnnotations = true
        XCTAssertEqual(metalView.presentsWithTransaction, false) // due to async mode

        me.mode = .sync
        XCTAssertEqual(metalView.presentsWithTransaction, true)

        displaysAnnotations = false
        XCTAssertEqual(metalView.presentsWithTransaction, true) // due to sync mode
    }
}
