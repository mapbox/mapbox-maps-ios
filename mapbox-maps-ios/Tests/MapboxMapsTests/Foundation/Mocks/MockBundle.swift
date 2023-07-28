import Foundation
@testable import MapboxMaps

final class MockBundle: BundleProtocol {
    let infoDictionaryStub = Stub<Void, [String: Any]?>(defaultReturnValue: nil)
    var infoDictionary: [String: Any]? {
        infoDictionaryStub.call()
    }

    struct PathForResoucrParameters {
        let name, ext: String?
    }
    let pathForResourceStub = Stub<PathForResoucrParameters, String?>(defaultReturnValue: nil)
    func path(forResource name: String?, ofType ext: String?) -> String? {
        pathForResourceStub.call(with: PathForResoucrParameters(name: name, ext: ext))
    }
}
