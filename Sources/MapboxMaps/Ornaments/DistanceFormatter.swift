import CoreLocation

/**
 `DistanceFormatter` implements a formatter object meant to be used for
 geographic distances. The user’s current locale will be used by default
 but it can be overriden by changing the locale property of the numberFormatter.
 */
internal class DistanceFormatter: MeasurementFormatter {

    /// Returns a localized formatted string for the provided distance.
    ///
    /// - parameter distance: The distance, measured in meters.
    /// - returns: A localized formatted distance string including units.
    internal func string(fromDistance distance: CLLocationDistance) -> String {

        numberFormatter.roundingIncrement = 0.25

        var measurement = Measurement(value: distance, unit: UnitLength.meters)

        if !locale.usesMetricSystem {
            unitOptions = .providedUnit
            measurement.convert(to: .miles)
            if measurement.value <= 0.2 {
                measurement.convert(to: .feet)
            }
        } else {
            unitOptions = .naturalScale
        }
        return string(from: measurement)
    }
}
