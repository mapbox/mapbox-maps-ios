import XCTest
@testable import MapboxMaps

final class OrnamentManagerTests: XCTestCase {
    var options: OrnamentOptions!
    var view: UIView!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    // swiftlint:disable:next weak_delegate
    var infoButtonOrnamentDelegate: MockInfoButtonOrnamentDelegate!
    var logoView: LogoView!
    var scaleBarView: MapboxScaleBarOrnamentView!
    var compassView: MapboxCompassOrnamentView!
    var attributionButton: InfoButtonOrnament!
    var ornamentsManager: OrnamentsManager!
    var onCameraChanged: SignalSubject<CameraChanged>!

    override func setUp() {
        super.setUp()
        options = OrnamentOptions()
        view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        onCameraChanged = SignalSubject()
        cameraAnimationsManager = MockCameraAnimationsManager()
        infoButtonOrnamentDelegate = MockInfoButtonOrnamentDelegate()
        logoView = LogoView(logoSize: .regular())
        scaleBarView = MapboxScaleBarOrnamentView()
        compassView = MapboxCompassOrnamentView()
        attributionButton = InfoButtonOrnament()

        ornamentsManager = OrnamentsManager(
            options: options,
            view: view,
            onCameraChanged: onCameraChanged.signal,
            cameraAnimationsManager: cameraAnimationsManager,
            infoButtonOrnamentDelegate: infoButtonOrnamentDelegate,
            logoView: logoView,
            scaleBarView: scaleBarView,
            compassView: compassView,
            attributionButton: attributionButton)
    }

    override func tearDown() {
        ornamentsManager = nil
        attributionButton = nil
        compassView = nil
        scaleBarView = nil
        logoView = nil
        infoButtonOrnamentDelegate = nil
        cameraAnimationsManager = nil
        onCameraChanged = nil
        view = nil
        options = nil
        super.tearDown()
    }

    func testInitializer() {
        XCTAssertEqual(view.subviews.count, 4)
        XCTAssertEqual(ornamentsManager.options.attributionButton.margins, options.attributionButton.margins)
    }

    func testHidingOrnament() throws {
        let compass = try XCTUnwrap(view.subviews.compactMap { $0 as? MapboxCompassOrnamentView }.first)
        let initialCompassIsHidden = compass.isHidden

        XCTAssertEqual(options.compass.visibility, .adaptive)
        options.compass.visibility = .hidden

        ornamentsManager.options = options

        XCTAssertEqual(options.compass.visibility, .hidden)

        let updatedCompass = try XCTUnwrap(view.subviews.compactMap { $0 as? MapboxCompassOrnamentView }.first)

        XCTAssertNotEqual(initialCompassIsHidden, updatedCompass.isHidden)
    }

    func testScaleBarOnRight() throws {
        let scaleBar = try XCTUnwrap(view.subviews.compactMap { $0 as? MapboxScaleBarOrnamentView }.first)

        XCTAssertFalse(scaleBar.isOnRight, "The default scale bar should be on the left initially.")

        ornamentsManager.options.scaleBar.position = .topRight
        XCTAssertTrue(scaleBar.isOnRight, "The scale bar should be on the right after the position has been updated to topRight.")

        ornamentsManager.options.scaleBar.position = .bottomLeft
        XCTAssertFalse(scaleBar.isOnRight, "The default scale bar should be on the left after updating position to bottomLeft.")

        ornamentsManager.options.scaleBar.position = .bottomRight
        XCTAssertTrue(scaleBar.isOnRight, "The scale bar should be on the right after the position has been updated to bottomRight.")
    }

    func testCompassTappedResetsToNorth() throws {
        let compass = try XCTUnwrap(view.subviews.compactMap { $0 as? MapboxCompassOrnamentView }.first)

        // `sendActions(for:)` doesn't work if you're not running in a host app,
        // so we use this workaround
        for target in compass.allTargets {
            for action in compass.actions(forTarget: target, forControlEvent: .touchUpInside) ?? [] {
                (target as NSObject).perform(Selector(action))
            }
        }

        XCTAssertEqual(cameraAnimationsManager.cancelAnimationsStub.invocations.count, 1)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 1)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.first?.parameters.to, CameraOptions(bearing: 0))
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.first?.parameters.duration, 0.3)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.first?.parameters.curve, .easeOut)
        XCTAssertNil(cameraAnimationsManager.easeToStub.invocations.first?.parameters.completion)
    }

    func testUpdateMapBearing() throws {
        let compass = try XCTUnwrap(view.subviews.compactMap { $0 as? MapboxCompassOrnamentView }.first)

        XCTAssertTrue(compass.containerView.isHidden, "The compass should be hidden initially")

        var cameraState = CameraState.zero
        cameraState.bearing += .random(in: (.leastNonzeroMagnitude)..<360)
        onCameraChanged.send(CameraChanged(cameraState: cameraState, timestamp: Date()))

        XCTAssertFalse(compass.containerView.isHidden, "The compass should not be hidden when the bearing is non-zero.")
        XCTAssertEqual(cameraState.bearing, compass.currentBearing)

        cameraState.bearing = 0
        onCameraChanged.send(CameraChanged(cameraState: cameraState, timestamp: Date()))

        XCTAssertTrue(compass.containerView.isHidden)
        XCTAssertEqual(cameraState.bearing, compass.currentBearing)
    }

    func testCompassVisibility() throws {
        let compass = try XCTUnwrap(view.subviews.compactMap { $0 as? MapboxCompassOrnamentView }.first)
        options.compass.visibility = .visible
        ornamentsManager.options = options
        XCTAssertEqual(options.compass.visibility, compass.visibility)
    }

    func testLogoView() {
        XCTAssertIdentical(ornamentsManager.logoView, logoView)
    }

    func testScaleBarView() {
        XCTAssertIdentical(ornamentsManager.scaleBarView, scaleBarView)
    }

    func testCompassView() {
        XCTAssertIdentical(ornamentsManager.compassView, compassView)
    }

    func testAttributionButton() {
        XCTAssertIdentical(ornamentsManager.attributionButton, attributionButton)
    }
}
