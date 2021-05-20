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
    public var preferredFramesPerSecond: PreferredFPS = .maximum

    /// When loading a map, if `prefetchZoomDelta` is set to any number greater
    /// than 0, the map will first request a tile for `zoom - prefetchZoomDelta`
    /// in an attempt to display a full map at lower resolution as quick as
    /// possible.
    ///
    /// It will get clamped at the tile source minimum zoom. The default delta
    /// is 4.
    public var prefetchZoomDelta: UInt8 = 4

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

    public init() {}
}
