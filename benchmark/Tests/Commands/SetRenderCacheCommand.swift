import Foundation
@_spi(Experimental) @testable import MapboxMaps

struct SetRenderCacheCommand: AsyncCommand {
    private let cacheSize: UInt64

    @MainActor
    func execute() async throws {
        guard let mapView = UIViewController.rootController?.findMapView() else {
            throw ExecutionError.cannotFindMapboxMap
        }

        mapView.mapboxMap.setRenderCache(RenderCacheOptions(__size: NSNumber(value: cacheSize)))
    }
}

extension SetRenderCacheCommand: Decodable {

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        cacheSize = try container.decode(UInt64.self)
    }
}
