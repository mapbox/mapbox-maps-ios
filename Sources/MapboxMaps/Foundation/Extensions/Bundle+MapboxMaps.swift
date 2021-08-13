import Foundation

private class BundleLocator {}

extension Bundle {
    class var mapboxMaps: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleLocator.self)
        #endif
    }

    static var mapboxMapsMetadata: [String: Any]? = {
        return [ "version" : "10.0.0-rc.6" ]
    }()
}
