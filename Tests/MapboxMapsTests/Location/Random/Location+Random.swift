import MapboxMaps
import MapboxCommon

extension Location {
    static func random() -> Location {
        Location(
            coordinate: .random(),
            timestamp: Date(),
            bearing: .random(),
            bearingAccuracy: .random()
        )
    }
}

extension Heading {
    static func random() -> Heading {
        Heading(direction: .random(),
                accuracy: .random())
    }
}

extension PuckRenderingData {
    static func random() -> PuckRenderingData {
        PuckRenderingData(location: .random(), heading: .random())
    }
}

extension CLLocationDirection {
    static func random() -> CLLocationDirection {
        random(in: 0..<360)
    }
}
