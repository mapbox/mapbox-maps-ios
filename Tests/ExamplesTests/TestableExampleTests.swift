import XCTest
import ObjectiveC.runtime
@testable import Examples
import MapboxMaps

final class TestableExampleTests: XCTestCase {
    private weak var weakExampleViewController: UIViewController?
    private weak var weakMapView: MapView?
    private var exampleControllerRemovedExpectation: XCTestExpectation?

    override static var defaultTestSuite: XCTestSuite {
        let newTestSuite = XCTestSuite(forTestCaseClass: TestableExampleTests.self)

        for example in Examples.all.flatMap(\.examples) {
            // Add a method for this test, but using the same implementation
            let testSelector = Selector("test\(example.type)")
            let myBlock: @convention(block) (TestableExampleTests) -> Void = { testCase in
                testCase.runExample(example)
            }

            let closureImpl = imp_implementationWithBlock(myBlock)
            class_addMethod(Self.self, testSelector, closureImpl, "v@:")

            let test = TestableExampleTests(selector: testSelector)
            print("Adding test for \(example)")
            newTestSuite.addTest(test)
        }

        return newTestSuite
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        // check for the example view controller and its mapview leaking
        // this check may also fail when finish is called earlier than all stored async operation that cpature self were completed and it will lead to delayed deinitialization
        XCTAssertNil(weakExampleViewController, "Example viewController is part of a memory leak")
        XCTAssertNil(weakMapView, "Example mapView is part of a memory leak")
    }

    private func runExample(_ example: Example) {
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
            print("Example: \(example.title) completed.")
        case .timedOut:
            XCTFail("Example: \(example.title) timed out. Don't forget to call finish().")
        default:
            XCTFail("Expectation failed with \(result)")
        }

        if !(exampleViewController is NonMapViewExampleProtocol) {
            weakMapView = try? XCTUnwrap(exampleViewController.firstMapView)
        }

        exampleControllerRemovedExpectation = self.expectation(description: "Example view controller is removed")
        navigationController.popToRootViewController(animated: false)

        // wait for navigation controller to remove and release the example view controller
        wait(for: [exampleControllerRemovedExpectation!], timeout: 3)
    }
}

extension TestableExampleTests: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController == navigationController.viewControllers.first {
            exampleControllerRemovedExpectation?.fulfill()
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
