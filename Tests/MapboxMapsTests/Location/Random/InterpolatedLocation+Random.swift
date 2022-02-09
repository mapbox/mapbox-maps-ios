@testable import MapboxMaps

extension InterpolatedLocation {
    static func random() -> Self {
        return InterpolatedLocation(
            coordinate: .random(),
            altitude: .random(in: 0...100),
            horizontalAccuracy: .random(in: 0...100),
            course: .random(.random(in: 0..<360)),
            heading: .random(.random(in: 0..<360)),
            accuracyAuthorization: .random())
    }
}
