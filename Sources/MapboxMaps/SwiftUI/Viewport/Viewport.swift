import SwiftUI
import Turf

/// Viewport represents the ways to position camera.
///
/// Currently, several types of viewport are supported:
/// - Default Style viewport sets the camera to the camera parameters defined in the Style root property. This type is used by default.
/// - Camera viewport allows to directly set camera using center coordinate, zoom, bearing, pitch, and anchor.
/// - Overview viewport helps to focus the map camera on a specified Geometry with the minimum zoom level. For example, focus user attention on a route line.
/// - Follow Puck viewport automatically tracks the user's position on the map.
/// - Idle viewport is activated when the user interacts with the map. You can also set it to interrupt the ongoing viewport transition animation.
///
/// Typically, you set viewport via two methods: by setting the constant initial viewport, or passing the viewport `Binding`.
/// The former method is handy to set viewport only once, at map initialization time:
/// ```swift
/// struct StaticViewport: View {
///     var body: some View {
///         // Focus camera on Disneyland at zoom 10.
///         Map(initialViewport: .camera(center: disneyland, zoom: 10))
///     }
/// }
///
/// private let disneyland = CLLocationCoordinate(latitude: 33.812092, longitude: -117.918976)
/// ```
///
/// The latter method allows you to programmatically update the viewport at any time, with or without animations:
///
/// ```swift
/// struct UserLocationMap: View {
///     // Initially, focus camera on US Disneyland.
///     @State var viewport: Viewport = .camera(center: disneyland, zoom: 10)
///
///     var body: some View {
///         VStack {
///             Map(viewport: $viewport)
///             Button("Jump to Paris Disneyland") {
///                 // Later, update viewport with the different settings.
///                 viewport = .camera(center: CLLocationCoordinate2D(latitude: 48.868, longitude: 2.782), zoom: 12)
///             }
///             Button("Animate to User") {
///                 // Or, update viewport with animation.
///                 withViewportAnimation {
///                     viewport = .followPuck(zoom: 16, bearing: .heading, pitch: 60)
///                 }
///             }
///         }
///     }
/// }
/// ```
///
/// See ``withViewportAnimation(_:body:completion:)`` and ``ViewportAnimation`` for more details about viewport animation.
///
/// The ``Viewport`` allows you to read only the values that you set. If you need to read the actual camera state values, subscribe to ``Map/onCameraChanged(action:)`` event.
public struct Viewport: Equatable, Sendable {
    enum Storage: Equatable, Sendable {
        case idle
        case styleDefault
        case camera(CameraOptions)
        case overview(OverviewOptions)
        case followPuck(FollowPuckOptions)
    }

    /// Options for the overview viewport.
    public struct OverviewOptions: Equatable, Sendable {
        /// Geometry to overview.
        public var geometry: Geometry
        /// Camera bearing.
        public var bearing: CGFloat

        /// Camera pitch.
        public var pitch: CGFloat

        /// Extra padding that is added for the geometry during bounding box calculation.
        ///
        /// - Note: Geometry padding is different to camera padding ``Viewport/padding-swift.property``.
        public var geometryPadding: SwiftUI.EdgeInsets

        /// The maximum zoom level to allow.
        public var maxZoom: Double?

        /// The center of the given bounds relative to the map's center, measured in points.
        public var offset: CGPoint?
    }

    /// Options for the follow puck viewport.
    public struct FollowPuckOptions: Equatable, Sendable {
        /// Camera zoom.
        public var zoom: CGFloat

        /// Camera bearing.
        public var bearing: FollowPuckViewportStateBearing

        /// Camera pitch.
        public var pitch: CGFloat
    }

    let storage: Storage

    /// Denotes camera padding of the viewport.
    public var padding = SwiftUI.EdgeInsets()

    /// Idle viewport represents the state when user freely drags the map.
    ///
    /// The viewport is automatically switches to `idle` state when the user starts dragging the map.
    /// Setting the `idle` viewport results in cancelling any ongoing camera animation.
    public static var idle: Viewport {
        return Viewport(storage: .idle)
    }

    /// Sets camera to the default camera options defined in the current style.
    ///
    /// See more in the [Mapbox Style Specification](https://docs.mapbox.com/mapbox-gl-js/style-spec/root/#center).
    public static var styleDefault: Viewport {
        Viewport(storage: .styleDefault)
    }

    /// Manually sets camera to specified properties.
    ///
    /// - Parameters:
    ///   - center: The geographic coordinate that will be rendered at the midpoint of the map.
    ///   - anchor: Point in the map's coordinate system about which `zoom` and `bearing` should be applied. Mutually exclusive with `center`.
    ///   - zoom: The zoom level of the map.
    ///   - bearing: The bearing of the map, measured in degrees clockwise from true north.
    ///   - pitch: Pitch toward the horizon measured in degrees, with 0 degrees resulting in a top-down view for a two-dimensional map.
    /// - Returns: A viewport configured with given camera settings.
    public static func camera(center: CLLocationCoordinate2D? = nil,
                              anchor: CGPoint? = nil,
                              zoom: CGFloat? = nil,
                              bearing: CLLocationDirection? = nil,
                              pitch: CGFloat? = nil) -> Viewport {
        let cameraOptions = CameraOptions(
            center: center,
            anchor: anchor,
            zoom: zoom,
            bearing: bearing,
            pitch: pitch)
        return Viewport(storage: .camera(cameraOptions))
    }

    /// Configures camera to show overview of the specified geometry.
    ///
    /// - Parameters:
    ///   - geometry: Geometry to show.
    ///   - bearing: The bearing of the map, measured in degrees clockwise from true north.
    ///   - pitch: Pitch toward the horizon measured in degrees, with 0 degrees resulting in a top-down view for a two-dimensional map.
    ///   - geometryPadding: Extra padding to add to geometry.
    ///   - maxZoom: The maximum zoom level to allow.
    ///   - offset: The center of the given bounds relative to the map's center, measured in points.
    /// - Returns: A viewport configured with given overview settings.
    public static func overview(
        geometry: GeometryConvertible,
        bearing: CGFloat = 0,
        pitch: CGFloat = 0,
        geometryPadding: SwiftUI.EdgeInsets = .init(),
        maxZoom: Double? = nil,
        offset: CGPoint? = nil
    ) -> Viewport {
        let options = OverviewOptions(
            geometry: geometry.geometry,
            bearing: bearing,
            pitch: pitch,
            geometryPadding: geometryPadding,
            maxZoom: maxZoom,
            offset: offset)
        return Viewport(storage: .overview(options))
    }

    /// Configures camera to follow the user location indicator.
    ///
    /// - Note: It's recommended to use only the ``ViewportAnimation/default`` animation option for transition
    /// to the `followPuck` viewport, because it handles the moving user location puck.
    /// Other animation options such as `easeIn`, `easeOut`, `easeInOut`,  `linear`, or `fly` don't support this.
    ///
    /// - Parameters:
    ///   - zoom: Zoom level of the map.
    ///   - bearing: Bearing of the map.
    ///   - pitch: Pitch toward the horizon measured in degrees, with 0 degrees resulting in a top-down view for a two-dimensional map.
    /// - Returns: A viewport configured to follow the user location puck.
    public static func followPuck(zoom: CGFloat,
                                  bearing: FollowPuckViewportStateBearing = .constant(0),
                                  pitch: CGFloat = 0) -> Viewport {
        let options = FollowPuckOptions(zoom: zoom, bearing: bearing, pitch: pitch)
        return Viewport(storage: .followPuck(options))
    }

    /// :nodoc:
    @available(*, deprecated, renamed: "padding")
    public func inset(by insets: SwiftUI.EdgeInsets, ignoringSafeArea: Edge.Set = []) -> Viewport { self }

    /// :nodoc:
    @available(*, unavailable, renamed: "padding")
    public func inset(edges: Edge.Set, length: CGFloat, ignoringSafeArea: Bool = false) -> Viewport { self }

    /// Adds padding to viewport.
    ///
    /// Safe area insets will be added to that value to form actual padding. If this method called twice, only the last call will take effect.
    ///
    /// - Parameters:
    ///   - padding: Camera
    /// - Returns: A viewport with modified inset options.
    public func padding(_ padding: SwiftUI.EdgeInsets) -> Viewport {
        copyAssigned(self, \.padding, padding)
    }

    /// Adds padding to viewport at specific edges.
    ///
    /// - Parameters:
    ///   - edges: The set of edges to pad. Default is a `all`.
    ///   - length: Amount of padding in points.
    /// - Returns: A viewport with modified inset options.
    public func padding(_ edges: Edge.Set = .all, _ length: CGFloat) -> Viewport {
        var copy = self
        copy.padding.updateEdges(edges, length)
        return copy
    }

    /// `true` when viewport is idle.
    public var isIdle: Bool {
        return storage == .idle
    }

    /// `true` when camera is configured from the default style camera properties.
    public var isStyleDefault: Bool {
        return storage == .styleDefault
    }

    /// Returns the camera options if viewport is configured with camera options.
    ///
    /// - Note: The ``CameraOptions-swift.struct/padding`` is ignored, it is replaced with ``Viewport/padding``, see ``Viewport/padding(_:)``.
    public var camera: CameraOptions? {
        switch storage {
        case .camera(let camera):
            return camera
        default:
            return nil
        }
    }

    /// Returns the overview options if viewport is configured to overview the specified geometry.
    public var overview: OverviewOptions? {
        switch storage {
        case .overview(let options):
            return options
        default:
            return nil
        }
    }

    /// Returns the follow puck options if viewport is configured to follow the user location puck.
    public var followPuck: FollowPuckOptions? {
        switch storage {
        case .followPuck(let options):
            return options
        default:
            return nil
        }
    }
}

extension Viewport {
    func makeState(with mapView: MapView, layoutDirection: LayoutDirection) -> ViewportState? {
        let padding = UIEdgeInsets(insets: padding, layoutDirection: layoutDirection)
        switch storage {
        case .idle:
            return nil
        case .camera(var cameraOptions):
            cameraOptions.padding = padding
            return mapView.viewport.makeCameraViewportState(camera: cameraOptions)
        case .overview(let options):
            let options = options.resolve(layoutDirection: layoutDirection, padding: padding)
            return mapView.viewport.makeOverviewViewportState(options: options)
        case .styleDefault:
            return mapView.viewport.makeDefaultStyleViewportState(padding: padding)
        case .followPuck(let options):
            let options = options.resolve(padding: padding)
            return mapView.viewport.makeFollowPuckViewportState(options: options)
        }
    }
}

extension Viewport.OverviewOptions {
    func resolve(layoutDirection: LayoutDirection, padding: UIEdgeInsets) -> OverviewViewportStateOptions {
        let geometryPadding = UIEdgeInsets(insets: geometryPadding, layoutDirection: layoutDirection)
        return OverviewViewportStateOptions(
            geometry: geometry,
            geometryPadding: geometryPadding,
            bearing: bearing,
            pitch: pitch,
            padding: padding,
            maxZoom: maxZoom,
            offset: offset,
            animationDuration: 0)
    }
}

extension Viewport.FollowPuckOptions {
    func resolve(padding: UIEdgeInsets) -> FollowPuckViewportStateOptions {
        FollowPuckViewportStateOptions(
            padding: padding,
            zoom: zoom,
            bearing: bearing,
            pitch: pitch)
    }
}
