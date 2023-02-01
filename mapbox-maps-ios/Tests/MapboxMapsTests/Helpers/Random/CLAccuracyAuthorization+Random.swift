import CoreLocation

extension CLAccuracyAuthorization {
    static func random() -> Self {
        return .random() ? .fullAccuracy : .reducedAccuracy
    }
}
