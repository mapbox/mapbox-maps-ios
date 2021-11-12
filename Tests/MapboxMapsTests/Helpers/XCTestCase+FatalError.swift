import XCTest
@testable import MapboxMaps

// From https://stackoverflow.com/a/68496755
extension XCTestCase {
    /// Pass in the code that is expected to result in a fatal error.
    /// - Parameter expectedMessage: The error message from the original fatal error.
    /// - Parameter testCase: The code that should result in a fatal error,
    func expectFatalError(expectedMessage: String, testcase: @escaping () -> Void) {

        // Setup an expectation and nil string to store the assertion message.
        let expectation = self.expectation(description: "expectingFatalError")
        var assertionMessage: String? = nil

        // Override fatalError. Store the fatal error message.
        FatalErrorUtil.replaceFatalError { message, _, _ in
            DispatchQueue.main.async {
                assertionMessage = message
                expectation.fulfill()
            }

            // Terminate the current thread after the expectation is fulfilled.
            Thread.exit()
            // Since current thread was terminated this code should never be executed.
            // This line satisfies the block's requirement to return `Never`.
            fatalError("This should not be executed.")
        }

        // Start the test case block on a separate thread. This allows us to
        // to terminate this thread after the expectation has been fulfilled.
        Thread(block: testcase).start()

        waitForExpectations(timeout: 0.1) { _ in
            XCTAssertEqual(expectedMessage, assertionMessage, "The expected message was \(expectedMessage). Got \(assertionMessage ?? "nil").")

            // Switch back to using the Swift global `fatalError`
            FatalErrorUtil.restoreFatalError()
        }
    }
}
