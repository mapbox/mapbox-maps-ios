import Foundation

internal protocol BundleProtocol: AnyObject {
    var infoDictionary: [String: Any]? { get }
}

extension Bundle: BundleProtocol {}
