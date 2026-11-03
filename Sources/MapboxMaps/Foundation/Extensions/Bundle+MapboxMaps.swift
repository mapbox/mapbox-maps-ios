import Foundation

private class BundleLocator {}

@_spi(Internal)
public struct MapboxMapsMetadata: Codable {
    public var version: String
}

extension Bundle {
    class var mapboxMaps: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        // When using frameworks this bundle will be our `.framework` bundle.
        // When using static linking this bundle will be the the host application's `.app` bundle.
        return Bundle(for: BundleLocator.self)
        #endif
    }

    /// :nodoc:
    @_spi(Internal)
    public static var mapboxMapsMetadata: MapboxMapsMetadata = {
        guard let metadataPath = Bundle.mapboxMaps.url(forResource: "MapboxMaps", withExtension: "json") else {
            return MapboxMapsMetadata(version: "unknown.ios-metatadata-failure")
        }
        do {
            let data = try Data(contentsOf: metadataPath)
            return try JSONDecoder().decode(MapboxMapsMetadata.self, from: data)
        } catch {
            return MapboxMapsMetadata(version: "unknown.ios-metatadata-failure")
        }
    }()
}
