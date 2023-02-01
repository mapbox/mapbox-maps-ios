internal struct DefaultViewportTransitionAnimationSpec {
    internal var duration: TimeInterval
    internal var delay: TimeInterval
    internal var cameraOptionsComponent: CameraOptionsComponentProtocol

    internal var total: TimeInterval {
        delay + duration
    }

    internal func scaled(by factor: Double) -> Self {
        var updatedSpec = self
        updatedSpec.duration *= factor
        updatedSpec.delay *= factor
        return updatedSpec
    }
}
