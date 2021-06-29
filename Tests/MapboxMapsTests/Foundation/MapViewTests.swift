import XCTest
@testable import MapboxMaps

final class MapViewTests: XCTestCase {

    var displayLink: MockDisplayLink!
    var dependencyProvider: MockMapViewDependencyProvider!
    var mapView: MapView!
    var window: UIWindow!
    var metalView: MockMetalView!

    override func setUpWithError() throws {
        try super.setUpWithError()
        displayLink = MockDisplayLink()
        dependencyProvider = MockMapViewDependencyProvider()
        dependencyProvider.makeDisplayLinkStub.defaultReturnValue = displayLink
        mapView = MapView(
            frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)),
            mapInitOptions: MapInitOptions(),
            dependencyProvider: dependencyProvider)
        window = UIWindow()
        window.addSubview(mapView)
        metalView = try XCTUnwrap(XCTUnwrap(dependencyProvider.makeMetalViewStub.returnedValues.first))
        // reset is required here to ignore the setNeedsDisplay() invocation during initialization
        metalView.setNeedsDisplayStub.reset()
    }

    override func tearDown() {
        metalView = nil
        window = nil
        mapView = nil
        dependencyProvider = nil
        displayLink = nil
        super.tearDown()
    }

    func invokeDisplayLinkCallback() throws {
        let makeDisplayLinkParams = try XCTUnwrap(dependencyProvider.makeDisplayLinkStub.parameters.first)
        let target = try XCTUnwrap(makeDisplayLinkParams.target as? NSObject)

        // Invoke the display link callback while there's an animator; verify that this alone does
        // not invoke setNeedsDisplay() on the MTKView
        target.perform(makeDisplayLinkParams.selector, with: displayLink)
    }

    // test that map view is deinited
    func testMapViewIsReleased() throws {
        weak var weakMapView: MapView?
        autoreleasepool {
            let mapView = MapView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
            weakMapView = mapView
        }
        XCTAssertNil(weakMapView)
    }

    func testDisplayLinkManagement() throws {
        do {
            XCTAssertEqual(dependencyProvider.makeDisplayLinkStub.invocations.count, 1)
            XCTAssertEqual(displayLink.addStub.invocations.count, 1)
            XCTAssertEqual(displayLink.addStub.parameters.first?.runloop, .current)
            XCTAssertEqual(displayLink.addStub.parameters.first?.mode, .common)
        }

        do {
            mapView.removeFromSuperview()
            let displayLink = try XCTUnwrap(dependencyProvider.makeDisplayLinkStub.returnedValues.first)
            XCTAssertEqual(displayLink?.invalidateStub.invocations.count, 1)
        }
    }

    func testPreferredFramesPerSecondIsInitiallyMaximum() {
        XCTAssertEqual(mapView.preferredFramesPerSecond, .maximum)
    }

    func testPreferredFramesPerSecondIsPropagatedToDisplayLink() {
        XCTAssertEqual(displayLink.preferredFramesPerSecond, mapView.preferredFramesPerSecond.rawValue)

        mapView.preferredFramesPerSecond = PreferredFPS(rawValue: 23)

        XCTAssertEqual(displayLink.preferredFramesPerSecond, 23)
    }

    func testAnimatorCompletionBlocksAreRemoved() throws {
        let firstCompletion = PendingAnimationCompletion(completion: { _ in }, animatingPosition: .end)
        let secondCompletion = PendingAnimationCompletion(completion: { _ in }, animatingPosition: .current)

        mapView.pendingAnimatorCompletionBlocks.append(firstCompletion)
        mapView.pendingAnimatorCompletionBlocks.append(secondCompletion)
        XCTAssertEqual(mapView.pendingAnimatorCompletionBlocks.count, 2)

        try invokeDisplayLinkCallback()
        XCTAssertEqual(mapView.pendingAnimatorCompletionBlocks.count, 0)
    }

    func testMetalViewSetNeedsDisplayIsNotAutomaticallyTriggeredByAnimators() throws {
        mapView.addCameraAnimator(MockCameraAnimator())

        try invokeDisplayLinkCallback()

        XCTAssertTrue(metalView.setNeedsDisplayStub.invocations.isEmpty)
    }

    func testMetalViewSetNeedsDisplayIsNotAutomaticallyTriggeredByPendingCompletionBlocks() throws {
        mapView.pendingAnimatorCompletionBlocks.append(
            PendingAnimationCompletion(completion: { (_) in }, animatingPosition: .end))

        try invokeDisplayLinkCallback()

        XCTAssertTrue(metalView.setNeedsDisplayStub.invocations.isEmpty)
    }

    func testMetalViewSetNeedsDisplayIsTriggeredByScheduleRepaint() throws {
        mapView.scheduleRepaint()

        try invokeDisplayLinkCallback()

        XCTAssertEqual(metalView.setNeedsDisplayStub.invocations.count, 1)
    }

    func testPendingCompletionBlocksAreInvoked() throws {
        var invocationCount = 0
        mapView.pendingAnimatorCompletionBlocks.append(PendingAnimationCompletion(completion: { (_) in
            invocationCount += 1
        }, animatingPosition: .end))

        try invokeDisplayLinkCallback()

        XCTAssertEqual(invocationCount, 1)
    }
}
