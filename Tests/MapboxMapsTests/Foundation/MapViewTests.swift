import XCTest
@testable @_spi(Metrics) import MapboxMaps

final class MapViewTests: XCTestCase {

    var notificationCenter: MockNotificationCenter!
    var bundle: MockBundle!
    var displayLink: MockDisplayLink!
    var dependencyProvider: MockMapViewDependencyProvider!
    var cameraAnimatorsRunner: MockCameraAnimatorsRunner!
    var attributionURLOpener: MockAttributionURLOpener!
    @MutableRef var applicationState: UIApplication.State = .active
    var mapView: MapView!
    var window: UIWindow!
    var metalView: MockMetalView!

    override func setUpWithError() throws {
        try super.setUpWithError()
        notificationCenter = MockNotificationCenter()
        bundle = MockBundle()
        displayLink = MockDisplayLink()
        cameraAnimatorsRunner = MockCameraAnimatorsRunner()
        dependencyProvider = MockMapViewDependencyProvider()
        dependencyProvider.notificationCenter = notificationCenter
        dependencyProvider.bundle = bundle
        dependencyProvider.makeDisplayLinkStub.defaultReturnValue = displayLink
        dependencyProvider.makeCameraAnimatorsRunnerStub.defaultReturnValue = cameraAnimatorsRunner
        attributionURLOpener = MockAttributionURLOpener()
        applicationState = .active
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
        bundle = nil
        notificationCenter = nil
        super.tearDown()
    }

    func buildMapView(useApplicationState: Bool = true) -> MapView {
        return MapView(
            frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)),
            mapInitOptions: MapInitOptions(),
            dependencyProvider: dependencyProvider,
            urlOpener: attributionURLOpener,
            applicationStateProvider: useApplicationState ? $applicationState : nil)
    }

    func invokeDisplayLinkCallback() throws {
        let makeDisplayLinkParams = try XCTUnwrap(dependencyProvider.makeDisplayLinkStub.invocations.first?.parameters)
        let target = try XCTUnwrap(makeDisplayLinkParams.target as? ForwardingDisplayLinkTarget)

        // Invoke the display link callback while there's an animator; verify that this alone does
        // not invoke setNeedsDisplay() on the MTKView
        target.update(with: displayLink)
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

    func testCameraAnimatorsRunnerIsDisabledPriorToJoiningAWindow() {
        // Create a separate runner, to not share it with the other default MapView for this test.
        let cameraAnimatorsRunner = MockCameraAnimatorsRunner()
        dependencyProvider.makeCameraAnimatorsRunnerStub.defaultReturnValue = cameraAnimatorsRunner
        mapView = MapView(
            frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)),
            mapInitOptions: MapInitOptions(),
            dependencyProvider: dependencyProvider,
            urlOpener: attributionURLOpener,
            applicationStateProvider: $applicationState)
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
            urlOpener: attributionURLOpener,
            applicationStateProvider: $applicationState)

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
        displayLink._timestamp = .random(in: 0..<CFTimeInterval.greatestFiniteMagnitude)

        XCTAssertEqual(mapView.displayLinkTimestamp, displayLink.timestamp)
    }

    func testDisplayLinkDurationIsNilWhenDisplayLinkIsNil() {
        mapView.removeFromSuperview()

        XCTAssertNil(mapView.displayLinkDuration)
    }

    func testDisplayLinkDurationWhenDisplayLinkIsNonNil() {
        displayLink._duration = .random(in: 0..<CFTimeInterval.greatestFiniteMagnitude)

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

    func testDisplayLinkPausedWhenAppWillResignActive() {
        displayLink.$isPausedStub.setStub.reset()

        notificationCenter.post(name: UIApplication.willResignActiveNotification, object: nil)

        XCTAssertEqual(displayLink.$isPausedStub.setStub.invocations.map(\.parameters), [true])
    }

    func testDisplayLinkPausedWhenAppDidEnterBackground() {
        displayLink.$isPausedStub.setStub.reset()

        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)

        XCTAssertEqual(displayLink.$isPausedStub.setStub.invocations.map(\.parameters), [true])
    }

    func testDisplayLinkPausedWhenDidMoveToWindowIfAppStateIsInactive() {
        // given
        applicationState = .inactive

        // when
        mapView.didMoveToWindow()

        // then
        XCTAssertTrue(displayLink.isPaused)
    }

    func testDisplayLinkPausedWhenDidMoveToWindowIfAppStateIsBackground() {
        // given
        applicationState = .background

        // when
        mapView.didMoveToWindow()

        // then
        XCTAssertTrue(displayLink.isPaused)
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

    func testDisplayLinkNotPausedWhenDidMoveToWindowIfAppStateIsActive() {
        // given
        applicationState = .active

        // when
        mapView.didMoveToWindow()

        // then
        XCTAssertFalse(displayLink.isPaused)
    }

    func testReleaseDrawablesInvokedWhenAppDidBecomeActive() {
        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)

        XCTAssertEqual(metalView.releaseDrawablesStub.invocations.count, 1)
    }

    func testDisplayLinkResumedWhenAppDidBecomeActiveOnIOS12() throws {
        if #available(iOS 13.0, *) {
            throw XCTSkip("Test applies only on iOS 12")
        }

        notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)

        XCTAssertEqual(displayLink.$isPausedStub.setStub.invocations.map(\.parameters), [false])
    }

    func testSubscribesToCorrectNotificationsOniOS12() throws {
        if #available(iOS 13, *) {
            throw XCTSkip()
        }

        let observers = notificationCenter.addObserverStub.invocations.map(\.parameters.observer)

        XCTAssertTrue(observers.allSatisfy { ($0 as AnyObject) === mapView })

        XCTAssertEqual(notificationCenter.addObserverStub.invocations.count, 4)

        XCTAssertEqual(notificationCenter.addObserverStub.invocations[0].parameters.name, UIApplication.didBecomeActiveNotification)
        XCTAssertEqual(notificationCenter.addObserverStub.invocations[1].parameters.name, UIApplication.didEnterBackgroundNotification)
        XCTAssertEqual(notificationCenter.addObserverStub.invocations[2].parameters.name, UIApplication.willResignActiveNotification)
        XCTAssertEqual(notificationCenter.addObserverStub.invocations[3].parameters.name, UIApplication.didReceiveMemoryWarningNotification)

    }
    func testSubscribesToCorrectNotifications() throws {
        guard #available(iOS 13, *) else {
            throw XCTSkip()
        }
        let observers = notificationCenter.addObserverStub.invocations.map(\.parameters.observer)

        XCTAssertTrue(observers.allSatisfy { ($0 as AnyObject) === mapView })

        XCTAssertEqual(notificationCenter.addObserverStub.invocations.count, 6)
        XCTAssertEqual(notificationCenter.addObserverStub.invocations[0].parameters.name, UIScene.didEnterBackgroundNotification)
        XCTAssertEqual(notificationCenter.addObserverStub.invocations[1].parameters.name, UIScene.willDeactivateNotification)
        XCTAssertEqual(notificationCenter.addObserverStub.invocations[2].parameters.name, UIScene.didActivateNotification)
        XCTAssertEqual(notificationCenter.addObserverStub.invocations[3].parameters.name, UIApplication.didEnterBackgroundNotification)
        XCTAssertEqual(notificationCenter.addObserverStub.invocations[4].parameters.name, UIApplication.willResignActiveNotification)
        XCTAssertEqual(notificationCenter.addObserverStub.invocations[5].parameters.name, UIApplication.didReceiveMemoryWarningNotification)
    }

    func testURLOpener() {
        let manager = AttributionDialogManager(dataSource: MockAttributionDataSource(), delegate: MockAttributionDialogManagerDelegate())
        let url = URL(string: "http://example.com")!
        let attribution = Attribution(title: .randomASCII(withLength: 10), url: url)

        mapView.attributionDialogManager(manager, didTriggerActionFor: attribution)

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
}

final class MapViewTestsWithScene: XCTestCase {

    var notificationCenter: MockNotificationCenter!
    var bundle: MockBundle!
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
        bundle = MockBundle()
        bundle.infoDictionaryStub.defaultReturnValue = ["UIApplicationSceneManifest": []]
        displayLink = MockDisplayLink()
        dependencyProvider = MockMapViewDependencyProvider()
        dependencyProvider.notificationCenter = notificationCenter
        dependencyProvider.bundle = bundle
        dependencyProvider.makeDisplayLinkStub.defaultReturnValue = displayLink
        attributionURLOpener = MockAttributionURLOpener()
        applicationState = .active
        applicationStateProvider = Ref { self.applicationState }
        mapView = MapView(
            frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)),
            mapInitOptions: MapInitOptions(),
            dependencyProvider: dependencyProvider,
            urlOpener: attributionURLOpener,
            applicationStateProvider: applicationStateProvider)
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

        bundle = nil
        notificationCenter = nil
        super.tearDown()
    }

    func testDisplayLinkResumedWhenSceneDidActivate() throws {
        guard #available(iOS 13.0, *) else {
            throw XCTSkip("Test requires iOS 13 or higher.")
        }
        displayLink.$isPausedStub.setStub.reset()

        notificationCenter.post(name: UIScene.didActivateNotification, object: window.parentScene)

        XCTAssertEqual(displayLink.$isPausedStub.setStub.invocations.map(\.parameters), [false])
    }

    func testDisplayLinkPausedWhenSceneWillDeactivate() throws {
        guard #available(iOS 13.0, *) else {
            throw XCTSkip("Test requires iOS 13 or higher.")
        }
        displayLink.$isPausedStub.setStub.reset()

        notificationCenter.post(name: UIScene.willDeactivateNotification, object: window.parentScene)

        XCTAssertEqual(displayLink.$isPausedStub.setStub.invocations.map(\.parameters), [true])
    }

    func testDisplayLinkPausedWhenSceneDidEnterBackground() throws {
        guard #available(iOS 13.0, *) else {
            throw XCTSkip("Test requires iOS 13 or higher.")
        }
        displayLink.$isPausedStub.setStub.reset()

        notificationCenter.post(name: UIScene.didEnterBackgroundNotification, object: window.parentScene)

        XCTAssertEqual(displayLink.$isPausedStub.setStub.invocations.map(\.parameters), [true])
    }

    func testReleaseDrawablesInvokedWhenSceneMovingToBackground() throws {
        guard #available(iOS 13.0, *) else {
            throw XCTSkip("Test requires iOS 13 or higher.")
        }

        notificationCenter.post(name: UIScene.didEnterBackgroundNotification, object: window.parentScene)

        XCTAssertEqual(metalView.releaseDrawablesStub.invocations.count, 1)
    }

    func testMetalViewHasCorrectParameters() throws {
        let mapViewSize = CGSize(width: 100, height: 100)
        mapView = MapView(
            frame: CGRect(origin: .zero, size: mapViewSize),
            mapInitOptions: MapInitOptions(),
            dependencyProvider: dependencyProvider,
            urlOpener: attributionURLOpener,
            applicationStateProvider: applicationStateProvider)

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
            urlOpener: attributionURLOpener,
            applicationStateProvider: applicationStateProvider)

        let metalView = mapView.getMetalView(for: nil)

        XCTAssertEqual(metalView?.bounds.size, minimumMetalViewSize)
    }

    func testOpacityIsPropagatedToMetalView() {
        // given
        let opaque = Bool.random()

        // when
        mapView.isOpaque = opaque

        // then
        XCTAssertEqual(opaque, metalView.isOpaque)
        XCTAssertEqual(opaque, metalView.layer.isOpaque)
    }
}
