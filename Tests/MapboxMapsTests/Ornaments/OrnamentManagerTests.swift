import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsOrnaments
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
class OrnamentManagerTests: XCTestCase, AttributionDataSource {

    var ornamentSupportableView: OrnamentSupportableViewMock!
    var options: OrnamentOptions!
    var ornamentsManager: OrnamentsManager!

    override func setUp() {
        ornamentSupportableView = OrnamentSupportableViewMock(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        options = OrnamentOptions()
        ornamentsManager = OrnamentsManager(view: ornamentSupportableView, options: options, attributionDataSource: self)

    }

    override func tearDown() {
        ornamentSupportableView = nil
    }

    func testInitializer() {
        XCTAssertEqual(ornamentSupportableView.subviews.count, 4)
        XCTAssertEqual(ornamentsManager.options.attributionButton.margins, options.attributionButton.margins)

    }

    func testScaleBarOnRight() throws {
        let initialSubviews = ornamentSupportableView.subviews.filter { $0 is MapboxScaleBarOrnamentView }

        let scaleBar = try XCTUnwrap(initialSubviews.first as? MapboxScaleBarOrnamentView, "The ornament supportable map view should include a scale bar")
        XCTAssertFalse(scaleBar.isOnRight, "The default scale bar should be on the left initially.")

        ornamentsManager.options.scaleBar.position = .topRight
        XCTAssertTrue(scaleBar.isOnRight, "The scale bar should be on the right after the position has been updated to topRight.")

        ornamentsManager.options.scaleBar.position = .bottomLeft
        XCTAssertFalse(scaleBar.isOnRight, "The default scale bar should be on the left after updating position to bottomLeft.")

        ornamentsManager.options.scaleBar.position = .bottomRight
        XCTAssertTrue(scaleBar.isOnRight, "The scale bar should be on the right after the position has been updated to bottomRight.")
    }

    func attributions() -> [Attribution] {
        return [ Attribution(title: "This is a test", url: URL(string: "https://example.com/this-is-a-test")!)]
    }

    func testCompassVisibility() throws {
        let initialSubviews = ornamentSupportableView.subviews.filter { $0 is MapboxCompassOrnamentView }
        let compass = try XCTUnwrap(initialSubviews.first as? MapboxCompassOrnamentView, "The ornament supportable map view should include a compass")

        // Check initial values
        XCTAssertEqual(OrnamentVisibility.adaptive, compass.visibility, "Compass should be initialized with adaptive visibility")
        XCTAssertEqual(compass.visibility, ornamentsManager.options.compass.visibility, "OrnamentsManager and compass visibility are out of sync")
        XCTAssertEqual(0, compass.currentBearing, "Compass initial bearing should be 0")
        XCTAssertEqual(true, compass.isHidden, "Compass should be hidden (adaptive, bearing == 0)")

        // Set bearing to non-north
        compass.currentBearing = 5
        XCTAssertEqual(false, compass.isHidden, "Compass should be visible: (adaptive, bearing != 0)")

        // Test hidden
        ornamentsManager.options.compass.visibility = .hidden
        XCTAssertEqual(compass.visibility, ornamentsManager.options.compass.visibility, "OrnamentsManager and compass visibility are out of sync")
        XCTAssertEqual(OrnamentVisibility.hidden, compass.visibility, "Compass visibility did not get set to hidden")
        XCTAssertEqual(true, compass.isHidden, "Compass should be hidden")

        // Test visible
        ornamentsManager.options.compass.visibility = .visible
        XCTAssertEqual(compass.visibility, ornamentsManager.options.compass.visibility, "OrnamentsManager and compass visibility are out of sync")
        XCTAssertEqual(OrnamentVisibility.visible, compass.visibility, "Compass visibility did not get set to hidden")
        XCTAssertEqual(false, compass.isHidden, "Compass should be visible: (visible, bearing != 0)")
        // set bearing to north, compass should still be visible
        compass.currentBearing = 0
        XCTAssertEqual(false, compass.containerView.isHidden, "Compass should be visible (visible, bearing == 0)")

        // Test adaptive
        ornamentsManager.options.compass.visibility = .adaptive
        XCTAssertEqual(compass.visibility, ornamentsManager.options.compass.visibility, "OrnamentsManager and compass visibility are out of sync")
        XCTAssertEqual(OrnamentVisibility.adaptive, compass.visibility, "Compass visibility did not get set to adaptive")
        XCTAssertEqual(true, compass.isHidden, "Compass should be hidden: (adaptive, bearing == 0)")
        // set bearing to not north, compass should become visible
        compass.currentBearing = 5
        XCTAssertEqual(false, compass.isHidden, "Compass should be visible (adaptive, bearing != 0)")
    }

    func testCompassImage() throws {
        // Create a dummy image to use for custom compass image
        let image: UIImage = UIGraphicsImageRenderer(size: CGSize(width: 50, height: 50)).image { rendererContext in
            UIColor.red.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
        }

        let initialSubviews = ornamentSupportableView.subviews.filter { $0 is MapboxCompassOrnamentView }
        let compass = try XCTUnwrap(initialSubviews.first as? MapboxCompassOrnamentView, "The ornament supportable map view should include a compass")

        // Check initial values
        XCTAssertEqual(CompassImage.default, compass.image, "Compass should be initialized with default image")
        XCTAssertEqual(compass.image, ornamentsManager.options.compass.image, "OrnamentsManager and compass image are out of sync")

        // Test set image to custom
        let custom = CompassImage.custom(image)
        ornamentsManager.options.compass.image = custom
        XCTAssertEqual(custom, compass.image, "Compass image did not get set to custom")
        XCTAssertEqual(compass.image, ornamentsManager.options.compass.image, "OrnamentsManager and compass image are out of sync")
        XCTAssertEqual(image, compass.containerView.image, "Compass image view image did not get set to custom image")

        // Test set image to default
        ornamentsManager.options.compass.image = .default
        XCTAssertEqual(CompassImage.default, compass.image, "Compass image did not get set to default")
        XCTAssertEqual(compass.image, ornamentsManager.options.compass.image, "OrnamentsManager and compass image are out of sync")
        XCTAssertNotEqual(image, compass.containerView.image, "Compass image view image is still set to custom image")
    }
}
