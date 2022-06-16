/// Configuraton options for ``Viewport``.
public struct ViewportOptions: Hashable {
    /// Indicates whether the ``Viewport`` should idle when the ``MapView``
    /// receives touch input.
    ///
    /// Set this property to `false` to enable building custom ``ViewportState``s that
    /// can work simultaneously with certain types of gestures.
    ///
    /// Defaults to `true`.
    public var transitionsToIdleUponUserInteraction: Bool

    /// Initializes ``ViewportOptions``.
    /// - Parameter transitionsToIdleUponUserInteraction: Defaults to `true`.
    public init(transitionsToIdleUponUserInteraction: Bool = true) {
        self.transitionsToIdleUponUserInteraction = transitionsToIdleUponUserInteraction
    }
}
