import XCTest
@testable import MapboxMaps

final class ViewAnnotationsContainerTests: XCTestCase {

    func testHitTest() {
        let wrapperView = UIView()
        wrapperView.frame = CGRect(origin: .zero, size: CGSize(width: 200.0, height: 200.0))

        let subviewInteractionOnlyView = ViewAnnotationsContainer()
        subviewInteractionOnlyView.frame = CGRect(origin: .zero, size: CGSize(width: 200.0, height: 200.0))

        let subview = UIView()
        subview.frame = CGRect(origin: .zero, size: CGSize(width: 50.0, height: 50.0))

        wrapperView.addSubview(subviewInteractionOnlyView)
        subviewInteractionOnlyView.addSubview(subview)

        let viewA = wrapperView.hitTest(CGPoint(x: 25.0, y: 25.0), with: UIEvent())
        XCTAssertEqual(viewA, subview)

        let viewB = wrapperView.hitTest(CGPoint(x: 100.0, y: 100.0), with: UIEvent())
        XCTAssertEqual(viewB, wrapperView)
    }

    func testDebug() {
        let view = UIView()
        let me = ViewAnnotationsContainer()
        me.addSubview(view)
        me.subviewDebugFrames = true

        XCTAssertEqual(view.subviews.contains(where: { $0.tag == 0xdeba9 }), true)
        me.subviewDebugFrames = false

        XCTAssertEqual(view.subviews.contains(where: { $0.tag == 0xdeba9 }), false)
    }
}
