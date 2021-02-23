import XCTest
import ObjectiveC.runtime
@testable import Examples

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

    override class var defaultTestSuite: XCTestSuite {
        let newTestSuite = XCTestSuite(forTestCaseClass: TestableExampleTests.self)

        guard let method = class_getInstanceMethod(Self.self, #selector(runExample)) else {
            fatalError()
        }

        let existingImpl = method_getImplementation(method)

        for example in Examples.all  {
            // Add a method for this test, but using the same implementation
            let selectorName = "test\(example.type)"
            let testSelector = Selector((selectorName))
            class_addMethod(Self.self, testSelector, existingImpl, "v@:f")

            let test = TestableExampleTests(selector: testSelector)
            test.example = example
            newTestSuite.addTest(test)
        }

        return newTestSuite
    }

    @objc private func runExample() {
        guard let navigationController = UIApplication.shared.windows.first?.rootViewController as? UINavigationController else {
            XCTFail("Root controller is not a UINavigationController")
            return
        }

        guard let examplesTableViewController = navigationController.viewControllers.first as? ExampleTableViewController else {
            XCTFail("First controller is not a ExampleTableViewController")
            return
        }

        examplesTableViewController.show(example: example)

        // Wait for the "finish" notification
        let expectation = XCTDarwinNotificationExpectation(notificationName: Example.finishNotificationName)

        let result = XCTWaiter().wait(for: [expectation], timeout: example.testTimeout)
        switch result {
        case .completed:
            break

        case .timedOut:
            // TODO: check if this is a failure
            print("Example timed out, was this intentional? Call finish() if possible.")

        default:
            XCTFail("Expectation failed with \(result)")
        }

        let popExpectation = self.expectation(description: "Pop to root controller")
        navigationController.popToRootViewController(animated: true) {
            popExpectation.fulfill()
        }
        wait(for: [popExpectation], timeout: 5.0)
    }
}
