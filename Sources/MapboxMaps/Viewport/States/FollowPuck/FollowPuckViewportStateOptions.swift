import UIKit
@_spi(Internal) import MapboxCoreMaps

/// Configuration options for ``FollowPuckViewportState``.
///
/// Each of the ``CameraOptions-swift.struct``-related properties is optional, so that the state can be configured to
/// only modify certain aspects of the camera if desired. This can be used, to achieve effects like allowing
/// zoom gestures to work simultaneously with ``FollowPuckViewportState``.
///
/// - SeeAlso: ``ViewportOptions/transitionsToIdleUponUserInteraction``
public struct FollowPuckViewportStateOptions: Codable, Hashable, Sendable {

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

    /// The value to use for ``CameraOptions-swift.struct/verticalFov`` when setting the camera. If `nil`, vertical fov will
    /// not be modified.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var verticalFov: CGFloat?

    /// Creates options.
    ///
    /// - Parameters:
    ///   - padding: Camera padding.
    ///   - zoom: Camera zoom. Default value is 16.35.
    ///   - bearing: camera bearing, by default bearing will be taken from heading data.
    ///   - pitch: Camera pitch. Default value is 45.
    ///   - verticalFov: Camera vertical fov. Default value is 36.87.
    public init(padding: UIEdgeInsets? = nil,
                zoom: CGFloat? = 16.35,
                bearing: FollowPuckViewportStateBearing? = .heading,
                pitch: CGFloat? = 45,
                verticalFov: CGFloat? = 36.87) {
        self.padding = padding
        self.zoom = zoom
        self.bearing = bearing
        self.pitch = pitch
        self.verticalFov = verticalFov
    }
}
