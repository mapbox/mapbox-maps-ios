import Foundation
import CoreLocation

/// Instances of this class are delivered to `LocationConsumer`s by `LocationManager` whenever
/// the heading, location, or accuracy authorization change.
@objc public class Location: NSObject {

    /// A heading value. May be used directly or via the higher-level `headingDirection` property.
    public let heading: CLHeading?

    /// A location value. May be used directly or via the convenience accessors `coordinate`, `course`, and `horizontalAccuracy`.
    public let location: CLLocation

    /// A conveninece accessor for `location.coordinate`
    public var coordinate: CLLocationCoordinate2D {
        return location.coordinate
    }

    /// A convenience accessor for `location.course`
    public var course: CLLocationDirection {
        return location.course
    }

    /// A convenience accessor for `location.horizontalAccuracy`
    public var horizontalAccuracy: CLLocationAccuracy {
        return location.horizontalAccuracy
    }

    /// Returns `nil` if `heading` is `nil`, `heading.trueHeading` if it's non-negative,
    /// and `heading.magneticHeading` otherwise.
    public var headingDirection: CLLocationDirection? {
        return heading.map { $0.trueHeading >= 0 ? $0.trueHeading : $0.magneticHeading }
    }

    /// An accuracy authorization value.
    public let accuracyAuthorization: CLAccuracyAuthorization

    /// :nodoc:
    /// Deprecated. Initialize a `Location`. Use `init(location:heading:accuracyAuthorization:)` instead.
    public init(with location: CLLocation, heading: CLHeading? = nil) {
        self.location = location
        self.heading = heading
        self.accuracyAuthorization = .fullAccuracy
    }

    /// Initialize a `Location`
    public init(location: CLLocation,
                heading: CLHeading?,
                accuracyAuthorization: CLAccuracyAuthorization) {
        self.location = location
        self.heading = heading
        self.accuracyAuthorization = accuracyAuthorization
    }
}

internal extension CLLocationCoordinate2D {
    private typealias CoordinateDiff = (latitude: CLLocationDegrees, longitude: CLLocationDegrees)

    func isDifferentEnough(from other: CLLocationCoordinate2D) -> Bool {
        let precision = 0.000_000_1
        let diff = diff(to: other)

        return diff.latitude > precision || diff.latitude > precision
    }

    private func diff(to other: CLLocationCoordinate2D) -> CoordinateDiff {
        return (latitude: abs(latitude - other.latitude), longitude: abs(longitude - other.longitude))
    }

    func isDifferentEnough(from other: CLLocationCoordinate2D, for zoomLevel: CGFloat) -> Bool {
        let precision = pow(Double(10), -zoomLevelToPrecision(zoomLevel))
        let diff = diff(to: other)

        return diff.latitude > precision || diff.latitude > precision
    }

    private func zoomLevelToPrecision(_ zoomLevel: CGFloat) -> Double {
        let maxZoom: CGFloat = 22
        let maxPrecision: CGFloat = 7
        let precision = zoomLevel / (maxZoom / maxPrecision)
        let roundedPrecision = round(precision)
        return roundedPrecision
    }

    func foo() {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = [.naturalScale]
        let zooms = stride(from: CGFloat(0), to: CGFloat(22), by: CGFloat(1))
        for zoomLevel in zooms {
            let precision = pow(Double(10), -zoomLevelToPrecision(zoomLevel))
            let kmPerDegree: CGFloat = 111.11111111
            let distance = kmPerDegree * precision
            let measurement: Measurement<UnitLength>
            if distance <= 0.001 {
                formatter.unitOptions = [.providedUnit]
                measurement = Measurement(value: round(distance * 1000.0 * 100.0), unit: UnitLength.centimeters)
            } else {
                formatter.unitOptions = [.naturalScale]
                measurement = Measurement(value: distance, unit: UnitLength.kilometers)
            }

            print("zoom level: \(zoomLevel), precision: \(precision), distance: \(formatter.string(from: measurement))")
        }
        print("end")
    }
}
