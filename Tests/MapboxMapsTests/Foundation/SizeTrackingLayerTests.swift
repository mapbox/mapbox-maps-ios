@testable import MapboxMaps
import XCTest
import os

final class SizeTrackingLayerTests: XCTestCase {

    var view: SizeTrackingView!

    override func setUp() {
        view = SizeTrackingView(frame: CGRect(x: 10, y: 80, width: 100, height: 100))
        view.backgroundColor = .red
        view.willAnimateStub.reset()
        view.completeResizingStub.reset()

        if let rootVC = UIApplication.shared.keyWindowForTests?.rootViewController {
            rootVC.view.addSubview(view)
        }
    }

    override func tearDown() {
        view?.removeFromSuperview()
        // XCTest keeps test case instances alive until the run ends, so release the map view here.
        view = nil
    }

    // MARK: UIView.animate

    func testUIViewAnimate() throws {
        let animationCompletion = expectation(description: "Animation completion")

        UIView.animate(withDuration: 0.25) {
            self.view.frame.size = CGSize(width: 200, height: 200)
        } completion: { _ in
            animationCompletion.fulfill()
        }

        try assertViewInvocations(animationCompletion)
    }

    func testUIViewAnimateWithDelay() throws {
        let animationCompletion = expectation(description: "Animation completion")

        UIView.animate(withDuration: 0.25, delay: 0.25) {
            self.view.frame.size = CGSize(width: 200, height: 200)
        } completion: { _ in
            animationCompletion.fulfill()
        }

        try assertViewInvocations(animationCompletion)
    }

    func testUIViewAnimateWithoutDuration() throws {
        let animationCompletion = expectation(description: "Animation completion")

        UIView.animate(withDuration: 0) {
            self.view.frame.size = CGSize(width: 200, height: 200)
        } completion: { _ in
            animationCompletion.fulfill()
        }

        try assertViewInvocations(animationCompletion)
    }

    // MARK: UIPropertyAnimator

    func testUIPropertyAnimator() throws {
        let animationCompletion = expectation(description: "Animation completion")

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0) {
            self.view.frame.size = CGSize(width: 200, height: 200)
        } completion: { _ in
            animationCompletion.fulfill()
        }

        try assertViewInvocations(animationCompletion)
    }

    // UIViewPropertyAnimator may reuse its CAAnimation, so a second run must still be tracked.
    func testUIPropertyAnimatorTwice() throws {
        for size in [CGSize(width: 200, height: 200), CGSize(width: 150, height: 50)] {
            let animationCompletion = expectation(description: "Animation completion")
            let resizeCompletion = expectation(description: "Resize completion")
            view.completeResizingStub.defaultSideEffect = { _ in resizeCompletion.fulfill() }

            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) {
                self.view.frame.size = size
            } completion: { _ in
                animationCompletion.fulfill()
            }
            wait(for: [animationCompletion, resizeCompletion], timeout: 5)
            XCTAssertEqual(view.mapboxMap.size, size)
        }

        XCTAssertEqual(view.willAnimateStub.invocations.map(\.parameters), [
            .init(from: CGSize(width: 100, height: 100), to: CGSize(width: 200, height: 200)),
            .init(from: CGSize(width: 200, height: 200), to: CGSize(width: 150, height: 50))
        ])
        XCTAssertEqual(view.completeResizingStub.invocations.map(\.parameters), [
            .init(from: CGSize(width: 100, height: 100), to: CGSize(width: 200, height: 200)),
            .init(from: CGSize(width: 200, height: 200), to: CGSize(width: 150, height: 50))
        ])
    }

    // MARK: CABasicAnimation

    func testCABasicAnimation() throws {
        let finalSize = CGSize(width: 400, height: 400)

        let animation = CABasicAnimation(keyPath: "bounds.size")
        animation.fromValue = NSValue(cgSize: view.layer.bounds.size)
        animation.toValue = NSValue(cgSize: finalSize)

        try assertCAAnimation(animation, finalBoundsSize: finalSize)
    }

    func testCABasicAnimationInsideAnimationGroup() throws {
        let finalSize = CGSize(width: 400, height: 400)

        let animation = CABasicAnimation(keyPath: "bounds.size")
        animation.fromValue = NSValue(cgSize: view.layer.bounds.size)
        animation.toValue = NSValue(cgSize: finalSize)

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [animation]

        try assertCAAnimation(animationGroup, finalBoundsSize: finalSize)
    }

    func testCABasicAnimationWithDelayCompletesAfterItEnds() throws {
        let finalSize = CGSize(width: 400, height: 400)
        let animation = CABasicAnimation(keyPath: "bounds.size")
        animation.fromValue = NSValue(cgSize: view.layer.bounds.size)
        animation.toValue = NSValue(cgSize: finalSize)
        animation.duration = 0.2
        animation.beginTime = CACurrentMediaTime() + 1
        let animationEnd = animation.beginTime + animation.duration

        var completionTime: CFTimeInterval?
        let resizeCompletion = expectation(description: "Resize completion")
        view.completeResizingStub.defaultSideEffect = { _ in
            completionTime = CACurrentMediaTime()
            resizeCompletion.fulfill()
        }

        view.layer.add(animation, forKey: "delayed")
        view.layer.bounds.size = finalSize
        XCTAssertEqual(view.willAnimateStub.invocations.count, 1)

        wait(for: [resizeCompletion], timeout: 5)
        // A small tolerance for timer precision; firing during the delay would be ~1 s early.
        XCTAssertGreaterThanOrEqual(try XCTUnwrap(completionTime), animationEnd - 0.02)
        XCTAssertEqual(view.mapboxMap.size, finalSize)
    }

    func testKeyFrameAnimation() throws {
        let startSize = view.layer.bounds.size
        let finalSize = CGSize(width: 400, height: 400)

        let animation = CAKeyframeAnimation(keyPath: "bounds.size")
        animation.values = [
            NSValue(cgSize: startSize),
            NSValue(cgSize: CGSize(width: startSize.width, height: finalSize.height)),
            NSValue(cgSize: finalSize),
        ]
        animation.keyTimes = [
            0,
            0.5,
            1
        ]

        try assertCAAnimation(animation, finalBoundsSize: finalSize)
    }

    func testKeyFrameAnimationInsideAnimationGroup() throws {
        let startSize = view.layer.bounds.size
        let finalSize = CGSize(width: 400, height: 400)

        let animation = CAKeyframeAnimation(keyPath: "bounds.size")
        animation.values = [
            NSValue(cgSize: startSize),
            NSValue(cgSize: CGSize(width: startSize.width, height: finalSize.height)),
            NSValue(cgSize: finalSize),
        ]
        animation.keyTimes = [
            0,
            0.5,
            1
        ]

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [animation]

        try assertCAAnimation(animationGroup, finalBoundsSize: finalSize)
    }

    // MARK: Unrelated animations

    func testMapSizeSettlesWhileUnrelatedAnimationInSameTransactionRuns() throws {
        let unrelatedLayer = CALayer()
        try XCTUnwrap(view.superview).layer.addSublayer(unrelatedLayer)
        defer { unrelatedLayer.removeFromSuperlayer() }

        // An infinite animation in the same transaction holds its completion block, as UIKit Liquid Glass does on rotation.
        let unrelatedAnimation = CABasicAnimation(keyPath: "opacity")
        unrelatedAnimation.fromValue = 0
        unrelatedAnimation.toValue = 1
        unrelatedAnimation.duration = .infinity

        let resizeCompletion = expectation(description: "Resize completion")
        view.completeResizingStub.defaultSideEffect = { _ in resizeCompletion.fulfill() }
        UIView.animate(withDuration: 0.1) {
            self.view.frame.size = CGSize(width: 200, height: 50)
            unrelatedLayer.add(unrelatedAnimation, forKey: "unrelated")
        }
        wait(for: [resizeCompletion], timeout: 5)

        XCTAssertEqual(view.completeResizingStub.invocations.map(\.parameters), [
            .init(from: CGSize(width: 100, height: 100), to: CGSize(width: 200, height: 50))
        ])
        XCTAssertEqual(view.mapboxMap.size, CGSize(width: 200, height: 50))
    }

    // MARK: Several bounds animations

    func testOverlappingResizesCompleteOnceWithFinalSize() throws {
        let firstAnimation = expectation(description: "First animation completion")
        let secondAnimation = expectation(description: "Second animation completion")
        let resizeCompletion = expectation(description: "Resize completion")
        view.completeResizingStub.defaultSideEffect = { _ in resizeCompletion.fulfill() }

        UIView.animate(withDuration: 0.2) {
            self.view.frame.size = CGSize(width: 300, height: 300)
        } completion: { _ in
            firstAnimation.fulfill()
        }
        UIView.animate(withDuration: 0.2) {
            self.view.frame.size = CGSize(width: 200, height: 50)
        } completion: { _ in
            secondAnimation.fulfill()
        }
        wait(for: [firstAnimation, secondAnimation, resizeCompletion], timeout: 5)

        XCTAssertEqual(view.willAnimateStub.invocations.count, 2)
        XCTAssertEqual(view.completeResizingStub.invocations.map(\.parameters), [
            .init(from: CGSize(width: 100, height: 100), to: CGSize(width: 200, height: 50))
        ])
        XCTAssertEqual(view.mapboxMap.size, CGSize(width: 200, height: 50))
    }

    func testInfiniteBoundsAnimationDoesNotHoldResizes() {
        let infiniteAnimation = CABasicAnimation(keyPath: "bounds.size")
        infiniteAnimation.fromValue = NSValue(cgSize: CGSize(width: 100, height: 100))
        infiniteAnimation.toValue = NSValue(cgSize: CGSize(width: 150, height: 150))
        infiniteAnimation.repeatCount = .infinity
        view.layer.add(infiniteAnimation, forKey: "infinite")
        defer { view.layer.removeAnimation(forKey: "infinite") }

        view.frame.size = CGSize(width: 200, height: 50)

        XCTAssertTrue(view.willAnimateStub.invocations.isEmpty)
        XCTAssertEqual(view.completeResizingStub.invocations.map(\.parameters), [
            .init(from: CGSize(width: 100, height: 100), to: CGSize(width: 200, height: 50))
        ])
    }

    // MARK: - Helpers

    func assertCAAnimation(_ animation: CAAnimation, key: String? = "custom-animation-key", finalBoundsSize: CGSize, file: StaticString = #file, line: UInt = #line) throws {
        XCTAssertNil(animation.delegate, "Delegate proxying is not supported")
        let animationCompletion = expectation(description: "Animation completion")
        animation.delegate = CAAnimationDelegateProxy { _, _ in
            animationCompletion.fulfill()
        }

        view.layer.add(animation, forKey: key)
        view.layer.anchorPoint = .zero
        view.layer.bounds.size = finalBoundsSize

        try assertViewInvocations(animationCompletion, file: file, line: line)
    }

    func assertViewInvocations(_ completionExpectation: XCTestExpectation, file: StaticString = #file, line: UInt = #line) throws {
        XCTAssertEqual(view.willAnimateStub.invocations.count, 1, "Number of willAnimate invocations before animation", file: file, line: line)
        XCTAssertTrue(view.completeResizingStub.invocations.isEmpty, "Number of completeResizing invocations before animation", file: file, line: line)

        wait(for: [completionExpectation], timeout: 60)

        XCTAssertEqual(view.willAnimateStub.invocations.count, 1, "Number of willAnimate invocations after animation", file: file, line: line)
        XCTAssertEqual(view.completeResizingStub.invocations.count, 1, "Number of completeResizing invocations after animation", file: file, line: line)
    }
}

final class SizeTrackingView: MapView {
    struct SizeChange: Equatable {
        let from: CGSize
        let to: CGSize
    }

    var willAnimateStub = Stub<SizeChange, Void>()
    override func sizeTrackingLayer(layer: MapboxMaps.SizeTrackingLayer, willAnimateResizingFrom from: CGSize, to: CGSize) {
        os_log(.info, "%@", "willAnimate from \(from) to \(to)")
        willAnimateStub.call(with: SizeChange(from: from, to: to))
        super.sizeTrackingLayer(layer: layer, willAnimateResizingFrom: from, to: to)
    }

    var completeResizingStub = Stub<SizeChange, Void>()
    override func sizeTrackingLayer(layer: MapboxMaps.SizeTrackingLayer, completeResizingFrom from: CGSize, to: CGSize) {
        os_log(.info, "%@", "completeResizing from \(from) to \(to)")
        completeResizingStub.call(with: SizeChange(from: from, to: to))
        super.sizeTrackingLayer(layer: layer, completeResizingFrom: from, to: to)
    }
}
