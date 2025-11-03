import XCTest
@testable @_spi(Metrics) @_spi(Restricted) import MapboxMaps

/// Test suite for `MapView` functionality and lifecycle management.
///
/// This test class covers the core functionality of `MapView`, including:
/// - Display link management and lifecycle
/// - Camera animation coordination
/// - Frame rate control and performance settings
/// - Memory management and resource cleanup
/// - Scene lifecycle integration
/// - Metal view configuration and rendering
///
/// The tests use mock objects to isolate the `MapView` behavior and verify
/// proper integration with system components like display links and notifications.
final class MapViewTests: XCTestCase {

    var notificationCenter: MockNotificationCenter!
    var displayLink: MockDisplayLink!
    var dependencyProvider: MockMapViewDependencyProvider!
    var cameraAnimatorsRunner: MockCameraAnimatorsRunner!
    var attributionURLOpener: MockAttributionURLOpener!
    var mapView: MapView!
    var window: UIWindow!
    var metalView: MockMetalView!

    /// Sets up the test environment with mock dependencies and a configured MapView.
    ///
    /// This method initializes all the mock objects needed for testing MapView functionality,
    /// including the notification center, display link, dependency provider, and camera
    /// animators runner. It also creates a MapView instance and adds it to a window
    /// to simulate a real-world usage scenario.
    override func setUpWithError() throws {
        try super.setUpWithError()
        notificationCenter = MockNotificationCenter()
        displayLink = MockDisplayLink()
        cameraAnimatorsRunner = MockCameraAnimatorsRunner()
        dependencyProvider = MockMapViewDependencyProvider()
        dependencyProvider.notificationCenter = notificationCenter
        dependencyProvider.makeDisplayLinkStub.defaultReturnValue = displayLink
        dependencyProvider.makeCameraAnimatorsRunnerStub.defaultReturnValue = cameraAnimatorsRunner
        attributionURLOpener = MockAttributionURLOpener()
        mapView = buildMapView()
        window = UIWindow()
        window.addSubview(mapView)

        metalView = try XCTUnwrap(dependencyProvider.makeMetalViewStub.invocations.first?.returnValue)
        // reset is required here to ignore the draw() invocation during initialization
        metalView.drawStub.reset()
    }

    override func tearDown() {
        metalView = nil
        window = nil
        mapView = nil
        attributionURLOpener = nil
        dependencyProvider = nil
        cameraAnimatorsRunner = nil
        displayLink = nil
        notificationCenter = nil
        super.tearDown()
    }

    /// Creates a MapView instance with the specified configuration for testing.
    ///
    /// - Parameter useApplicationState: Whether to use application state provider (currently unused).
    /// - Returns: A configured MapView instance ready for testing.
    func buildMapView(useApplicationState: Bool = true) -> MapView {
        return MapView(
            frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)),
            mapInitOptions: MapInitOptions(),
            dependencyProvider: dependencyProvider,
            urlOpener: attributionURLOpener)
    }

    /// Simulates a display link callback to test rendering behavior.
    ///
    /// This helper method extracts the display link target from the dependency provider
    /// and invokes its update method with the mock display link. This is used to test
    /// that display link callbacks properly trigger rendering updates without directly
    /// invoking setNeedsDisplay() on the Metal view.
    ///
    /// - Throws: An error if the display link target cannot be found or unwrapped.
    func invokeDisplayLinkCallback() throws {
        let makeDisplayLinkParams = try XCTUnwrap(dependencyProvider.makeDisplayLinkStub.invocations.first?.parameters)
        let target = try XCTUnwrap(makeDisplayLinkParams.target as? ForwardingDisplayLinkTarget)

        // Invoke the display link callback while there's an animator; verify that this alone does
        // not invoke setNeedsDisplay() on the MTKView
        target.update(with: displayLink)
    }

    /// Tests that MapView is properly deallocated when no longer referenced.
    ///
    /// This test verifies that MapView doesn't have retain cycles by creating a weak reference
    /// and ensuring it becomes nil after the strong reference is released within an autoreleasepool.
    func testMapViewIsReleased() throws {
        weak var weakMapView: MapView?
        autoreleasepool {
            let mapView = MapView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
            weakMapView = mapView
        }
        XCTAssertNil(weakMapView)
    }

    /// Tests the complete lifecycle of display link management.
    ///
    /// This test verifies that:
    /// 1. A display link is created and added to the run loop with correct parameters
    /// 2. The display link is properly invalidated when the map view is removed from its superview
    func testDisplayLinkManagement() throws {
        do {
            XCTAssertEqual(dependencyProvider.makeDisplayLinkStub.invocations.count, 1)
            XCTAssertEqual(displayLink.addStub.invocations.count, 1)
            XCTAssertEqual(displayLink.addStub.invocations.first?.parameters.runloop, .current)
            XCTAssertEqual(displayLink.addStub.invocations.first?.parameters.mode, .common)
        }

        do {
            mapView.removeFromSuperview()
            let displayLink = try XCTUnwrap(dependencyProvider.makeDisplayLinkStub.invocations.first?.returnValue)
            XCTAssertEqual(displayLink.invalidateStub.invocations.count, 1)
        }
    }

    func testCameraAnimatorsRunnerIsDisabledPriorToJoiningAWindow() {
        // Create a separate runner, to not share it with the other default MapView for this test.
        let cameraAnimatorsRunner = MockCameraAnimatorsRunner()
        dependencyProvider.makeCameraAnimatorsRunnerStub.defaultReturnValue = cameraAnimatorsRunner
        mapView = MapView(
            frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)),
            mapInitOptions: MapInitOptions(),
            dependencyProvider: dependencyProvider,
            urlOpener: attributionURLOpener)
        XCTAssertEqual(cameraAnimatorsRunner.isEnabled, false)

        window.addSubview(mapView)

        XCTAssertEqual(cameraAnimatorsRunner.isEnabled, true)
    }

    func testDisablesAnimationsWhenRemovedFromWindow() throws {
        cameraAnimatorsRunner.$isEnabled.reset()

        mapView.removeFromSuperview()

        XCTAssertEqual(cameraAnimatorsRunner.$isEnabled.setStub.invocations.map(\.parameters), [false])
    }

    func testDisablesAnimationsWhenUnableToCreateDisplayLink() throws {
        mapView = MapView(
            frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)),
            mapInitOptions: MapInitOptions(),
            dependencyProvider: dependencyProvider,
            urlOpener: attributionURLOpener)

        cameraAnimatorsRunner.$isEnabled.reset()
        dependencyProvider.makeDisplayLinkStub.defaultReturnValue = nil

        window.addSubview(mapView)

        XCTAssertEqual(cameraAnimatorsRunner.$isEnabled.setStub.invocations.map(\.parameters), [false])
    }

    @available(*, deprecated)
    func testPreferredFramesPerSecondIsInitiallyZero() {
        XCTAssertEqual(mapView.preferredFramesPerSecond, 0)
        XCTAssertEqual(displayLink.preferredFramesPerSecond, mapView.preferredFramesPerSecond)
    }

    @available(*, deprecated)
    func testPreferredFramesPerSecondUpdate() {
        mapView.preferredFramesPerSecond = 23

        XCTAssertEqual(displayLink.preferredFramesPerSecond, 23)
        XCTAssertEqual(mapView.preferredFramesPerSecond, 23)
    }

    func testPreferredFrameRateRangeIsDefault() throws {
        guard #available(iOS 15.0, *) else {
            throw XCTSkip("Test requires iOS 15 or higher.")
        }
        let preferredFramesRateRange = mapView.preferredFrameRateRange
        let defaultRange = CAFrameRateRange.default
        XCTAssertEqual(preferredFramesRateRange, defaultRange)
        XCTAssertEqual(displayLink.preferredFrameRateRange, defaultRange)
    }

    func testPreferredFrameRateRangeUpdate() throws {
        guard #available(iOS 15.0, *) else {
            throw XCTSkip("Test requires iOS 15 or higher.")
        }
        let frameRateRange = CAFrameRateRange(minimum: 0, maximum: 120, preferred: 80)
        mapView.preferredFrameRateRange = frameRateRange
        XCTAssertEqual(displayLink.preferredFrameRateRange, frameRateRange)
        XCTAssertEqual(mapView.preferredFrameRateRange, frameRateRange)
    }

    func testDisplayLinkTimestampIsNilWhenDisplayLinkIsNil() {
        mapView.removeFromSuperview()

        XCTAssertNil(mapView.displayLinkTimestamp)
    }

    func testDisplayLinkTimestampWhenDisplayLinkIsNonNil() {
        displayLink._timestamp = 0

        XCTAssertEqual(mapView.displayLinkTimestamp, displayLink.timestamp)
    }

    func testDisplayLinkDurationIsNilWhenDisplayLinkIsNil() {
        mapView.removeFromSuperview()

        XCTAssertNil(mapView.displayLinkDuration)
    }

    func testDisplayLinkDurationWhenDisplayLinkIsNonNil() {
        displayLink._duration = 4

        XCTAssertEqual(mapView.displayLinkDuration, displayLink.duration)
    }

    func testMetalViewSetNeedsDisplayIsTriggeredByScheduleRepaint() throws {
        mapView.scheduleRepaint()

        try invokeDisplayLinkCallback()

        XCTAssertEqual(metalView.drawStub.invocations.count, 1)
    }

    func testMetalViewDoesFitMapView() {
        let mapView = MapView(frame: .init(x: 50, y: 50, width: 100, height: 100))

        XCTAssertEqual(mapView.bounds, mapView.metalView?.frame)
    }

    func testMetalViewDoesResizeToFitMapView() {
        let mapView = MapView(frame: .init(x: 50, y: 50, width: 100, height: 100))
        mapView.frame = .init(x: 0, y: 0, width: 100, height: 100)

        XCTAssertEqual(mapView.bounds, mapView.metalView?.frame)
    }

    func testDisplayLinkInvokesParticipants() throws {
        var count = 0
        let token = mapView.__displayLinkSignalForTests.observe { _ in
            count += 1
        }

        XCTAssertEqual(count, 0)

        try invokeDisplayLinkCallback()

        XCTAssertEqual(count, 1)

        token.cancel()

        try invokeDisplayLinkCallback()

        XCTAssertEqual(count, 1)
    }

    func testDisplayLinkInvokesCameraAnimatorsRunner() throws {
        XCTAssertEqual(dependencyProvider.makeCameraAnimatorsRunnerStub.invocations.count, 1)
        let runner = try XCTUnwrap(dependencyProvider.makeCameraAnimatorsRunnerStub.invocations.first?.returnValue as? MockCameraAnimatorsRunner)

        try invokeDisplayLinkCallback()

        XCTAssertEqual(runner.updateStub.invocations.count, 1)
    }

    func testDisplayLinkNotPausedWhenDidMoveToWindowIfAppStateProviderIsNil() {
        // given
        mapView = buildMapView(useApplicationState: false)
        window = UIWindow()
        window.addSubview(mapView)

        // when
        mapView.didMoveToWindow()

        // then
        XCTAssertFalse(displayLink.isPaused)
    }

    func testSubscribesToCorrectNotifications() throws {
        let observers = notificationCenter.addObserverStub.invocations.map(\.parameters.observer)

        XCTAssertTrue(observers.allSatisfy { ($0 as AnyObject) === mapView })

        XCTAssertEqual(notificationCenter.addObserverStub.invocations.count, 4)
        XCTAssertEqual(notificationCenter.addObserverStub.invocations[0].parameters.name, UIApplication.didReceiveMemoryWarningNotification)
        XCTAssertEqual(notificationCenter.addObserverStub.invocations[1].parameters.name, UIScene.didEnterBackgroundNotification)
        XCTAssertEqual(notificationCenter.addObserverStub.invocations[2].parameters.name, UIScene.willDeactivateNotification)
        XCTAssertEqual(notificationCenter.addObserverStub.invocations[3].parameters.name, UIScene.didActivateNotification)
    }

    func testURLOpener() throws {
        let attributionMenu = AttributionMenu(urlOpener: attributionURLOpener, feedbackURLRef: Ref { nil })
        let url = URL(string: "http://example.com")!
        let attribution = Attribution(title: .testConstantASCII(withLength: 10), url: url)

        let menu = attributionMenu.menu(from: [attribution])
        guard let item = menu.elements.first, case let AttributionMenuElement.item(menuItem) = item else {
            XCTFail("Failed to unwrap AttributionMenuElement.item")
            return
        }
        menuItem.action?()

        XCTAssertEqual(attributionURLOpener.openAttributionURLStub.invocations.count, 1)
        XCTAssertEqual(attributionURLOpener.openAttributionURLStub.invocations.first?.parameters, url)
    }

    func testEventsFlushingOnDeinit() throws {
        dependencyProvider.makeEventsManagerStub.returnValueQueue.append(EventsManagerMock())

        autoreleasepool {
            mapView = buildMapView()
        }

        let flushStub = try XCTUnwrap(mapView.eventsManager as? EventsManagerMock).flushStub

        XCTAssertTrue(flushStub.invocations.isEmpty)

        resetAllStubs()
        mapView = nil

        XCTAssertEqual(flushStub.invocations.count, 1)
    }

    func testEnablesDisplayLinkWhenAnyTouchesBegan() {
        displayLink.$isPausedStub.reset()

        mapView.touchesBegan(.init(), with: nil)

        XCTAssertEqual(displayLink.$isPausedStub.setStub.invocations.count, 1)
        XCTAssertEqual(displayLink.$isPausedStub.setStub.invocations.first?.parameters, false)
    }
}

/// Test suite for `MapView` scene lifecycle integration and Metal view configuration.
///
/// This test class focuses on testing MapView behavior in relation to iOS scene lifecycle events,
/// including scene activation, deactivation, and background transitions. It also verifies
/// proper Metal view configuration and rendering behavior under different scene states.
///
/// Key areas covered:
/// - Scene lifecycle notification handling
/// - Display link state management during scene transitions
/// - Metal view configuration and rendering parameters
/// - Resource management during background transitions
final class MapViewTestsWithScene: XCTestCase {

    var notificationCenter: MockNotificationCenter!
    var displayLink: MockDisplayLink!
    var dependencyProvider: MockMapViewDependencyProvider!
    var attributionURLOpener: MockAttributionURLOpener!
    var applicationState: UIApplication.State!
    var applicationStateProvider: Ref<UIApplication.State>?
    var mapView: MapView!
    var window: UIWindow!
    var metalView: MockMetalView!

    override func setUpWithError() throws {
        try super.setUpWithError()
        notificationCenter = MockNotificationCenter()
        displayLink = MockDisplayLink()
        dependencyProvider = MockMapViewDependencyProvider()
        dependencyProvider.notificationCenter = notificationCenter
        dependencyProvider.makeDisplayLinkStub.defaultReturnValue = displayLink
        attributionURLOpener = MockAttributionURLOpener()
        applicationState = .active
        applicationStateProvider = Ref { self.applicationState }
        mapView = MapView(
            frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)),
            mapInitOptions: MapInitOptions(),
            dependencyProvider: dependencyProvider,
            urlOpener: attributionURLOpener)
        window = UIWindow()
        window.addSubview(mapView)

        metalView = try XCTUnwrap(dependencyProvider.makeMetalViewStub.invocations.first?.returnValue)
        // reset is required here to ignore the draw() invocation during initialization
        metalView.drawStub.reset()
    }

    override func tearDown() {
        metalView = nil
        window = nil
        mapView = nil
        applicationState = nil
        applicationStateProvider = nil
        attributionURLOpener = nil
        dependencyProvider = nil
        displayLink = nil

        notificationCenter = nil
        super.tearDown()
    }

    func testMapStyleInInitOptions() throws {
        XCTAssertEqual(mapView.mapboxMap.mapStyle, .standard)
        let mapStyle = MapStyle.outdoors
        var aView = MapView(frame: .zero, mapInitOptions: MapInitOptions(mapStyle: mapStyle))
        XCTAssertEqual(aView.mapboxMap.mapStyle, mapStyle)
    }

    func testDisplayLinkResumedWhenSceneDidActivate() throws {
        displayLink.$isPausedStub.setStub.reset()

        notificationCenter.post(name: UIScene.didActivateNotification, object: window.parentScene)

        XCTAssertEqual(displayLink.$isPausedStub.setStub.invocations.map(\.parameters), [false])
    }

    func testDisplayLinkRunningWhenSceneWillDeactivate() throws {
        displayLink.$isPausedStub.setStub.reset()

        notificationCenter.post(name: UIScene.willDeactivateNotification, object: window.parentScene)

        XCTAssertEqual(displayLink.$isPausedStub.setStub.invocations.map(\.parameters), [false])
    }

    func testReleaseDrawablesInvokedWhenSceneMovingToBackground() throws {
        notificationCenter.post(name: UIScene.didEnterBackgroundNotification, object: window.parentScene)

        XCTAssertEqual(metalView.releaseDrawablesStub.invocations.count, 1)
    }

    func testMetalViewHasCorrectParameters() throws {
        let mapViewSize = CGSize(width: 100, height: 100)
        mapView = MapView(
            frame: CGRect(origin: .zero, size: mapViewSize),
            mapInitOptions: MapInitOptions(),
            dependencyProvider: dependencyProvider,
            urlOpener: attributionURLOpener)

        let metalView = try XCTUnwrap(mapView.getMetalView(for: nil))

        XCTAssertEqual(metalView.translatesAutoresizingMaskIntoConstraints, false)
        XCTAssertEqual(metalView.autoResizeDrawable, false)
        XCTAssertEqual(metalView.contentScaleFactor, ScreenShim.nativeScale, accuracy: 0.001)
        XCTAssertEqual(metalView.contentMode, .center)
        XCTAssertEqual(metalView.isOpaque, true)
        XCTAssertEqual(metalView.layer.isOpaque, true)
#if !(swift(>=5.9) && os(visionOS))
        XCTAssertEqual(metalView.isPaused, true)
        XCTAssertEqual(metalView.enableSetNeedsDisplay, false)
#endif
        XCTAssertEqual(metalView.presentsWithTransaction, false)
        XCTAssertEqual(metalView.bounds.size, mapViewSize)
    }

    func testMetalViewHasMinimumSize() {
        let mapViewSize = CGSize.zero
        let minimumMetalViewSize = CGSize(width: 1, height: 1)
        mapView = MapView(
            frame: CGRect(origin: .zero, size: mapViewSize),
            mapInitOptions: MapInitOptions(),
            dependencyProvider: dependencyProvider,
            urlOpener: attributionURLOpener)

        let metalView = mapView.getMetalView(for: nil)

        XCTAssertEqual(metalView?.bounds.size, minimumMetalViewSize)
    }

    func testOpacityIsPropagatedToMetalView() {
        // given
        let opaque = Bool.testConstantValue()

        // when
        mapView.isOpaque = opaque

        // then
        XCTAssertEqual(opaque, metalView.isOpaque)
        XCTAssertEqual(opaque, metalView.layer.isOpaque)
    }
}
