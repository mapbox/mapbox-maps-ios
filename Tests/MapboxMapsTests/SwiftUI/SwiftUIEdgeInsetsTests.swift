import XCTest
import SwiftUI
@testable import MapboxMaps

@available(iOS 13.0, *)
class SwiftUIEdgeInsetsTests: XCTestCase {

    func testInitUIEdgeInsets() {
        let uiEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        var insets = SwiftUI.EdgeInsets(uiInsets: uiEdgeInsets, layoutDirection: .leftToRight)
        XCTAssertEqual(insets.top, 10)
        XCTAssertEqual(insets.leading, 20)
        XCTAssertEqual(insets.bottom, 30)
        XCTAssertEqual(insets.trailing, 40)

        insets = SwiftUI.EdgeInsets(uiInsets: uiEdgeInsets, layoutDirection: .rightToLeft)
        XCTAssertEqual(insets.top, 10)
        XCTAssertEqual(insets.leading, 40)
        XCTAssertEqual(insets.bottom, 30)
        XCTAssertEqual(insets.trailing, 20)
    }

    func testUpdateEdges() {
        var insets = SwiftUI.EdgeInsets(top: 10, leading: 20, bottom: 30, trailing: 40)
        insets.updateEdges(.top, 1)
        insets.updateEdges(.leading, 2)
        insets.updateEdges(.bottom, 3)
        insets.updateEdges(.trailing, 4)
        XCTAssertEqual(insets.top, 1)
        XCTAssertEqual(insets.leading, 2)
        XCTAssertEqual(insets.bottom, 3)
        XCTAssertEqual(insets.trailing, 4)
    }

    func testInitEdgeInsets() {
        let swiftUIEdgeInsets = SwiftUI.EdgeInsets(top: 10, leading: 20, bottom: 30, trailing: 40)
        var insets = UIEdgeInsets(insets: swiftUIEdgeInsets, layoutDirection: .leftToRight)
        XCTAssertEqual(insets.top, 10)
        XCTAssertEqual(insets.left, 20)
        XCTAssertEqual(insets.bottom, 30)
        XCTAssertEqual(insets.right, 40)

        insets = UIEdgeInsets(insets: swiftUIEdgeInsets, layoutDirection: .rightToLeft)
        XCTAssertEqual(insets.top, 10)
        XCTAssertEqual(insets.left, 40)
        XCTAssertEqual(insets.bottom, 30)
        XCTAssertEqual(insets.right, 20)
    }
}
