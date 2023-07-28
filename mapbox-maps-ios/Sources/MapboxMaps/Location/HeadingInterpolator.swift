internal func interpolateHeading(from: Heading, to: Heading, fraction: Double) -> Heading {
    let direction = directionInterpolator.interpolate(
        from: from.direction,
        to: to.direction,
        fraction: fraction)

    return Heading(
        direction: direction,
        accuracy: to.accuracy,
        timestamp: to.timestamp)
}

private let directionInterpolator = DirectionInterpolator(wrappingInterpolator: WrappingInterpolator())
