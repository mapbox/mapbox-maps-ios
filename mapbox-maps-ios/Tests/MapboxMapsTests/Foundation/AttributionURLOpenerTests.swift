import Foundation
@testable import MapboxMaps
import XCTest

final class AttributionURLOpenerTests: XCTestCase {
    var urlOpener: DefaultAttributionURLOpener!
    var application: MockUIApplication!

    override func setUp() {
        super.setUp()

        application = MockUIApplication()
        urlOpener = DefaultAttributionURLOpener(application: application)
    }

    override func tearDown() {
        urlOpener = nil
        application = nil
        super.tearDown()
    }

    func testURLOpener() {
        let url = URL(string: "http://example.com")!

        urlOpener.openAttributionURL(url)

        XCTAssertEqual(application.openURLStub.invocations.count, 1)
        XCTAssertEqual(application.openURLStub.invocations.first?.parameters, url)
    }
}
