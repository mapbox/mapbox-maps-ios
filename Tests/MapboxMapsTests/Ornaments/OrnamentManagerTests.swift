import XCTest
@testable @_spi(Experimental) import MapboxMaps
@_spi(Experimental) import MapboxCoreMaps

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
    var indoorSelectorView: IndoorSelectorView!
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
        indoorSelectorView = IndoorSelectorView(model: MockIndoorSelectorModel())
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
            attributionButton: attributionButton,
            indoorSelectorView: indoorSelectorView)
    }

    override func tearDown() {
        ornamentsManager = nil
        attributionButton = nil
        compassView = nil
        scaleBarView = nil
        logoView = nil
        indoorSelectorView = nil
        infoButtonOrnamentDelegate = nil
        cameraAnimationsManager = nil
        onCameraChanged = nil
        view = nil
        options = nil
        super.tearDown()
    }

    func testInitializer() {
        XCTAssertEqual(view.subviews.count, 5)
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
        cameraState.bearing += 350
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

    func testIndoorSelectorView() {
        XCTAssertIdentical(ornamentsManager.indoorSelectorView, indoorSelectorView)
    }

    func testTintColor() {
        options.attributionButton.tintColor = .red
        ornamentsManager.options = options
        XCTAssertEqual(ornamentsManager.attributionButton.tintColor, .red)
        XCTAssertEqual(ornamentsManager.options.attributionButton.tintColor, .red)
    }

    func testTintColorOverride() {
        ornamentsManager.attributionButton.tintColor = .gray

        options.attributionButton.tintColor = .red
        ornamentsManager.options = options
        XCTAssertEqual(ornamentsManager.attributionButton.tintColor, .red)
        XCTAssertEqual(ornamentsManager.options.attributionButton.tintColor, .red)
    }

    func testTintColorSync() {
        ornamentsManager.attributionButton.tintColor = .gray
        XCTAssertEqual(ornamentsManager.attributionButton.tintColor, .gray)
        XCTAssertEqual(ornamentsManager.options.attributionButton.tintColor, .gray)

        options.attributionButton.tintColor = .red
        ornamentsManager.options = options
        XCTAssertEqual(ornamentsManager.attributionButton.tintColor, .red)
        XCTAssertEqual(ornamentsManager.options.attributionButton.tintColor, .red)
    }

    func testTintColorClear() {
        let originalTintColor = ornamentsManager.attributionButton.tintColor

        options.attributionButton.tintColor = .red
        ornamentsManager.options = options
        XCTAssertEqual(ornamentsManager.attributionButton.tintColor, .red)
        XCTAssertEqual(ornamentsManager.options.attributionButton.tintColor, .red)

        options.attributionButton.tintColor = nil
        ornamentsManager.options = options
        XCTAssertEqual(ornamentsManager.attributionButton.tintColor, originalTintColor)
        XCTAssertEqual(ornamentsManager.options.attributionButton.tintColor, originalTintColor)
    }

    // MARK: - ScaleBar Units Tests

    func testUseMetricUnitsToUnitsInteraction() {
        var scaleBarOptions = ScaleBarViewOptions()

        // Test setting useMetricUnits to true sets units to .metric
        scaleBarOptions.useMetricUnits = true
        XCTAssertEqual(scaleBarOptions.units, .metric, "Setting useMetricUnits to true should set units to .metric")
        XCTAssertTrue(scaleBarOptions.useMetricUnits, "useMetricUnits should remain true")

        // Test setting useMetricUnits to false sets units to .imperial
        scaleBarOptions.useMetricUnits = false
        XCTAssertEqual(scaleBarOptions.units, .imperial, "Setting useMetricUnits to false should set units to .imperial")
        XCTAssertFalse(scaleBarOptions.useMetricUnits, "useMetricUnits should remain false")
    }

    func testUnitsToUseMetricUnitsInteraction() {
        var scaleBarOptions = ScaleBarViewOptions()

        // Test setting units to .metric sets useMetricUnits to true
        scaleBarOptions.units = .metric
        XCTAssertTrue(scaleBarOptions.useMetricUnits, "Setting units to .metric should set useMetricUnits to true")
        XCTAssertEqual(scaleBarOptions.units, .metric, "units should remain .metric")

        // Test setting units to .imperial sets useMetricUnits to false
        scaleBarOptions.units = .imperial
        XCTAssertFalse(scaleBarOptions.useMetricUnits, "Setting units to .imperial should set useMetricUnits to false")
        XCTAssertEqual(scaleBarOptions.units, .imperial, "units should remain .imperial")

        // Test setting units to .nautical sets useMetricUnits to false
        scaleBarOptions.units = .nautical
        XCTAssertFalse(scaleBarOptions.useMetricUnits, "Setting units to .nautical should set useMetricUnits to false")
        XCTAssertEqual(scaleBarOptions.units, .nautical, "units should remain .nautical")
    }

    func testScaleBarOptionsInitialization() {
        // Test default initialization - depends on locale
        let defaultOptions = ScaleBarViewOptions()
        let expectedDefaultUnits: ScaleBarViewOptions.Units = Locale.current.usesMetricSystem ? .metric : .imperial
        XCTAssertEqual(defaultOptions.units, expectedDefaultUnits, "Default units should match locale")
        XCTAssertEqual(defaultOptions.useMetricUnits, Locale.current.usesMetricSystem, "Default useMetricUnits should match locale")

        // Test initialization with useMetricUnits false
        let imperialOptions = ScaleBarViewOptions(useMetricUnits: false)
        XCTAssertEqual(imperialOptions.units, .imperial, "useMetricUnits false should result in .imperial units")
        XCTAssertFalse(imperialOptions.useMetricUnits, "useMetricUnits should be false")

        // Test initialization with explicit units
        let nauticalOptions = ScaleBarViewOptions(units: .nautical)
        XCTAssertEqual(nauticalOptions.units, .nautical, "Explicit units should be preserved")
        XCTAssertFalse(nauticalOptions.useMetricUnits, "useMetricUnits should be false for nautical units")

        // Test initialization with both parameters - units should take precedence
        let explicitOptions = ScaleBarViewOptions(useMetricUnits: true, units: .nautical)
        XCTAssertEqual(explicitOptions.units, .nautical, "Explicit units parameter should take precedence")
        XCTAssertFalse(explicitOptions.useMetricUnits, "useMetricUnits should be set based on units value")
    }

    func testScaleBarUnitsBackwardCompatibility() {
        var scaleBarOptions = ScaleBarViewOptions()

        // Simulate legacy code setting useMetricUnits
        scaleBarOptions.useMetricUnits = true
        XCTAssertEqual(scaleBarOptions.units, .metric, "Legacy useMetricUnits=true should work with new units property")

        scaleBarOptions.useMetricUnits = false
        XCTAssertEqual(scaleBarOptions.units, .imperial, "Legacy useMetricUnits=false should work with new units property")

        // Simulate new code setting units while legacy property exists
        scaleBarOptions.units = .nautical
        XCTAssertFalse(scaleBarOptions.useMetricUnits, "New units=.nautical should update legacy useMetricUnits property")

        scaleBarOptions.units = .metric
        XCTAssertTrue(scaleBarOptions.useMetricUnits, "New units=.metric should update legacy useMetricUnits property")

        scaleBarOptions.units = .imperial
        XCTAssertFalse(scaleBarOptions.useMetricUnits, "New units=.imperial should update legacy useMetricUnits property")
    }

    func testScaleBarUnitsNoInfiniteLoop() {
        var scaleBarOptions = ScaleBarViewOptions()

        // Test that setting the same value doesn't trigger changes
        scaleBarOptions.units = .metric
        let initialUnits = scaleBarOptions.units
        let initialUseMetric = scaleBarOptions.useMetricUnits

        scaleBarOptions.units = .metric  // Same value
        XCTAssertEqual(scaleBarOptions.units, initialUnits, "Setting same units value should not change anything")
        XCTAssertEqual(scaleBarOptions.useMetricUnits, initialUseMetric, "Setting same units value should not change useMetricUnits")

        // Test same for useMetricUnits
        scaleBarOptions.useMetricUnits = true  // Same value
        XCTAssertEqual(scaleBarOptions.units, initialUnits, "Setting same useMetricUnits value should not change anything")
        XCTAssertEqual(scaleBarOptions.useMetricUnits, initialUseMetric, "Setting same useMetricUnits value should not change itself")
    }

    // MARK: - IndoorSelector Tests

    func testIndoorSelectorInitiallyHidden() throws {
        let indoorSelector = try XCTUnwrap(view.subviews.compactMap { $0 as? IndoorSelectorView }.first)
        XCTAssertTrue(indoorSelector.isHidden, "Indoor selector should be hidden initially when model has no floors")
    }

    func testIndoorSelectorIntrinsicContentSizeUpdates() throws {
        let mockModel = MockIndoorSelectorModel()
        let testIndoorSelector = IndoorSelectorView(model: mockModel)

        mockModel.floors = []
        let emptySize = testIndoorSelector.intrinsicContentSize
        XCTAssertEqual(emptySize.height, 0, "Height should be 0 with no floors")

        mockModel.floors = [
            IndoorFloor(id: "0", name: "0"),
            IndoorFloor(id: "1", name: "1"),
            IndoorFloor(id: "2", name: "2")
        ]
        mockModel.onFloorsUpdated?()

        let updatedSize = testIndoorSelector.intrinsicContentSize
        XCTAssertEqual(updatedSize.height, 132, "Height should be 132 (3 floors * 44) with 3 floors")
    }

    func testIndoorSelectorMaxVisibleFloors() throws {
        let mockModel = MockIndoorSelectorModel()
        let testIndoorSelector = IndoorSelectorView(model: mockModel)

        mockModel.floors = [
            IndoorFloor(id: "0", name: "0"),
            IndoorFloor(id: "1", name: "1"),
            IndoorFloor(id: "2", name: "2"),
            IndoorFloor(id: "3", name: "3"),
            IndoorFloor(id: "4", name: "4"),
            IndoorFloor(id: "5", name: "5")
        ]
        mockModel.onFloorsUpdated?()

        let size = testIndoorSelector.intrinsicContentSize
        XCTAssertEqual(size.height, 176, "Height should be capped at 176 (4 floors * 44) even with 6 floors")
    }
}
