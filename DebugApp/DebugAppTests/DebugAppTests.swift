import XCTest
@testable import DebugApp

class DebugAppTests: ApplicationTestCase {
    func testExample() {
        let expect = expectation(description: "Waiting")
        DispatchQueue.main.asyncAfter(deadline: .now()+4) {
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5.0)
    }
}
