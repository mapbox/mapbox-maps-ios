extension FloatingPoint {
    internal func wrapped(to range: Range<Self>) -> Self {
        let d = range.upperBound - range.lowerBound
        return fmod(fmod(self - range.lowerBound, d) + d, d) + range.lowerBound
    }

    internal func toDegrees() -> Self {
        return self * 180 / .pi
    }

    /// Calculates the rotation between two angles in radians. Result is wrapped to [0, 2pi)
    internal func wrappedAngle(to: Self) -> Self {
        return (to - self).wrapped(to: 0..<(2 * .pi))
    }
}
