import Foundation
@testable import MapboxMaps

final class MockPreferredContentSizeCategoryProvider: PreferredContentSizeCategoryProvider {
    let preferredContentSizeCategoryStub = Stub<Void, UIContentSizeCategory>(defaultReturnValue: .unspecified)
    var preferredContentSizeCategory: UIContentSizeCategory {
        return preferredContentSizeCategory.call()
    }
}
