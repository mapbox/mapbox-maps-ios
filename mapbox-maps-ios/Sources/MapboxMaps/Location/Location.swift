import CoreLocation

extension Location {
    // TODO: Remove this in common v24.0.0-beta.2
    func copyBySetting(accuracyAuthorization: CLAccuracyAuthorization) -> Location {
        var extra = extraDictionary
        extra[accuracyAuthorizationKey] = accuracyAuthorization
        return Location(
            coordinate: coordinate,
            timestamp: timestamp,
            altitude: altitude,
            horizontalAccuracy: horizontalAccuracy,
            verticalAccuracy: verticalAccuracy,
            speed: speed,
            speedAccuracy: speedAccuracy,
            bearing: bearing,
            bearingAccuracy: bearingAccuracy,
            floor: floor,
            source: source,
            extra: extra)
    }

    private var extraDictionary: [String: Any] {
        extra as? [String: Any] ?? [:]
    }

    private func getExtra(key: String) -> Any? {
        (extra as? [String: Any])?[key]
    }

    var accuracyAuthorization: CLAccuracyAuthorization {
        let value = getExtra(key: accuracyAuthorizationKey) as? CLAccuracyAuthorization
        return value ?? .fullAccuracy
    }
}

private let accuracyAuthorizationKey = "accuracyAuthorization"
