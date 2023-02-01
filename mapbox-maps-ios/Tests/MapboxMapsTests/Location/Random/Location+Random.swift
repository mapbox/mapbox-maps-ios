import MapboxMaps

extension Location {
    static func random() -> Location {
        return Location(
            location: .random(),
            heading: .random(MockHeading()),
            accuracyAuthorization: .random())
    }
}
