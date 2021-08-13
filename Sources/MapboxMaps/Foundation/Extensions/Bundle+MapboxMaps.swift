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
        guard let metadataPath = Bundle.mapboxMaps.url(forResource: "MapboxMaps", withExtension: "json"),
              let data = try? Data(contentsOf: metadataPath),
              let metadata = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return nil
        }
        return metadata as? [String: Any]
    }()
}
