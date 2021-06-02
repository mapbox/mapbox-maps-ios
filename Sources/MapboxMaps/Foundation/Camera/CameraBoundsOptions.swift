import Foundation
import CoreLocation

public struct CameraBoundsOptions: Hashable {
    public var bounds: CoordinateBounds?
    public var maxZoom: CGFloat?
    public var minZoom: CGFloat?
    public var maxPitch: CGFloat?
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
        self.maxZoom = objcValue.__maxZoom.flatMap{ CGFloat($0.doubleValue) }
        self.minZoom = objcValue.__minZoom.flatMap{ CGFloat($0.doubleValue) }
        self.maxPitch = objcValue.__maxPitch.flatMap{ CGFloat($0.doubleValue) }
        self.minPitch = objcValue.__minPitch.flatMap{ CGFloat($0.doubleValue) }
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
    public init(cameraBounds: CameraBounds) {
        self.bounds = cameraBounds.bounds
        self.maxZoom = CGFloat(cameraBounds.maxZoom)
        self.minZoom = CGFloat(cameraBounds.minZoom)
        self.maxPitch = CGFloat(cameraBounds.maxPitch)
        self.minPitch = CGFloat(cameraBounds.minPitch)
    }
}

extension MapboxCoreMaps.CameraBoundsOptions {
    internal convenience init(_ swiftValue: CameraBoundsOptions) {
        self.init(__bounds: swiftValue.bounds,
                  maxZoom: swiftValue.maxZoom?.NSNumber,
                  minZoom: swiftValue.minZoom?.NSNumber,
                  maxPitch: swiftValue.maxPitch?.NSNumber,
                  minPitch: swiftValue.minPitch?.NSNumber)
    }
}

extension MapboxCoreMaps.CameraBounds {
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
