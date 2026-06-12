import XCTest
@_spi(Experimental) @testable import MapboxMaps

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

    func testDebugNoCollisionBox() {
        let view = UIView()
        let me = ViewAnnotationsContainer()
        me.addSubview(view)
        me.subviewDebugFrames = true

        XCTAssertEqual(view.subviews.contains(where: { $0.tag == 0xdeba9 }), true)
        me.subviewDebugFrames = false

        XCTAssertEqual(view.subviews.contains(where: { $0.tag == 0xdeba9 }), false)
    }

    func testDebugCollisionBox() {
        // Multiple collision boxes: two marked subviews → two debug views
        let container1 = ViewAnnotationsContainer()
        let view1 = UIView()
        view1.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let box1a = UIView()
        box1a.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        box1a.mbxCollisionBox = true
        let box1b = UIView()
        box1b.frame = CGRect(x: 60, y: 60, width: 40, height: 40)
        box1b.mbxCollisionBox = true
        view1.addSubview(box1a)
        view1.addSubview(box1b)
        container1.addSubview(view1)
        container1.subviewDebugFrames = true

        XCTAssertEqual(view1.subviews.filter { $0.tag == 0xdeba9 }.count, 2)

        container1.subviewDebugFrames = false
        XCTAssertFalse(view1.subviews.contains(where: { $0.tag == 0xdeba9 }))

        // Single collision box: one marked subview → one debug view matching its frame
        let container2 = ViewAnnotationsContainer()
        let view2 = UIView()
        view2.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let box2 = UIView()
        box2.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
        box2.mbxCollisionBox = true
        view2.addSubview(box2)
        container2.addSubview(view2)
        container2.subviewDebugFrames = true

        let debugViews2 = view2.subviews.filter { $0.tag == 0xdeba9 }
        XCTAssertEqual(debugViews2.count, 1)
        XCTAssertEqual(debugViews2.first?.frame, box2.frame)

        container2.subviewDebugFrames = false
        XCTAssertFalse(view2.subviews.contains(where: { $0.tag == 0xdeba9 }))

        // View itself is the collision box → one debug view covering its bounds
        let container3 = ViewAnnotationsContainer()
        let view3 = UIView()
        view3.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        view3.mbxCollisionBox = true
        container3.addSubview(view3)
        container3.subviewDebugFrames = true

        let debugViews3 = view3.subviews.filter { $0.tag == 0xdeba9 }
        XCTAssertEqual(debugViews3.count, 1)
        XCTAssertEqual(debugViews3.first?.frame, view3.bounds)

        container3.subviewDebugFrames = false
        XCTAssertFalse(view3.subviews.contains(where: { $0.tag == 0xdeba9 }))
    }
}
