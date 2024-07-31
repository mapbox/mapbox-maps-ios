import Foundation

private class BundleLocator {}

internal struct MapboxMapsMetadata: Codable {
    var version: String
}

extension Bundle {
    class var mapboxMaps: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        // When using frameworks this bundle will be our `.framework` bundle.
        // When using static linking this bundle will be the the host application's `.app` bundle.
        let bundle = Bundle(for: BundleLocator.self)

        // When using CocoaPods a "resource bundle" will be used to avoid resource conflicts with the host application.
        // Check for the existence of the resource bundle and use that instead if it is present.
        let resourceBundle = bundle.path(forResource: "MapboxMapsResources", ofType: "bundle")
            .flatMap(Bundle.init(path:))

        return resourceBundle ?? bundle
        #endif
    }

    static var mapboxMapsMetadata: MapboxMapsMetadata = {
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
