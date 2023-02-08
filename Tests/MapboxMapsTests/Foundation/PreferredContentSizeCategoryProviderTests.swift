import Foundation
@testable import MapboxMaps
import XCTest

final class UIApplicationPreferredContentSizeCategoryProviderTests: XCTestCase {
    var application: MockUIApplication!
    var provider: UIApplicationPreferredContentSizeCategoryProvider!

    override func setUp() {
        super.setUp()

        application = MockUIApplication()
        provider = UIApplicationPreferredContentSizeCategoryProvider(application: application)
    }

    override func tearDown() {
        provider = nil
        application = nil
        super.tearDown()
    }

    func testPreferredContentSizeCategory() {
        let categories: [UIContentSizeCategory] = [.unspecified, .extraSmall, .small, .medium, .large, .extraLarge, .extraExtraLarge, .extraExtraExtraLarge]

        for category in categories {
            application.updatePreferredContentSizeCategory(category)

            XCTAssertEqual(provider.preferredContentSizeCategory, application.preferredContentSizeCategory)
        }
    }
}

@available(iOS 13.0, *)
final class DefaultPreferredContentSizeCategoryProviderTests: XCTestCase {
    var provider: DefaultPreferredContentSizeCategoryProvider!

    override func setUp() {
        super.setUp()

        provider = DefaultPreferredContentSizeCategoryProvider()
    }

    override func tearDown() {
        provider = nil
        super.tearDown()
    }

    func testPreferredContentSizeCategory() {
        let category = provider.preferredContentSizeCategory

        XCTAssertNotNil(category)
        XCTAssertEqual(category, .unspecified)
    }
}
