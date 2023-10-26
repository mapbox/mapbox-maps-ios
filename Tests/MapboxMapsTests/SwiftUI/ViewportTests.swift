@_spi(Experimental) @testable import MapboxMaps
import XCTest
import SwiftUI
import UIKit

@available(iOS 13.0, *)
final class ViewportTests: XCTestCase {
    func testIdle() {
        let viewport = Viewport.idle
        XCTAssertEqual(viewport.isIdle, true)
        XCTAssertEqual(viewport.isStyleDefault, false)
        XCTAssertEqual(viewport.camera, nil)
        XCTAssertEqual(viewport.followPuck, nil)
        XCTAssertEqual(viewport.overview, nil)
    }

    func testStyleDefault() {
        let viewport = Viewport.styleDefault
        XCTAssertEqual(viewport.isIdle, false)
        XCTAssertEqual(viewport.isStyleDefault, true)
        XCTAssertEqual(viewport.camera, nil)
        XCTAssertEqual(viewport.followPuck, nil)
        XCTAssertEqual(viewport.overview, nil)
    }

    func testCamera() {
        let viewport = Viewport.camera(center: .init(latitude: 0, longitude: 1), anchor: .init(x: 2, y: 3), zoom: 4, bearing: 5, pitch: 6)
        let expectedCamera = CameraOptions(
            center: .init(latitude: 0, longitude: 1),
            anchor: .init(x: 2, y: 3),
            zoom: 4,
            bearing: 5,
            pitch: 6)
        XCTAssertEqual(viewport.camera, expectedCamera)
        XCTAssertEqual(viewport.isIdle, false)
        XCTAssertEqual(viewport.isStyleDefault, false)
        XCTAssertEqual(viewport.followPuck, nil)
        XCTAssertEqual(viewport.overview, nil)
    }

    func testOverview() throws {
        let geometry = Point(CLLocationCoordinate2D(latitude: 0, longitude: 1))
        let viewport = Viewport.overview(
            geometry: geometry,
            bearing: 2,
            pitch: 3,
            geometryPadding: SwiftUI.EdgeInsets(top: 4, leading: 5, bottom: 6, trailing: 7),
            maxZoom: 8,
            offset: CGPoint(x: 9, y: 10))

        let padding = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)

        let expectedOptions = OverviewViewportStateOptions(
            geometry: geometry,
            geometryPadding: UIEdgeInsets(top: 4, left: 5, bottom: 6, right: 7),
            bearing: 2,
            pitch: 3,
            padding: padding,
            maxZoom: 8,
            offset: CGPoint(x: 9, y: 10),
            animationDuration: 0)
        let resolved = try XCTUnwrap(viewport.overview).resolve(layoutDirection: .leftToRight, padding: padding)
        XCTAssertEqual(resolved, expectedOptions)
        XCTAssertEqual(viewport.isIdle, false)
        XCTAssertEqual(viewport.isStyleDefault, false)
        XCTAssertEqual(viewport.camera, nil)
        XCTAssertEqual(viewport.followPuck, nil)
    }

    func testFollowPuck() {
        let viewport = Viewport.followPuck(zoom: 0, bearing: .constant(1), pitch: 2)
        let padding = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        let expected = FollowPuckViewportStateOptions(padding: padding, zoom: 0, bearing: .constant(1), pitch: 2)
        XCTAssertEqual(viewport.isIdle, false)
        XCTAssertEqual(viewport.isStyleDefault, false)
        XCTAssertEqual(viewport.camera, nil)
        XCTAssertEqual(viewport.followPuck?.resolve(padding: padding), expected)
        XCTAssertEqual(viewport.overview, nil)
    }

    func testPaddingResolution() {
        let viewport = Viewport.styleDefault
            .inset(by: SwiftUI.EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4))

        let safeArea = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        let ltrPadding = viewport.padding(with: .leftToRight, safeAreaInsets: safeArea)
        XCTAssertEqual(ltrPadding.top, 11)
        XCTAssertEqual(ltrPadding.left, 22)
        XCTAssertEqual(ltrPadding.bottom, 33)
        XCTAssertEqual(ltrPadding.right, 44)

        let rtlPadding = viewport.padding(with: .rightToLeft, safeAreaInsets: safeArea)
        XCTAssertEqual(rtlPadding.top, 11)
        XCTAssertEqual(rtlPadding.left, 24)
        XCTAssertEqual(rtlPadding.bottom, 33)
        XCTAssertEqual(rtlPadding.right, 42)
    }

    func testPaddingResolutionIgnoreSafeArea() {
        let viewport = Viewport.styleDefault
            .inset(by: SwiftUI.EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4), ignoringSafeArea: .all)

        let safeArea = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        let ltrPadding = viewport.padding(with: .leftToRight, safeAreaInsets: safeArea)
        XCTAssertEqual(ltrPadding.top, 1)
        XCTAssertEqual(ltrPadding.left, 2)
        XCTAssertEqual(ltrPadding.bottom, 3)
        XCTAssertEqual(ltrPadding.right, 4)

        let rtlPadding = viewport.padding(with: .rightToLeft, safeAreaInsets: safeArea)
        XCTAssertEqual(rtlPadding.top, 1)
        XCTAssertEqual(rtlPadding.left, 4)
        XCTAssertEqual(rtlPadding.bottom, 3)
        XCTAssertEqual(rtlPadding.right, 2)
    }

    func testPaddingResolutionIndividualEdge() {
        let viewport = Viewport.styleDefault
            .inset(edges: .top, length: 1)
            .inset(edges: .leading, length: 2)
            .inset(edges: .bottom, length: 3)
            .inset(edges: .trailing, length: 4)

        let safeArea = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        let ltrPadding = viewport.padding(with: .leftToRight, safeAreaInsets: safeArea)
        XCTAssertEqual(ltrPadding.top, 11)
        XCTAssertEqual(ltrPadding.left, 22)
        XCTAssertEqual(ltrPadding.bottom, 33)
        XCTAssertEqual(ltrPadding.right, 44)

        let rtlPadding = viewport.padding(with: .rightToLeft, safeAreaInsets: safeArea)
        XCTAssertEqual(rtlPadding.top, 11)
        XCTAssertEqual(rtlPadding.left, 24)
        XCTAssertEqual(rtlPadding.bottom, 33)
        XCTAssertEqual(rtlPadding.right, 42)
    }

    func testPaddingResolutionIndividualEdgeIgnoreSafeArea() {
        let viewport = Viewport.styleDefault
            .inset(edges: .top, length: 1, ignoringSafeArea: true)
            .inset(edges: .leading, length: 2, ignoringSafeArea: true)
            .inset(edges: .bottom, length: 3, ignoringSafeArea: true)
            .inset(edges: .trailing, length: 4, ignoringSafeArea: true)

        let safeArea = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        let ltrPadding = viewport.padding(with: .leftToRight, safeAreaInsets: safeArea)
        XCTAssertEqual(ltrPadding.top, 1)
        XCTAssertEqual(ltrPadding.left, 2)
        XCTAssertEqual(ltrPadding.bottom, 3)
        XCTAssertEqual(ltrPadding.right, 4)

        let rtlPadding = viewport.padding(with: .rightToLeft, safeAreaInsets: safeArea)
        XCTAssertEqual(rtlPadding.top, 1)
        XCTAssertEqual(rtlPadding.left, 4)
        XCTAssertEqual(rtlPadding.bottom, 3)
        XCTAssertEqual(rtlPadding.right, 2)
    }
}
