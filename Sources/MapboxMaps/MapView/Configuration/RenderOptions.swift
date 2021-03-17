import Foundation

/// Used to configure rendering-specific capabilities of the `MapView`
public struct RenderOptions: Equatable {

    ///  The preferred frame rate at which the map view is rendered.
    ///
    ///  The default value for this property is
    ///  `.normal`, which will adaptively set the
    ///  preferred frame rate based on the capability of the user’s device to maintain
    ///  a smooth experience.
    ///
    ///  See Also `CADisplayLink.preferredFramesPerSecond`
    public var preferredFramesPerSecond: PreferredFPS = .normal

    ///  A Boolean value indicating whether the map should prefetch tiles.
    ///
    ///  When this property is set to `true`, the map view prefetches tiles designed for
    ///  a low zoom level and displays them until receiving more detailed tiles for the
    ///  current zoom level. The prefetched tiles typically contain simplified versions
    ///  of each shape, improving the map view’s perceived performance.
    ///
    ///  The default value of this property is `true`.
    public var prefetchesTiles: Bool = true
}
