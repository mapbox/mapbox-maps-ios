import XCTest
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

    func testScheduleTaskForwardsToDelegate() {
        var invoked = false

        delegatingMapClient.scheduleTask {
            invoked = true
        }
        delegate.scheduleTaskStub.invocations.first?.parameters()

        XCTAssertEqual(delegate.scheduleTaskStub.invocations.count, 1)
        XCTAssertTrue(invoked)
    }

    func testGetMetalViewForwardsToDelegate() {
        let expectedDevice = MTLCreateSystemDefaultDevice()
        let expectedView = MTKView()
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
        XCTAssertEqual(actualView, expectedView)
    }
}
