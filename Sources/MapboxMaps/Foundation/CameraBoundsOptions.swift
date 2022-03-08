import Foundation
import CoreLocation

/// Holds options to be used for setting camera bounds.
public struct CameraBoundsOptions: Hashable {

    /// The latitude and longitude bounds to which the camera center are constrained.
    public var bounds: CoordinateBounds?

    /// The maximum zoom level, in mapbox zoom levels 0-25.5. At low zoom levels,
    /// a small set of map tiles covers a large geographical area. At higher
    /// zoom levels, a larger number of tiles cover a smaller geographical area.
    public var maxZoom: CGFloat?

    /// The minimum zoom level, in mapbox zoom levels 0-25.5.
    public var minZoom: CGFloat?

    /// The maximum allowed pitch value in degrees.
    public var maxPitch: CGFloat?

    /// The minimum allowed pitch value degrees.
    public var minPitch: CGFloat?

    public init(bounds: CoordinateBounds? = nil,
                maxZoom: CGFloat? = nil,
                minZoom: CGFloat? = nil,
                maxPitch: CGFloat? = nil,
                minPitch: CGFloat? = nil) {
        self.bounds = bounds
        self.maxZoom = maxZoom
        self.minZoom = minZoom
        self.maxPitch = maxPitch
        self.minPitch = minPitch
    }

    internal init(_ objcValue: MapboxCoreMaps.CameraBoundsOptions) {
        self.bounds = objcValue.bounds
        self.maxZoom = objcValue.__maxZoom.flatMap { CGFloat($0.doubleValue) }
        self.minZoom = objcValue.__minZoom.flatMap { CGFloat($0.doubleValue) }
        self.maxPitch = objcValue.__maxPitch.flatMap { CGFloat($0.doubleValue) }
        self.minPitch = objcValue.__minPitch.flatMap { CGFloat($0.doubleValue) }
    }

    public static func == (lhs: CameraBoundsOptions, rhs: CameraBoundsOptions) -> Bool {
        return lhs.bounds == rhs.bounds
            && lhs.maxZoom == rhs.maxZoom
            && lhs.minZoom == rhs.minZoom
            && lhs.maxPitch == rhs.maxPitch
            && lhs.minPitch == rhs.minPitch
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(bounds)
        hasher.combine(maxZoom)
        hasher.combine(minZoom)
        hasher.combine(maxPitch)
        hasher.combine(minPitch)
    }
}

extension CameraBoundsOptions {

    /// Initialize a `CameraBoundsOptions` from the immutable `CameraBounds` type
    /// - Parameter cameraBounds: `CameraBounds`
    public init(cameraBounds: CameraBounds) {
        bounds = cameraBounds.bounds
        maxZoom = cameraBounds.maxZoom
        minZoom = cameraBounds.minZoom
        maxPitch = cameraBounds.maxPitch
        minPitch = cameraBounds.minPitch
    }
}

// MARK: - MapboxCoreMaps.CameraBoundsOptions -

extension MapboxCoreMaps.CameraBoundsOptions {
    internal convenience init(_ swiftValue: CameraBoundsOptions) {
        self.init(__bounds: swiftValue.bounds,
                  maxZoom: swiftValue.maxZoom?.NSNumber,
                  minZoom: swiftValue.minZoom?.NSNumber,
                  maxPitch: swiftValue.maxPitch?.NSNumber,
                  minPitch: swiftValue.minPitch?.NSNumber)
    }
}
