import UIKit

/// Configuration options for ``FollowPuckViewportState``.
///
/// Each of the ``CameraOptions-swift.struct``-related properties is optional, so that the state can be configured to
/// only modify certain aspects of the camera if desired. This can be used, to achieve effects like allowing
/// zoom gestures to work simultaneously with ``FollowPuckViewportState``.
///
/// - SeeAlso: ``ViewportOptions/transitionsToIdleUponUserInteraction``
public struct FollowPuckViewportStateOptions: Codable, Hashable {

    /// The value to use for ``CameraOptions-swift.struct/padding`` when setting the camera. If `nil`, padding
    /// will not be modified.
    public var padding: UIEdgeInsets? {
        get { paddingCodable?.edgeInsets }
        set { paddingCodable = newValue.map(UIEdgeInsetsCodable.init) }
    }

    private var paddingCodable: UIEdgeInsetsCodable?

    /// The value to use for ``CameraOptions-swift.struct/zoom`` when setting the camera. If `nil`, zoom will
    /// not be modified.
    public var zoom: CGFloat?

    /// Indicates how to obtain the value to use for ``CameraOptions-swift.struct/bearing`` when setting the
    /// camera. If `nil`, bearing will not be modified.
    public var bearing: FollowPuckViewportStateBearing?

    /// The value to use for ``CameraOptions-swift.struct/pitch`` when setting the camera. If `nil`, pitch will
    /// not be modified.
    public var pitch: CGFloat?

    /// Memberwise initializer for `FollowPuckViewportStateOptions`.
    ///
    /// All parameters have default values.
    ///
    /// - Parameters:
    ///   - padding: Defaults to `UIEdgeInsets.zero`.
    ///   - zoom: Defaults to 16.35.
    ///   - bearing: Defaults to ``FollowPuckViewportStateBearing/heading``.
    ///   - pitch: Defaults to 45.
    public init(padding: UIEdgeInsets? = .zero,
                zoom: CGFloat? = 16.35,
                bearing: FollowPuckViewportStateBearing? = .heading,
                pitch: CGFloat? = 45) {
        self.padding = padding
        self.zoom = zoom
        self.bearing = bearing
        self.pitch = pitch
    }
}
