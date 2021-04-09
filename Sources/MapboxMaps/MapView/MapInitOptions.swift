import Foundation

@objc public protocol MapInitOptionsDataSource {
    /// When you implement this method you should return a `MapInitOptions`.
    func mapInitOptions() -> Any
}

public struct MapInitOptions: Equatable {
    //asdf
    public static var `default`: MapInitOptions {
        MapInitOptions(resourceOptions: ResourceOptions.default,
                       mapOptions: MapOptions.default)
    }

    public let resourceOptions: ResourceOptions
    public let mapOptions: MapOptions

    public init(resourceOptions: ResourceOptions,
                mapOptions: MapOptions) {
        self.resourceOptions = resourceOptions
        self.mapOptions = mapOptions
    }
}
