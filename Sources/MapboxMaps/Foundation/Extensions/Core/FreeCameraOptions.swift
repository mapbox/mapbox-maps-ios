import CoreLocation
import MapboxCoreMaps
import MapboxCommon.MBXCoordinate2D

extension FreeCameraOptions {

    /// The current mercator location coordinate.
    /// - Note: If the location could not be resolved in some case, `kCLLocationCoordinate2DInvalid` will be returned.
    public var location: CLLocationCoordinate2D {
        get {
            __getLocation()?.value ?? kCLLocationCoordinate2DInvalid
        }
        set {
            __setLocationForLocation(newValue)
        }
    }

    /// The current altitude in meters.
    public var altitude: CLLocationDistance {
        get {
            __getAltitude()?.doubleValue ?? 0
        }
        set {
            __setAltitudeForAltitude(newValue)
        }
    }
}
