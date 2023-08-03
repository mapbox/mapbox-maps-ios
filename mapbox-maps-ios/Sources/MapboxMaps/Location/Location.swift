import CoreLocation

extension Location {
    var accuracyAuthorization: CLAccuracyAuthorization {
        let value = getExtra(key: Self.accuracyAuthorizationKey)
        let casted = (value as? NSNumber).flatMap { CLAccuracyAuthorization(rawValue: $0.intValue) }
        return casted ?? .fullAccuracy
    }

    private func getExtra(key: String) -> AnyObject? {
        (extra as? [String: AnyObject])?[key]
    }

    static func makeExtra(for accuracyAuthorization: CLAccuracyAuthorization) -> [String: AnyObject] {
        return [
            accuracyAuthorizationKey: NSNumber(value: accuracyAuthorization.rawValue)
        ]
    }

    private static let accuracyAuthorizationKey = "accuracyAuthorization"
}
