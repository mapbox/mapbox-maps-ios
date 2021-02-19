import Foundation

private class BundleLocator {}

extension Bundle {
    class var mapbox: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleLocator.self)
        #endif
    }
}
