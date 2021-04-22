import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsOrnaments
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
class OrnamentManagerTests: XCTestCase {

    var ornamentSupportableView: OrnamentSupportableViewMock!

    override func setUp() {
        ornamentSupportableView = OrnamentSupportableViewMock(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    }

    override func tearDown() {
        ornamentSupportableView = nil
    }

    func testInitializer() {
       let options = OrnamentOptions()
        let ornamentsManager = OrnamentsManager(view: ornamentSupportableView, options: options)
        XCTAssertEqual(ornamentSupportableView.subviews.count, 4)
        XCTAssertEqual(ornamentsManager.options.attributionButtonMargins, options.attributionButtonMargins)

    }

    func testHidingOrnament() {
        var options = OrnamentOptions()
        let ornamentsManager = OrnamentsManager(view: ornamentSupportableView, options: options)

        let initialSubviews = ornamentSupportableView.subviews.filter { $0.isKind(of: MapboxCompassOrnamentView.self) }
        guard let isInitialCompassHidden = initialSubviews.first?.isHidden else {
            XCTFail("Failed to access the compass' isHidden property.")
            return
        }

        XCTAssertEqual(options.compassVisibility, .adaptive)
        options.compassVisibility = .hidden

        ornamentsManager.options = options

        XCTAssertEqual(options.compassVisibility, .hidden)

        let updatedSubviews = ornamentSupportableView.subviews.filter { $0.isKind(of: MapboxCompassOrnamentView.self) }
        guard let isUpdatedCompassHidden = updatedSubviews.first?.isHidden else {
            XCTFail("Failed to access the updated compass' isHidden property.")
            return
        }

        XCTAssertNotEqual(isInitialCompassHidden, isUpdatedCompassHidden)
    }

    func testUpdatingPosition() {

    }
}
