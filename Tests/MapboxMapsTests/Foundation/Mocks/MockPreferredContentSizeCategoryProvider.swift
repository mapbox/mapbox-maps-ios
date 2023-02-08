import Foundation
@testable import MapboxMaps

final class MockPreferredContentSizeCategoryProvider: PreferredContentSizeCategoryProvider {
    let preferredContentSizeCategoryStub = Stub<UIContentSizeCategory>(defaultReturnValue: .unspecified)
    var preferredContentSizeCategory: UIContentSizeCategory {
        return preferredContentSizeCategory.call()
    }
}
