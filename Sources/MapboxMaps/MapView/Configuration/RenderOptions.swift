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

    /// A Boolean value that indicates whether the underlying `CAMetalLayer` of the `MapView`
    /// presents its content using a CoreAnimation transaction
    ///
    /// By default, this is `false` resulting in the output of a rendering pass being displayed on
    /// the `CAMetalLayer` as quickly as possible (and asynchronously). This typically results
    /// in the fastest rendering performance.
    ///
    /// If, however, the `MapView` is overlaid with a `UIKit` element which must be pinned to a
    /// particular lat-long, then setting this to `true` will result in better synchronization and less jitter.
    public var presentsWithTransaction: Bool = false
}
