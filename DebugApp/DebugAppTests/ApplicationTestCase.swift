import XCTest
import MetalKit
@testable import DebugApp

class ApplicationTestCase: XCTestCase {
    var vc: DebugViewController?

    override class func tearDown() {
        super.tearDown()
        // Add a breakpoint here to check memory graphs and callstacks.
        print("ApplicationTestCases complete")
    }

    override func setUpWithError() throws {
        try super.setUpWithError()

        guard MTLCreateSystemDefaultDevice() != nil else {
            throw XCTSkip("No valid Metal device")
        }

        guard let mvc = UIApplication.shared.windows.first?.rootViewController as? MainViewController else {
            XCTFail("Root view controller should be MainViewController")
            return
        }

        let expect = expectation(description: "Present view controller")
        mvc.showViewController { vc in
            self.vc = vc

            // TODO: Configure the DebugViewController. For example, override
            // the LocationProvider so we don't get the request permission
            // system dialog.
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)
    }

    override func tearDown() {
        if let vc = vc {
            let expect = expectation(description: "Dismiss view controller")
            vc.dismiss(animated: false) {
                expect.fulfill()
            }
            wait(for: [expect], timeout: 1.0)
        }
        vc = nil
        super.tearDown()
    }

    override func invokeTest() {
        // By wrapping invokeTest with an autorelease pool, we can
        // check that objects have been released as expected in the
        // class tearDown()
        autoreleasepool {
            super.invokeTest()
        }
    }
}
