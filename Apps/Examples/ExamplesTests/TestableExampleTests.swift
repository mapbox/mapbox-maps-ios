import XCTest
import ObjectiveC.runtime
@testable import Examples
import MapboxMaps

//swiftlint:disable force_cast
extension UINavigationController {
    func popToRootViewController(animated: Bool, completion: @escaping () -> Void) {
        popToRootViewController(animated: animated)

        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
}

class TestableExampleTests: XCTestCase {
    private var example: Example!
    private weak var weakExampleViewController: UIViewController?
    private weak var weakMapView: MapView?
    private var rootControllerExpectation: XCTestExpectation?

    override class var defaultTestSuite: XCTestSuite {
        let newTestSuite = XCTestSuite(forTestCaseClass: TestableExampleTests.self)

        guard let method = class_getInstanceMethod(Self.self, #selector(runExample)) else {
            fatalError()
        }

        let existingImpl = method_getImplementation(method)

        for category in Examples.all {
            for example in category["examples"] as! [Example] {
                // Add a method for this test, but using the same implementation
                if example.type == OfflineManagerExample.self ||
                   example.type == SnapshotterCoreGraphicsExample.self ||
                   example.type == StoryboardMapViewExample.self {
                    let selectorName = "test\(example.type)"
                    let testSelector = Selector((selectorName))
                    class_addMethod(Self.self, testSelector, existingImpl, "v@:f")

                    let test = TestableExampleTests(selector: testSelector)
                    test.example = example
                    newTestSuite.addTest(test)
                }
            }
        }
        return newTestSuite
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        XCTAssertNil(weakExampleViewController)
        XCTAssertNil(weakMapView)
    }

    @objc private func runExample() {
        guard let navigationController = UIApplication.shared.windows.first?.rootViewController as? UINavigationController else {
            XCTFail("Root controller is not a UINavigationController")
            return
        }
        navigationController.delegate = self

        let exampleViewController = example.makeViewController()
        weakExampleViewController = exampleViewController

        // Wait for the "finish" notification
        let expectation = XCTNSNotificationExpectation(name: Example.finishNotificationName, object: exampleViewController)

        navigationController.pushViewController(exampleViewController, animated: false)

        let result = XCTWaiter().wait(for: [expectation], timeout: example.testTimeout)
        switch result {
        case .completed:
            break
        case .timedOut:
            XCTFail("Example: \(example.title) timed out. Don't forget to call finish().")
        default:
            XCTFail("Expectation failed with \(result)")
        }

        if !(exampleViewController is NonMapViewExampleProtocol) {
            weakMapView = exampleViewController.firstMapView
            XCTAssertNotNil(weakMapView)
        }

        rootControllerExpectation = self.expectation(description: "Root controller is shown")
        navigationController.popToRootViewController(animated: false)

        let result1 = XCTWaiter().wait(for: [rootControllerExpectation!], timeout: 3)
        switch result1 {
        case .completed:
            break
        case .timedOut:
            XCTFail("Example: \(example.title) timed out. Don't forget to call finish().")
        default:
            XCTFail("Expectation failed with \(result)")
        }
    }
}

private extension UIViewController {
    var firstMapView: MapView? {
        return findMapView(in: view)
    }

    private func findMapView(in view: UIView) -> MapView? {
        if let mapView = view as? MapView {
            return mapView
        }

        for subview in view.subviews {
            if let mapView = subview as? MapView {
                return mapView
            }

            return findMapView(in: subview)
        }

        return nil
    }
}

extension TestableExampleTests: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController == navigationController.viewControllers.first {
            rootControllerExpectation?.fulfill()
        }
    }
}
