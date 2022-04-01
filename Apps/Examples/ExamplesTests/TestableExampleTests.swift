import XCTest
import ObjectiveC.runtime
@testable import Examples

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

    override class var defaultTestSuite: XCTestSuite {
        let newTestSuite = XCTestSuite(forTestCaseClass: TestableExampleTests.self)

        guard let method = class_getInstanceMethod(Self.self, #selector(runExample)) else {
            fatalError()
        }

        let existingImpl = method_getImplementation(method)

        for category in Examples.all {
            for example in category["examples"] as! [Example] {
                // Add a method for this test, but using the same implementation
                let selectorName = "test\(example.type)"
                let testSelector = Selector((selectorName))
                class_addMethod(Self.self, testSelector, existingImpl, "v@:f")

                let test = TestableExampleTests(selector: testSelector)
                test.example = example
                newTestSuite.addTest(test)
            }
        }
        return newTestSuite
    }

    @objc private func runExample() {
        guard let navigationController = UIApplication.shared.windows.first?.rootViewController as? UINavigationController else {
            XCTFail("Root controller is not a UINavigationController")
            return
        }

        let exampleViewController = example.makeViewController()

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

        navigationController.popToRootViewController(animated: false)
    }
}
