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

    func testHidingOrnament() {
        let initialSubviews = ornamentSupportableView.subviews.filter { $0.isKind(of: MapboxCompassOrnamentView.self) }
        guard let isInitialCompassHidden = initialSubviews.first?.isHidden else {
            XCTFail("Failed to access the compass' isHidden property.")
            return
        }

        XCTAssertEqual(options.compass.visibility, .adaptive)
        options.compass.visibility = .hidden

        ornamentsManager.options = options

        XCTAssertEqual(options.compass.visibility, .hidden)

        let updatedSubviews = ornamentSupportableView.subviews.filter { $0.isKind(of: MapboxCompassOrnamentView.self) }
        guard let isUpdatedCompassHidden = updatedSubviews.first?.isHidden else {
            XCTFail("Failed to access the updated compass' isHidden property.")
            return
        }

        XCTAssertNotEqual(isInitialCompassHidden, isUpdatedCompassHidden)
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
}
