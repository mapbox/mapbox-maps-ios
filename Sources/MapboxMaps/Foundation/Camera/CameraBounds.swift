import Foundation
import CoreLocation

public struct CameraBounds: Hashable {
    public let bounds: CoordinateBounds
    public let maxZoom: CGFloat
    public let minZoom: CGFloat
    public let maxPitch: CGFloat
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
