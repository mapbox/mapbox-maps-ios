internal protocol LocationInterpolatorProtocol: AnyObject {
    func interpolate(from fromLocation: [Location],
                     to toLocation: [Location],
                     fraction: Double) -> [Location]
}

internal final class LocationInterpolator: LocationInterpolatorProtocol {
    private let doubleInterpolator: DoubleInterpolatorProtocol
    private let directionInterpolator: DirectionInterpolatorProtocol
    private let coordinateInterpolator: CoordinateInterpolatorProtocol
    private let optionalInterpolator = OptionalInterpolator()

    internal init(doubleInterpolator: DoubleInterpolatorProtocol,
                  directionInterpolator: DirectionInterpolatorProtocol,
                  coordinateInterpolator: CoordinateInterpolatorProtocol) {
        self.doubleInterpolator = doubleInterpolator
        self.directionInterpolator = directionInterpolator
        self.coordinateInterpolator = coordinateInterpolator
    }

    convenience init() {
        let doubleInterpolator = DoubleInterpolator()
        let wrappingInterpolator = WrappingInterpolator()
        let directionInterpolator = DirectionInterpolator(
            wrappingInterpolator: wrappingInterpolator)
        let longitudeInterpolator = LongitudeInterpolator(
            wrappingInterpolator: wrappingInterpolator)
        let coordinateInterpolator = CoordinateInterpolator(
            doubleInterpolator: doubleInterpolator,
            longitudeInterpolator: longitudeInterpolator)
        self.init(
            doubleInterpolator: doubleInterpolator,
            directionInterpolator: directionInterpolator,
            coordinateInterpolator: coordinateInterpolator)
    }

    internal func interpolate(from fromLocation: [Location],
                              to toLocation: [Location],
                              fraction: Double) -> [Location] {
        guard let toLocation = toLocation.last else {
            return []
        }

        guard let fromLocation = fromLocation.last else {
            return [toLocation]
        }

        let coordinate = coordinateInterpolator.interpolate(
            from: fromLocation.coordinate,
            to: toLocation.coordinate,
            fraction: fraction)

        let altitude = optionalInterpolator.interpolate(
            from: fromLocation.altitude,
            to: toLocation.altitude,
            fraction: fraction,
            interpolate: doubleInterpolator.interpolate(from:to:fraction:))

        let horizontalAccuracy = optionalInterpolator.interpolate(
            from: fromLocation.horizontalAccuracy,
            to: toLocation.horizontalAccuracy,
            fraction: fraction,
            interpolate: doubleInterpolator.interpolate(from:to:fraction:))

        let bearing = optionalInterpolator.interpolate(
            from: fromLocation.bearing,
            to: toLocation.bearing,
            fraction: fraction,
            interpolate: directionInterpolator.interpolate(from:to:fraction:))

    return [
        Location(
            coordinate: coordinate,
            timestamp: toLocation.timestamp,
            altitude: altitude ?? toLocation.altitude,
            horizontalAccuracy: horizontalAccuracy ?? toLocation.horizontalAccuracy,
            verticalAccuracy: toLocation.verticalAccuracy,
            speed: toLocation.speed,
            speedAccuracy: toLocation.speedAccuracy,
            bearing: bearing ?? toLocation.bearing,
            bearingAccuracy: toLocation.bearingAccuracy,
            floor: toLocation.floor,
            source: toLocation.source,
            extra: toLocation.extra)
        ]
    }
}
