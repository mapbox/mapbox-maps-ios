import Foundation
@testable import MapboxMaps

final class MockBundle: BundleProtocol {
    let infoDictionaryStub = Stub<Void, [String: Any]?>(defaultReturnValue: nil)
    var infoDictionary: [String: Any]? {
        infoDictionaryStub.call()
    }
}
