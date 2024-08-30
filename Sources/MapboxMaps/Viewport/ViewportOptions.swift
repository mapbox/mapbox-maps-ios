/// Configuration options for ``ViewportManager``.
public struct ViewportOptions: Hashable, Sendable {
    /// Indicates whether the ``ViewportManager`` should idle when the ``MapView``
    /// receives pan touch input.
    ///
    /// Set this property to `false` to enable building custom ``ViewportState``s that
    /// can work simultaneously with certain types of gestures.
    ///
    /// Defaults to `true`.
    public var transitionsToIdleUponUserInteraction: Bool

    /// When `true`, all viewport states increase the camera padding by the amount of the safe area insets.
    ///
    /// You can use `UIViewController.additionalSafeAreaInsets` to control the additional amount of padding.
    ///
    /// Default value is `false`. If you use ``Map-struct`` in SwiftUI this value is true by default.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var usesSafeAreaInsetsAsPadding: Bool

    /// Creates viewport options
    /// - Parameters:
    ///     - transitionsToIdleUponUserInteraction: If `true`, viewport will idle when map receives pan gesture. Default value is `true`.
    public init(transitionsToIdleUponUserInteraction: Bool = true) {
        self.transitionsToIdleUponUserInteraction = transitionsToIdleUponUserInteraction
        self.usesSafeAreaInsetsAsPadding = false
    }

    /// Creates viewport options
    /// - Parameters:
    ///    - transitionsToIdleUponUserInteraction: If `true`, viewport will idle when map receives pan gesture. Default value is `true`.
    ///    - usesSafeAreaInsetsAsPadding: If `true`, all viewport states increase the camera padding by the amount of the safe area insets.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public init(transitionsToIdleUponUserInteraction: Bool,
                usesSafeAreaInsetsAsPadding: Bool) {
        self.transitionsToIdleUponUserInteraction = transitionsToIdleUponUserInteraction
        self.usesSafeAreaInsetsAsPadding = usesSafeAreaInsetsAsPadding
    }
}
