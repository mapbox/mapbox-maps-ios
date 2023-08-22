@testable import MapboxMaps
import XCTest

final class OnceTests: XCTestCase {

    func testExecuteExactlyOnce() {
        var once = Once()
        var isExecuted = false

        once {
            isExecuted = true
        }
        once {
            XCTFail("Once should not be executed more than once")
        }

        XCTAssertTrue(isExecuted)
    }

    func testReset() {
        var once = Once()
        var executionCount = 0

        once {
            executionCount += 1
        }
        once.reset()
        once {
            executionCount += 1
        }
        once {
            XCTFail("Once should not be executed more than once unless reset")
        }

        XCTAssertEqual(executionCount, 2)
    }

    func testResetIf() {
        var once = Once()
        var executionCount = 0

        once {
            executionCount += 1
        }
        once.reset(if: false)
        once {
            XCTFail("shouldn't be reset")
        }

        once.reset(if: true)
        once {
            executionCount += 1
        }

        XCTAssertEqual(executionCount, 2)
    }

    func testTry() {
        var once = Once()
        XCTAssertEqual(once.continueOnce(), true)
        XCTAssertEqual(once.continueOnce(), false)

        once.reset()
        XCTAssertEqual(once.continueOnce(), true)
    }
}
