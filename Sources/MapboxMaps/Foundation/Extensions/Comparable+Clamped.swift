internal extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        if self > limits.upperBound {
            return limits.upperBound
        } else if self < limits.lowerBound {
            return limits.lowerBound
        } else {
            return self
        }
    }
}
