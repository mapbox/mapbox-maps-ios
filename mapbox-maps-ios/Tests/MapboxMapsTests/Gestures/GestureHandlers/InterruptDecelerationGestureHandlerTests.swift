import XCTest
@testable import MapboxMaps

final class InterruptDecelerationGestureHandlerTests: XCTestCase {
    var view: UIView!
    var gestureRecognizer: MockTapGestureRecognizer!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var gestureHandler: InterruptDecelerationGestureHandler!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureHandlerDelegate!

    override func setUp() {
        super.setUp()
        view = UIView()
        gestureRecognizer = MockTapGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        cameraAnimationsManager = MockCameraAnimationsManager()
        gestureHandler = InterruptDecelerationGestureHandler(gestureRecognizer: gestureRecognizer,
                                                             cameraAnimationsManager: cameraAnimationsManager)
        delegate = MockGestureHandlerDelegate()
        gestureHandler.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        gestureHandler = nil
        cameraAnimationsManager = nil
        gestureRecognizer = nil
        view = nil
        super.tearDown()
    }

    func testDecelerationAnimationCancellation() throws {
        gestureRecognizer.getStateStub.defaultReturnValue = .recognized
        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsOwnersTypesStub.invocations.count, 1)

        let invocation = try XCTUnwrap(cameraAnimationsManager.cancelAnimationsOwnersTypesStub.invocations.first)
        XCTAssertEqual(invocation.parameters.owners, [.cameraAnimationsManager])
        XCTAssertEqual(invocation.parameters.types, [.deceleration])
    }

    func testNoCancellationOnNonRecognizedGesture() throws {
        gestureRecognizer.getStateStub.defaultReturnValue = .cancelled
        gestureRecognizer.sendActions()

        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsOwnersTypesStub.invocations.count, 0)
    }

    func testSimultaniousGesturesRecognition() {
        let anotherRecognizer = MockTapGestureRecognizer()

        XCTAssertTrue(gestureHandler.gestureRecognizer(gestureRecognizer,
                                                       shouldRecognizeSimultaneouslyWith: anotherRecognizer))
    }
}
