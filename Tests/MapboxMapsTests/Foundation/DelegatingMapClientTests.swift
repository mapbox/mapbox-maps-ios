import XCTest
import MetalKit
@testable import MapboxMaps

final class DelegatingMapClientTests: XCTestCase {

    var delegatingMapClient: DelegatingMapClient!
    // swiftlint:disable:next weak_delegate
    var delegate: MockDelegatingMapClientDelegate!

    override func setUp() {
        super.setUp()
        delegatingMapClient = DelegatingMapClient()
        delegate = MockDelegatingMapClientDelegate()
        delegatingMapClient.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        delegatingMapClient = nil
        super.tearDown()
    }

    func testScheduleRepaintForwardsToDelegate() {
        delegatingMapClient.scheduleRepaint()

        XCTAssertEqual(delegate.scheduleRepaintStub.invocations.count, 1)
    }

    func testGetMetalViewForwardsToDelegate() {
        let expectedDevice = MTLCreateSystemDefaultDevice()
        let expectedView = MetalView(frame: CGRect(x: 0, y: 0, width: 64, height: 64), device: nil)
        delegate.getMetalViewStub.defaultReturnValue = expectedView

        let actualView = delegatingMapClient.getMetalView(for: expectedDevice)

        XCTAssertEqual(delegate.getMetalViewStub.invocations.count, 1)
        guard let actualDevice = delegate.getMetalViewStub.invocations.first?.parameters else {
            return
        }
        if let expected = expectedDevice {
            XCTAssertTrue(actualDevice === expected)
        } else {
            XCTAssertNil(actualDevice)
            XCTAssertNil(expectedDevice)
        }
        XCTAssertIdentical(actualView, expectedView)
    }
}
