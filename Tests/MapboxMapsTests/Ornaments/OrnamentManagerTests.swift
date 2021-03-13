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
        let config = OrnamentConfig(ornamentPositions: [.mapboxLogoView: .bottomLeft],
                                    ornamentMargins: [.mapboxLogoView: CGPoint.zero], ornamentVisibility: [:],
                                    telemetryOptOutShownInApp: true)
        let ornamentsManager = OrnamentsManager(for: ornamentSupportableView, withConfig: config)
        XCTAssert(ornamentSupportableView.subviews.count == ornamentsManager.ornaments.count,
                  "Wrong number of corresponding ornament subviews")
        XCTAssert(ornamentsManager.ornaments.count == 1, "Should have one ornament after initialization")

        if let existingOrnament = ornamentsManager.ornaments.first {
            XCTAssert(existingOrnament.type == .mapboxLogoView,
                      "Initial ornament should be the Mapbox logo.")
        } else {
            XCTFail("Ornaments manager does not have any ornaments")
        }

        XCTAssertTrue(config.telemetryOptOutShownInApp)
    }

    func testAddingOrnament() {
        let customOrnament = UIView()
        let config = OrnamentConfig(ornamentPositions: [.mapboxLogoView: .bottomLeft],
                                    ornamentMargins: [.mapboxLogoView: CGPoint.zero], ornamentVisibility: [:],
                                    telemetryOptOutShownInApp: true)
        let ornamentsManager = OrnamentsManager(for: ornamentSupportableView, withConfig: config)
        ornamentsManager.addOrnament(customOrnament, at: .topLeft)

        XCTAssert(ornamentSupportableView.subviews.count == ornamentsManager.ornaments.count,
                  "Wrong number of corresponding ornament subviews")
        XCTAssertTrue(ornamentsManager.ornaments.count == 2, "Ornament manager should add one ornament")
    }

    func testRemovingOrnament() {
        let customOrnament = UIView()
        let config = OrnamentConfig(ornamentPositions: [.mapboxLogoView: .bottomLeft],
                                    ornamentMargins: [.mapboxLogoView: CGPoint.zero], ornamentVisibility: [:],
                                    telemetryOptOutShownInApp: true)
        let ornamentsManager = OrnamentsManager(for: ornamentSupportableView, withConfig: config)
        ornamentsManager.addOrnament(customOrnament, at: .topLeft)
        ornamentsManager.removeOrnament(customOrnament)

        XCTAssert(ornamentSupportableView.subviews.count == ornamentsManager.ornaments.count,
                  "Wrong number of corresponding ornament subviews")
        XCTAssertTrue(ornamentSupportableView.subviews.count == 1, "Ornament manager should remove one ornament")
    }

    func testHeavyStateMutation() {
        // Given
        let config = OrnamentConfig(ornaments: [], telemetryOptOutShownInApp: true)
        let ornamentsManager = OrnamentsManager(for: ornamentSupportableView, withConfig: config)

        // When we add three ornaments
        ornamentsManager.addOrnament(.mapboxLogoView, at: .bottomLeft, visibility: .visible)
        ornamentsManager.addOrnament(.mapboxScaleBar, at: .bottomRight, visibility: .visible)
        ornamentsManager.addOrnament(.compass, at: .centerLeft, visibility: .visible)

        // Then
        XCTAssert(ornamentSupportableView.subviews.count == ornamentsManager.ornaments.count,
                  "Wrong number of corresponding ornament subviews")
        XCTAssertTrue(ornamentSupportableView.subviews.count == 3, "Ornament manager should add three ornaments")

        // When we remove an ornament
        ornamentsManager.removeOrnament(at: .bottomLeft)

        // Then
        XCTAssert(ornamentSupportableView.subviews.count == ornamentsManager.ornaments.count,
                  "Wrong number of corresponding ornament subviews")
        XCTAssertTrue(ornamentSupportableView.subviews.count == 2, "Ornament manager should add three ornaments")

        // When we remove one more ornament
        ornamentsManager.removeOrnament(with: .mapboxScaleBar)
        // And try to remove ornament which was removed already
        ornamentsManager.removeOrnament(at: .bottomLeft)

        // Then
        XCTAssert(ornamentSupportableView.subviews.count == ornamentsManager.ornaments.count,
                  "Wrong number of corresponding ornament subviews")
        XCTAssertTrue(ornamentSupportableView.subviews.count == 1, "Ornament manager should add three ornaments")

        // When we set a config
        let newConfig = OrnamentConfig(ornamentPositions: [.mapboxLogoView: .bottomLeft, .mapboxScaleBar: .bottomRight],
                                       ornamentMargins: [
                                           .mapboxLogoView: CGPoint.zero,
                                           .mapboxScaleBar: .defaultMargins
                                       ], ornamentVisibility: [:])
        ornamentsManager.ornamentConfig = newConfig

        // Then
        XCTAssert(ornamentSupportableView.subviews.count == ornamentsManager.ornaments.count,
                  "Wrong number of corresponding ornament subviews")
        XCTAssertTrue(ornamentSupportableView.subviews.count == 2, "Ornament manager should add three ornaments")
    }

    func testLogoViewSizeWidth() {
        let config = OrnamentConfig(ornamentPositions: [.mapboxLogoView: .bottomLeft],
                                    ornamentMargins: [.mapboxLogoView: CGPoint.zero], ornamentVisibility: [:],
                                    telemetryOptOutShownInApp: true)
        let ornamentsManager = OrnamentsManager(for: ornamentSupportableView, withConfig: config)

        if let logoView = ornamentsManager.ornaments.filter({ $0.type == .mapboxLogoView }).first {
            ornamentSupportableView.setNeedsLayout()
            ornamentSupportableView.layoutIfNeeded()

            let expectedWidth = ornamentSupportableView.frame.width * 0.25

            XCTAssertTrue(logoView.view?.frame.width == expectedWidth,
                          "Logo view width should be 25% of the map view's width")
        } else {
            XCTFail("Logo ornament does not exist")
        }
    }
}
