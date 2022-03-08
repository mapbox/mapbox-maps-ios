import Foundation
import CoreLocation

/// Holds information about camera bounds.
public struct CameraBounds: Hashable {
    /// The latitude and longitude bounds to which the camera center are constrained.
    public let bounds: CoordinateBounds

    /// The maximum zoom level, in mapbox zoom levels 0-25.5. At low zoom levels,
    /// a small set of map tiles covers a large geographical area. At higher zoom
    /// levels, a larger number of tiles cover a smaller geographical area.
    public let maxZoom: CGFloat

    /// The minimum zoom level, in mapbox zoom levels 0-25.5.
    public let minZoom: CGFloat

    /// The maximum allowed pitch value in degrees.
    public let maxPitch: CGFloat

    /// The minimum allowed pitch value degrees.
    public let minPitch: CGFloat

    internal init(bounds: CoordinateBounds,
                  maxZoom: CGFloat,
                  minZoom: CGFloat,
                  maxPitch: CGFloat,
                  minPitch: CGFloat) {
        self.bounds = bounds
        self.maxZoom = maxZoom
        self.minZoom = minZoom
        self.maxPitch = maxPitch
        self.minPitch = minPitch
    }

    internal init(_ objcValue: MapboxCoreMaps.CameraBounds) {
        self.bounds = objcValue.bounds
        self.maxZoom = CGFloat(objcValue.maxZoom)
        self.minZoom = CGFloat(objcValue.minZoom)
        self.maxPitch = CGFloat(objcValue.maxPitch)
        self.minPitch = CGFloat(objcValue.minPitch)
    }

    public static func == (lhs: CameraBounds, rhs: CameraBounds) -> Bool {
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

extension CameraBounds {
    internal static var `default`: CameraBounds {
        let defaultSouthWest = CLLocationCoordinate2D(latitude: -90, longitude: -180)
        let defaultNorthEast = CLLocationCoordinate2D(latitude: 90, longitude: 180)

        return CameraBounds(bounds: CoordinateBounds(southwest: defaultSouthWest,
                                                     northeast: defaultNorthEast,
                                                     infiniteBounds: true),
                            maxZoom: 22,
                            minZoom: 0,
                            maxPitch: 85,
                            minPitch: 0)
    }
}
