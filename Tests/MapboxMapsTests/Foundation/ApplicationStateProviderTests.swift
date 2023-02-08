import Foundation
@testable import MapboxMaps
import XCTest

final class UIApplicationApplicationStateProviderTests: XCTestCase {
    var application: MockUIApplication!
    var provider: UIApplicationApplicationStateProvider!

    override func setUp() {
        super.setUp()

        application = MockUIApplication()
        provider = UIApplicationApplicationStateProvider(application: application)
    }

    override func tearDown() {
        provider = nil
        application = nil
        super.tearDown()
    }

    func testPreferredContentSizeCategory() {
        let states: [UIApplication.State] = [.active, .inactive, .background]

        for state in states {
            application.updateApplicationState(state)

            XCTAssertEqual(provider.applicationState, application.applicationState)
        }
    }
}

@available(iOS 13.0, *)
final class DefaultApplicationStateProviderTests: XCTestCase {
    var provider: DefaultApplicationStateProvider!

    override func setUp() {
        super.setUp()

        provider = DefaultApplicationStateProvider()
    }

    override func tearDown() {
        provider = nil
        super.tearDown()
    }

    func testPreferredContentSizeCategory() {
        let state = provider.applicationState

        XCTAssertNotNil(state)
        XCTAssertEqual(state, .active)
    }
}
