internal protocol MapTransformDelegate: AnyObject {
    /// Gets the size of the map in points
    var size: CGSize { get set }

    /// Notify map about gesture being in progress.
    var isGestureInProgress: Bool { get set }

    /// Tells the map rendering engine that the animation is currently performed
    /// by the user (e.g. with a `setCamera()` calls series). It adjusts the
    /// engine for the animation use case.
    /// In particular, it brings more stability to symbol placement and rendering.
    var isUserAnimationInProgress: Bool { get set }

    /// Returns the map's options
    var options: MapOptions { get }

    /// Set the map north orientation
    ///
    /// - Parameter northOrientation: The map north orientation to set
    func setNorthOrientation(northOrientation: NorthOrientation)

    /// Set the map constrain mode
    ///
    /// - Parameter constrainMode: The map constraint mode to set
    func setConstrainMode(_ constrainMode: ConstrainMode)

    /// Set the map viewport mode
    ///
    /// - Parameter viewportMode: The map viewport mode to set
    func setViewportMode(_ viewportMode: ViewportMode)
}
