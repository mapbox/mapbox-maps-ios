import Foundation
import CoreLocation

/// Holds options to be used for setting camera bounds.
public struct CameraBoundsOptions: Hashable {

    /// The latitude and longitude bounds to which the camera center is constrained.
    /// Defaults to: Southwest: (-90, -180) and Northeast: (90, 180).
    public var bounds: CoordinateBounds?

    /// The maximum zoom level, in mapbox zoom levels 0-25.5. At low zoom levels,
    /// a small set of map tiles covers a large geographical area. At higher
    /// zoom levels, a larger number of tiles cover a smaller geographical area.
    /// Defaults to 22.
    public var maxZoom: CGFloat?

    /// The minimum zoom level, in mapbox zoom levels 0-25.5.
    /// Defaults to 0.
    public var minZoom: CGFloat?

    /// The maximum allowed pitch value in degrees.
    /// Defaults to 85.
    public var maxPitch: CGFloat?

    /// The minimum allowed pitch value degrees.
    /// Defaults to 0.
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

    internal init(_ objcValue: CoreCameraBoundsOptions) {
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

// TODO: After MAPSIOS-1538 landed - mark as Sendable along with the inner type CoordinateBounds which need to be marked as Sendable.
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

extension CoreCameraBoundsOptions {
    internal convenience init(_ swiftValue: CameraBoundsOptions) {
        self.init(__bounds: swiftValue.bounds,
                  maxZoom: swiftValue.maxZoom?.NSNumber,
                  minZoom: swiftValue.minZoom?.NSNumber,
                  maxPitch: swiftValue.maxPitch?.NSNumber,
                  minPitch: swiftValue.minPitch?.NSNumber)
    }
}
