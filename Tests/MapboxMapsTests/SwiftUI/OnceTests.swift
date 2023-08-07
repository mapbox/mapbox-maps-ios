@testable import MapboxMaps
import XCTest

final class OnceTests: XCTestCase {

    func testOnceExecuteExactlyOnce() {
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

    func testOnceCanBeReset() {
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
}
