import Foundation

internal protocol BundleProtocol: AnyObject {
    var infoDictionary: [String: Any]? { get }
    func path(forResource name: String?, ofType ext: String?) -> String?
}

extension Bundle: BundleProtocol {}
