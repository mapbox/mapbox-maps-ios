import Foundation

@objc public protocol MapInitOptionsDataSource {
    /// When you implement this method you should return a `MapInitOptions`.
    func mapInitOptions() -> Any
}

extension MapInitOptionsDataSource {
    public func mapInitOptions() -> Any {
        return MapInitOptions.default
    }
}

public struct MapInitOptions {
    public static let `default` = MapInitOptions(resourceOptions: ResourceOptions.default,
                                                 mapOptions: MapOptions.default)

    public let resourceOptions: ResourceOptions
    public let mapOptions: MapOptions

    public init(resourceOptions: ResourceOptions,
                mapOptions: MapOptions) {
        self.resourceOptions = resourceOptions
        self.mapOptions = mapOptions
    }
}
