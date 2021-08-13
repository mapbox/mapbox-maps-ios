import Foundation

private class BundleLocator {}

internal struct MapboxMapsMetaData: Codable {
    var version: String
}

extension Bundle {
    class var mapboxMaps: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleLocator.self)
        #endif
    }

    static var mapboxMapsMetadata: MapboxMapsMetaData? = {
        guard let metadataPath = Bundle.mapboxMaps.url(forResource: "MapboxMaps", withExtension: "json"),
              let data = try? Data(contentsOf: metadataPath) else {
            return nil
        }

        return try? JSONDecoder().decode(MapboxMapsMetaData.self, from: data)
    }()
}
