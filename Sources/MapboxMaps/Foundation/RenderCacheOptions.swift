/// Parameters that define behavior of the render cache.
public struct RenderCacheOptions {
    /// Maximum size allocated for the render cache in megabytes. Setting the
    /// value to zero will effectively disable the feature.
    ///
    /// Recommended starting values for the cache sizes are 64 and 128 for devices with pixel ratio 1.0 and > 1.0 respectively.
    public let size: UInt

    /// :nodoc:
    public init(size: UInt) {
        self.size = size
    }

    internal init(_ objcValue: MapboxCoreMaps.RenderCacheOptions) {
        self.size = objcValue.size?.uintValue ?? 0
    }
}

extension MapboxCoreMaps.RenderCacheOptions {
    internal convenience init(_ swiftValue: RenderCacheOptions) {
        self.init(__size: NSNumber(value: swiftValue.size))
    }
}
