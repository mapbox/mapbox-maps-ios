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
    var locationProducer: MockLocationProducer!
    var orientationProvider: MockInterfaceOrientationProvider!
    var attributionURLOpener: MockAttributionURLOpener!

    override func setUpWithError() throws {
        try super.setUpWithError()
        displayLink = MockDisplayLink()
        notificationCenter = MockNotificationCenter()
        bundle = MockBundle()
        locationProducer = MockLocationProducer()
        dependencyProvider = MockMapViewDependencyProvider()
        dependencyProvider.makeDisplayLinkStub.defaultReturnValue = displayLink
        dependencyProvider.makeNotificationCenterStub.defaultReturnValue = notificationCenter
        dependencyProvider.makeBundleStub.defaultReturnValue = bundle
        dependencyProvider.makeLocationProducerStub.defaultReturnValue = locationProducer
        orientationProvider = MockInterfaceOrientationProvider()
        attributionURLOpener = MockAttributionURLOpener()
        mapView = MapView(
            frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)),
            mapInitOptions: MapInitOptions(),
            dependencyProvider: dependencyProvider,
            orientationProvider: orientationProvider,
            urlOpener: attributionURLOpener)
        window = UIWindow()
        window.addSubview(mapView)
        metalView = try XCTUnwrap(XCTUnwrap(dependencyProvider.makeMetalViewStub.invocations.first?.returnValue))
    }

    override func tearDown() {
        metalView = nil
        window = nil
        mapView = nil
        dependencyProvider = nil
        displayLink = nil
        bundle = nil
        notificationCenter = nil
        orientationProvider = nil
        attributionURLOpener = nil
        locationProducer = nil
        super.tearDown()
    }

    func invokeDisplayLinkCallback() throws {
        let makeDisplayLinkParams = try XCTUnwrap(dependencyProvider.makeDisplayLinkStub.invocations.first?.parameters)
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
            XCTAssertEqual(displayLink.addStub.invocations.first?.parameters.runloop, .current)
            XCTAssertEqual(displayLink.addStub.invocations.first?.parameters.mode, .common)
        }

        do {
            mapView.removeFromSuperview()
            let displayLink = try XCTUnwrap(dependencyProvider.makeDisplayLinkStub.invocations.first?.returnValue)
            XCTAssertEqual(displayLink.invalidateStub.invocations.count, 1)
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

    func testMetalViewDrawIsTriggeredByScheduleRepaint() throws {
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
        let participant1 = MockDisplayLinkParticipant()
        let participant2 = MockDisplayLinkParticipant()

        mapView.add(participant1)

        try invokeDisplayLinkCallback()

        XCTAssertEqual(participant1.participateStub.invocations.count, 1)
        XCTAssertEqual(participant2.participateStub.invocations.count, 0)

        mapView.add(participant2)

        try invokeDisplayLinkCallback()

        XCTAssertEqual(participant1.participateStub.invocations.count, 2)
        XCTAssertEqual(participant2.participateStub.invocations.count, 1)

        mapView.remove(participant2)

        try invokeDisplayLinkCallback()

        XCTAssertEqual(participant1.participateStub.invocations.count, 3)
        XCTAssertEqual(participant2.participateStub.invocations.count, 1)

        mapView.remove(participant1)

        try invokeDisplayLinkCallback()

        XCTAssertEqual(participant1.participateStub.invocations.count, 3)
        XCTAssertEqual(participant2.participateStub.invocations.count, 1)
    }

    func testDisplayLinkInvokesCameraAnimatorsRunner() throws {
        XCTAssertEqual(dependencyProvider.makeCameraAnimatorsRunnerStub.invocations.count, 1)
        let runner = try XCTUnwrap(dependencyProvider.makeCameraAnimatorsRunnerStub.invocations.first?.returnValue as? MockCameraAnimatorsRunner)

        try invokeDisplayLinkCallback()

        XCTAssertEqual(runner.updateStub.invocations.count, 1)
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
            dependencyProvider: dependencyProvider,
            orientationProvider: orientationProvider,
            urlOpener: attributionURLOpener)

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
        XCTAssertEqual(notificationCenter.addObserverStub.invocations.count, 3)
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
            dependencyProvider: dependencyProvider,
            orientationProvider: orientationProvider,
            urlOpener: attributionURLOpener)

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
        XCTAssertEqual(notificationCenter.addObserverStub.invocations.count, 3)
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
            dependencyProvider: dependencyProvider,
            orientationProvider: orientationProvider,
            urlOpener: attributionURLOpener)
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
        XCTAssertEqual(notificationCenter.removeObserverStub.invocations.count, 4)
    }

    func testDisplayLinkPausedWhenAppMovingToBackground() {
        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)

        XCTAssertEqual(displayLink.$isPaused.setStub.invocations.map(\.parameters), [true])
    }

    func testDisplayLinkResumedWhenAppMovingToForeground() {
        notificationCenter.post(name: UIApplication.willEnterForegroundNotification, object: nil)

        XCTAssertEqual(displayLink.$isPaused.setStub.invocations.map(\.parameters), [false])
    }

    func testDisplayLinkResumedWhenSceneMovingToForeground() throws {
        guard #available(iOS 13.0, *) else {
            throw XCTSkip("Test requires iOS 13 or higher.")
        }
        bundle.infoDictionaryStub.defaultReturnValue = ["UIApplicationSceneManifest": []]
        mapView.didMoveToWindow()

        notificationCenter.post(name: UIScene.willEnterForegroundNotification, object: window.parentScene)

        XCTAssertEqual(displayLink.$isPaused.setStub.invocations.map(\.parameters), [false])
    }

    func testDisplayLinkPausedWhenSceneMovingToBackground() throws {
        guard #available(iOS 13.0, *) else {
            throw XCTSkip("Test requires iOS 13 or higher.")
        }
        bundle.infoDictionaryStub.defaultReturnValue = ["UIApplicationSceneManifest": []]
        mapView.didMoveToWindow()

        notificationCenter.post(name: UIScene.didEnterBackgroundNotification, object: window.parentScene)

        XCTAssertEqual(displayLink.$isPaused.setStub.invocations.map(\.parameters), [true])
    }

    func testOrientationProviderIsUsed() throws {
        try invokeDisplayLinkCallback()

        XCTAssertEqual(orientationProvider.interfaceOrientationStub.invocations.count, 1)
    }

    func testOrientationChangeIsPropagated() throws {
        let orientations: [UIInterfaceOrientation] = [.portrait, .landscapeLeft, .landscapeRight, .portraitUpsideDown]
        for orientation in orientations {
            orientationProvider.interfaceOrientationStub.defaultReturnValue = orientation

            try invokeDisplayLinkCallback()

            XCTAssertEqual(locationProducer.headingOrientation, CLDeviceOrientation(interfaceOrientation: orientation))
        }
    }

    func testURLOpener() {
        let manager = AttributionDialogManager(dataSource: MockAttributionDataSource(), delegate: MockAttributionDialogManagerDelegate())
        let url = URL(string: "http://example.com")!
        let attribution = Attribution(title: .randomASCII(withLength: 10), url: url)

        mapView.attributionDialogManager(manager, didTriggerActionFor: attribution)

        XCTAssertEqual(attributionURLOpener.openAttributionURLStub.invocations.count, 1)
        XCTAssertEqual(attributionURLOpener.openAttributionURLStub.invocations.first?.parameters, url)
    }
}
