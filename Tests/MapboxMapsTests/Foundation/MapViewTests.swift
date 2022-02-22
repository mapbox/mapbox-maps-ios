import XCTest
@testable @_spi(Metrics) import MapboxMaps

final class MapViewTests: XCTestCase {

    var displayLink: MockDisplayLink!
    var notificationCenter: MockNotificationCenter!
    var bundle: MockBundle!
    var dependencyProvider: MockMapViewDependencyProvider!
    var mapView: MapView!
    var window: UIWindow!
    var metalView: MockMetalView!

    override func setUpWithError() throws {
        try super.setUpWithError()
        displayLink = MockDisplayLink()
        notificationCenter = MockNotificationCenter()
        bundle = MockBundle()
        dependencyProvider = MockMapViewDependencyProvider()
        dependencyProvider.makeDisplayLinkStub.defaultReturnValue = displayLink
        dependencyProvider.makeNotificationCenterStub.defaultReturnValue = notificationCenter
        dependencyProvider.makeBundleStub.defaultReturnValue = bundle
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
        bundle = nil
        notificationCenter = nil
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
            assertMethodCall(dependencyProvider.makeDisplayLinkStub)
            assertMethodCall(displayLink.addStub)
            XCTAssertEqual(displayLink.addStub.parameters.first?.runloop, .current)
            XCTAssertEqual(displayLink.addStub.parameters.first?.mode, .common)
        }

        do {
            mapView.removeFromSuperview()
            let displayLink = try XCTUnwrap(XCTUnwrap(dependencyProvider.makeDisplayLinkStub.returnedValues.first))
            assertMethodCall(displayLink.invalidateStub)
        }
    }

    func testPreferredFramesPerSecondIsInitiallyZero() {
        XCTAssertEqual(mapView.preferredFramesPerSecond, 0)
        XCTAssertEqual(displayLink.preferredFramesPerSecond, mapView.preferredFramesPerSecond)
    }

    func testPreferredFramesPerSecondUpdate() {
        mapView.preferredFramesPerSecond = 23

        XCTAssertEqual(displayLink.preferredFramesPerSecond, 23)
        XCTAssertEqual(mapView.preferredFramesPerSecond, 23)
    }

    // Checking Swift version as a proxy for iOS SDK version to enable
    // building with iOS SDKs < 15
    #if swift(>=5.5)
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
    #endif

    func testDisplayLinkTimestampIsNilWhenDisplayLinkIsNil() {
        mapView.removeFromSuperview()

        XCTAssertNil(mapView.displayLinkTimestamp)
    }

    func testDisplayLinkTimestampWhenDisplayLinkIsNonNil() {
        displayLink.timestamp = .random(in: 0..<CFTimeInterval.greatestFiniteMagnitude)

        XCTAssertEqual(mapView.displayLinkTimestamp, displayLink.timestamp)
    }

    func testDisplayLinkDurationIsNilWhenDisplayLinkIsNil() {
        mapView.removeFromSuperview()

        XCTAssertNil(mapView.displayLinkDuration)
    }

    func testDisplayLinkDurationWhenDisplayLinkIsNonNil() {
        displayLink.duration = .random(in: 0..<CFTimeInterval.greatestFiniteMagnitude)

        XCTAssertEqual(mapView.displayLinkDuration, displayLink.duration)
    }

    func testMetalViewSetNeedsDisplayIsTriggeredByScheduleRepaint() throws {
        mapView.scheduleRepaint()

        try invokeDisplayLinkCallback()

        assertMethodCall(metalView.setNeedsDisplayStub)
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
        let participant1 = MockDisplayLinkParticipant()
        let participant2 = MockDisplayLinkParticipant()

        mapView.add(participant1)

        try invokeDisplayLinkCallback()

        assertMethodCall(participant1.participateStub)
        assertMethodNotCall(participant2.participateStub)

        mapView.add(participant2)

        try invokeDisplayLinkCallback()

        assertMethodCall(participant1.participateStub, times: 2)
        assertMethodCall(participant2.participateStub)

        mapView.remove(participant2)

        try invokeDisplayLinkCallback()

        assertMethodCall(participant1.participateStub, times: 3)
        assertMethodCall(participant2.participateStub)

        mapView.remove(participant1)

        try invokeDisplayLinkCallback()

        assertMethodCall(participant1.participateStub, times: 3)
        assertMethodCall(participant2.participateStub)
    }

    func testAppLifecycleNotificationSubscribedWhenDidMoveToNewWindow() {
        let notificationCenter = MockNotificationCenter()
        let bundle = MockBundle()
        bundle.infoDictionaryStub.defaultReturnValue = [:]
        dependencyProvider.makeNotificationCenterStub.defaultReturnValue = notificationCenter
        dependencyProvider.makeBundleStub.defaultReturnValue = bundle
        let mapView = MapView(
            frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)),
            mapInitOptions: MapInitOptions(),
            dependencyProvider: dependencyProvider)

        window.addSubview(mapView)

        XCTAssertTrue(notificationCenter.addObserverStub.invocations.contains(where: { invocation in
            invocation.parameters.name == UIApplication.didEnterBackgroundNotification
        }))
        XCTAssertTrue(notificationCenter.addObserverStub.invocations.contains(where: { invocation in
            invocation.parameters.name == UIApplication.willEnterForegroundNotification
        }))
        XCTAssertTrue(notificationCenter.addObserverStub.invocations.contains(where: { invocation in
            invocation.parameters.name == UIApplication.didReceiveMemoryWarningNotification
        }))
        assertMethodCall(notificationCenter.addObserverStub, times: 3)
    }

    func testSceneLifecycleNotificationSubscribedWhenDidMoveToNewWindow() throws {
        guard #available(iOS 13.0, *) else {
            throw XCTSkip("Test requires iOS 13 or higher.")
        }

        let notificationCenter = MockNotificationCenter()
        let bundle = MockBundle()
        bundle.infoDictionaryStub.defaultReturnValue = ["UIApplicationSceneManifest": []]
        dependencyProvider.makeNotificationCenterStub.defaultReturnValue = notificationCenter
        dependencyProvider.makeBundleStub.defaultReturnValue = bundle
        let mapView = MapView(
            frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)),
            mapInitOptions: MapInitOptions(),
            dependencyProvider: dependencyProvider)

        window.addSubview(mapView)

        XCTAssertTrue(notificationCenter.addObserverStub.invocations.contains(where: { invocation in
            return invocation.parameters.name == UIScene.didEnterBackgroundNotification &&
            invocation.parameters.object as? UIScene == window.parentScene
        }))
        XCTAssertTrue(notificationCenter.addObserverStub.invocations.contains(where: { invocation in
            return invocation.parameters.name == UIScene.willEnterForegroundNotification &&
            invocation.parameters.object as? UIScene == window.parentScene
        }))
        XCTAssertTrue(notificationCenter.addObserverStub.invocations.contains(where: { invocation in
            invocation.parameters.name == UIApplication.didReceiveMemoryWarningNotification
        }))
        assertMethodCall(notificationCenter.addObserverStub, times: 3)
    }

    func testLifecycleNotificationsUnsubscribedWhenMovingFromWindow() throws {
        guard #available(iOS 13.0, *) else {
            throw XCTSkip("Test requires iOS 13 or higher.")
        }

        let notificationCenter = MockNotificationCenter()
        dependencyProvider.makeNotificationCenterStub.defaultReturnValue = notificationCenter
        let mapView = MapView(
            frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)),
            mapInitOptions: MapInitOptions(),
            dependencyProvider: dependencyProvider)
        window.addSubview(mapView)
        notificationCenter.removeObserverStub.reset()

        mapView.removeFromSuperview()

        XCTAssertTrue(notificationCenter.removeObserverStub.invocations.contains(where: { invocation in
            invocation.parameters.name == UIApplication.didEnterBackgroundNotification
        }))
        XCTAssertTrue(notificationCenter.removeObserverStub.invocations.contains(where: { invocation in
            invocation.parameters.name == UIApplication.willEnterForegroundNotification
        }))
        XCTAssertTrue(notificationCenter.removeObserverStub.invocations.contains(where: { invocation in
            invocation.parameters.name == UIScene.didEnterBackgroundNotification
        }))
        XCTAssertTrue(notificationCenter.removeObserverStub.invocations.contains(where: { invocation in
            return invocation.parameters.name == UIScene.willEnterForegroundNotification
        }))
        assertMethodCall(notificationCenter.removeObserverStub, times: 4)
    }

    func testDisplayLinkPausedWhenAppMovingToBackground() {
        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)

        XCTAssertEqual(displayLink.$isPaused.setStub.parameters, [true])
    }

    func testDisplayLinkResumedWhenAppMovingToForeground() {
        notificationCenter.post(name: UIApplication.willEnterForegroundNotification, object: nil)

        XCTAssertEqual(displayLink.$isPaused.setStub.parameters, [false])
    }

    func testDisplayLinkResumedWhenSceneMovingToForeground() throws {
        guard #available(iOS 13.0, *) else {
            throw XCTSkip("Test requires iOS 13 or higher.")
        }
        bundle.infoDictionaryStub.defaultReturnValue = ["UIApplicationSceneManifest": []]
        mapView.didMoveToWindow()

        notificationCenter.post(name: UIScene.willEnterForegroundNotification, object: window.parentScene)

        XCTAssertEqual(displayLink.$isPaused.setStub.parameters, [false])
    }

    func testDisplayLinkPausedWhenSceneMovingToBackground() throws {
        guard #available(iOS 13.0, *) else {
            throw XCTSkip("Test requires iOS 13 or higher.")
        }
        bundle.infoDictionaryStub.defaultReturnValue = ["UIApplicationSceneManifest": []]
        mapView.didMoveToWindow()

        notificationCenter.post(name: UIScene.didEnterBackgroundNotification, object: window.parentScene)

        XCTAssertEqual(displayLink.$isPaused.setStub.parameters, [true])
    }
}
