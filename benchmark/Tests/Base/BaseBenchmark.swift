import XCTest
import MapboxMobileEvents
@testable import MapboxMaps

class BaseBenchmark: XCTestCase {

    @available(iOS 13.0, *)
    override class var defaultMetrics: [XCTMetric] {
        return [XCTClockMetric(), XCTMemoryMetric(), XCTCPUMetric()]
    }

    enum Error: Swift.Error {
        case rootViewControllerNotFound
    }

    var styleURI: StyleURI = .streets

    internal var mapView: MapView!
    private var viewController: UIViewController!
    private var measurementExpectation: XCTestExpectation?
    private var adHocWaitExpectation: XCTestExpectation?

    override class func setUp() {
        super.setUp()
        MMEEventsManager.shared().disableLocationMetrics()
    }

    override func setUpWithError() throws {
        try super.setUpWithError()

        self.viewController = try addTestViewController()
    }

    override func tearDownWithError() throws {
        removeTestViewController()
        try super.tearDownWithError()
    }

    override func stopMeasuring() {
        super.stopMeasuring()

        measurementExpectation?.fulfill()
    }

    @available(iOS 13.0, *)
    override func measure(metrics: [XCTMetric], block: () -> Void) {
        super.measure(metrics: metrics, block: block)

        measurementExpectation?.fulfill()
    }

    @available(iOS 13.0, *)
    override func measure(options: XCTMeasureOptions, block: () -> Void) {
        super.measure(options: options, block: block)

        measurementExpectation?.fulfill()
    }

    @available(iOS 13.0, *)
    override func measure(metrics: [XCTMetric], options: XCTMeasureOptions, block: () -> Void) {
        super.measure(metrics: metrics, options: options, block: block)

        measurementExpectation?.fulfill()
    }

    /// Sets up an expectation that gets fulfilled when a performance measurement is done.
    /// - Parameters:
    ///   - timeout: Amount of seconds to wait until declaring the test failed
    ///   - filePath: A string that represents a file path to the source code file.
    ///   - lineNumber: An integer that represents a line of code in the source code file.
    func waitForMeasurement(timeout: TimeInterval = 10, filePath: String = #file, lineNumber: Int = #line) {
        let expectation = XCTestExpectation(description: "Measurement expectation")

        measurementExpectation = expectation
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)

        guard result == .timedOut else {
            return
        }
        let location = XCTSourceCodeLocation(filePath: filePath, lineNumber: lineNumber)
        let context = XCTSourceCodeContext(location: location)
        let issue = XCTIssue(type: .performanceRegression,
                             compactDescription: "Test took longer than \(timeout) seconds",
                             sourceCodeContext: context)
        record(issue)
    }

    /// Sets up an expectation and waits until it's fulfilled with `BaseBenchmark.notifyTestDidFinish`.
    /// - Parameters:
    ///   - timeout: Amount of seconds to wait until declaring the test failed
    ///   - filePath: A string that represents a file path to the source code file.
    ///   - lineNumber: An integer that represents a line of code in the source code file.
    func waitForTestToFinish(timeout: TimeInterval = 120, filePath: String = #file, lineNumber: Int = #line) {
        let expectation = XCTestExpectation(description: "Measurement expectation")

        adHocWaitExpectation = expectation
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)

        guard result == .timedOut else {
            return
        }
        let location = XCTSourceCodeLocation(filePath: filePath, lineNumber: lineNumber)
        let context = XCTSourceCodeContext(location: location)
        let issue = XCTIssue(type: .performanceRegression,
                             compactDescription: "Test took longer than \(timeout) seconds",
                             sourceCodeContext: context)
        record(issue)
    }

    /// Fulfills an expectation setup earlier with `BaseBenchmark.waitForTestToFinish(timeout:filePath:lineNumber)`
    func notifyTestDidFinish() {
        adHocWaitExpectation?.fulfill()
    }

    /// Sets up a view controller with an instance of a `MapView` and invokes `handler` closure afterwards.
    /// - Parameters:
    ///   - cameraOptions: Camera options to setup the map view with.
    ///   - handler: A handler that is invoked after the map view is setup.
    func onMapReady(cameraOptions: CameraOptions? = nil, handler: (MapView) -> ()) {
        let frame = viewController?.view.frame ?? .zero
        guard let token = Bundle.main.infoDictionary?["MBXAccessToken"] as? String else {
            XCTFail("Access token not found")
            return
        }
        let resourceOptions = ResourceOptions(accessToken: token)
        let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions, cameraOptions: cameraOptions)
        mapView = MapView(frame: frame, mapInitOptions: mapInitOptions)

        viewController.view.addSubview(mapView)
        handler(mapView)
    }

    /// Sets up a map view with a style specified in `styleURI` property.
    /// - Parameters:
    ///   - cameraOptions: Camera options to setup the map view with.
    ///   - filePath: A string that represents a file path to the source code file.
    ///   - lineNumber: An integer that represents a line of code in the source code file.
    ///   - handler: A handler that is invoked after the style is loaded.
    func onStyleLoaded(cameraOptions: CameraOptions? = nil,
                       filePath: String = #file,
                       lineNumber: Int = #line,
                       handler: @escaping (MapView, Style) -> ()) {
        onMapReady(cameraOptions: cameraOptions) { mapView in
            mapView.mapboxMap.loadStyleURI(styleURI) { result in
                switch result {
                case .failure(let error):
                    let location = XCTSourceCodeLocation(filePath: filePath, lineNumber: lineNumber)
                    let context = XCTSourceCodeContext(location: location)
                    let issue = XCTIssue(type: .thrownError,
                                         compactDescription: error.localizedDescription,
                                         sourceCodeContext: context)
                    self.record(issue)
                case .success(let style):
                    handler(mapView, style)
                }
            }
        }
    }

    /// Sets up a map view with a style specified in `styleURI` property and waits until the map is loaded.
    /// - Parameters:
    ///   - cameraOptions: Camera options to setup the map view with.
    ///   - handler: A handler that is invoked after the map is loaded.
    ///   - filePath: A string that represents a file path to the source code file.
    ///   - lineNumber: An integer that represents a line of code in the source code file.
    func onMapLoaded(cameraOptions: CameraOptions? = nil,
                     handler: @escaping (MapView) -> (),
                     filePath: String = #file,
                     lineNumber: Int = #line) {
        onStyleLoaded(cameraOptions: cameraOptions, filePath: filePath, lineNumber: lineNumber) { mapView, style in
            mapView.mapboxMap.onNext(.mapLoaded) { event in
                handler(mapView)
            }
        }
    }

    // MARK: - Private

    private func addTestViewController(timeout: TimeInterval = 1.0) throws -> UIViewController {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            throw Error.rootViewControllerNotFount
        }

        let childController = NotifyingViewController()

        childController.willMove(toParent: rootViewController)
        childController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childController.view.translatesAutoresizingMaskIntoConstraints = true
        childController.view.frame = rootViewController.view.bounds
        rootViewController.view.addSubview(childController.view)
        rootViewController.addChild(childController)

        childController.didMove(toParent: rootViewController)

        let expectation = self.expectation(description: "View controller must be visible")
        childController.whenVisible {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)

        return childController
    }

    private func removeTestViewController() {
        guard let childController = viewController else {
            return
        }

        childController.willMove(toParent: nil)
        childController.view.removeFromSuperview()
        childController.removeFromParent()
        childController.didMove(toParent: nil)

        viewController = nil
    }
}
