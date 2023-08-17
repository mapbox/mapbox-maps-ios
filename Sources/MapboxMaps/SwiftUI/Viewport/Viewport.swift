import SwiftUI
import Turf

/// The viewport represents the ways to position camera.
///
/// The viewport may be set to the map as initial viewport:
///
/// ```swift
///  Map(initialViewport: .styleDefault)
/// ```
///
/// or as binding:
///
/// ```swift
/// struct UserLocationMap: View {
///   @State var viewport: Viewport = .followPuck(zoom: 16, bearing: .heading)
///   var body: some View {
///     Map(viewport: $viewport)
///   }
/// }
/// ```
///
/// Viewport change can be animated via the ``withViewportAnimation(_:body:completion:)``.
///
/// ```swift
///   struct AnimatedMap: View {
///       @State var viewport: Viewport = .styleDefault
///       var body: some View {
///           Map(viewport: $viewport)
///               .overlay {
///                   Button("Locate the user") {
///                       withViewportMapAnimation {
///                           viewport = .followPuck(zoom: 16, bearing: .heading, pitch: 60)
///                       }
///                   }
///               }
///       }
///   }
/// ```
@_spi(Experimental)
@available(iOS 13.0, *)
public struct Viewport: Equatable {
    enum Storage: Equatable {
        case idle
        case styleDefault
        case camera(CameraOptions)
        case overview(OverviewOptions)
        case followPuck(FollowPuckOptions)
    }

    /// Options for the overview viewport.
    public struct OverviewOptions: Equatable {
        public var geometry: Geometry
        public var bearing: CGFloat
        public var pitch: CGFloat
    }

    /// Options for the follow puck viewport.
    public struct FollowPuckOptions: Equatable {
        public var zoom: CGFloat
        public var bearing: FollowPuckViewportStateBearing
        public var pitch: CGFloat
    }

    /// Represent insets configuration.
    ///
    /// Inset configuration is applicable to every kind of viewport configuration except ``MapViewport/idle``.
    public struct InsetOptions: Equatable {
        var insets: SwiftUI.EdgeInsets = .init()
        var ignoredSafeAreaEdges: Edge.Set = []
    }

    let storage: Storage

    /// Configures insets of viewport.
    public var insetOptions = InsetOptions()

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
    /// - Returns: A viewport configured with given overview settings.
    public static func overview(
        geometry: GeometryConvertible,
        bearing: CGFloat = 0,
        pitch: CGFloat = 0
    ) -> Viewport {
        let options = OverviewOptions(geometry: geometry.geometry, bearing: bearing, pitch: pitch)
        return Viewport(storage: .overview(options))
    }

    /// Configures camera to follow the user location indicator.
    ///
    /// - Note: It's recommended to use only the ``MapViewportAnimation/default`` animation option for transition
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

    /// Creates a new MapViewport with modified inset options.
    ///
    /// Insets are ignored for `idle` viewport.
    ///
    /// By default, insets are equal to the safe area. This method allows you to set additional insets, or ignore safe area part on the specified edges.
    ///
    /// - Parameters:
    ///   - insets: Additional insets, that will be summarized with existing safe area insets.
    ///   - ignoringSafeArea: A set of edges where safe area's contribution to the resulting inset should be ignored.
    /// - Returns: A viewport with modified inset options.
    public func inset(by insets: SwiftUI.EdgeInsets, ignoringSafeArea: Edge.Set = []) -> Viewport {
        var copy = self
        copy.insetOptions = .init(insets: insets, ignoredSafeAreaEdges: ignoringSafeArea)
        return copy
    }

    /// Creates a new MapViewport with modified inset options.
    ///
    /// Insets are ignored for `idle` viewport.
    ///
    /// By default, insets are equal to the safe area. This method allows you to set additional inset for the specified edges.
    /// This method can be called multiple times to configure different edges.
    ///
    /// - Parameters:
    ///   - edges: Edges for which to set the additional inset.
    ///   - length: The length of inset.
    ///   - ignoringSafeArea: If safe area's contribution should be ignored for the specified edges.
    /// - Returns: A viewport with modified inset options.
    public func inset(edges: Edge.Set, length: CGFloat, ignoringSafeArea: Bool = false) -> Viewport {
        var copy = self

        for (edge, keyPath) in edgeToInsetMapping where edges.contains(edge) {
            copy.insetOptions.insets[keyPath: keyPath] = length
            if ignoringSafeArea {
                copy.insetOptions.ignoredSafeAreaEdges.remove(edge)
            } else {
                copy.insetOptions.ignoredSafeAreaEdges.insert(edge)
            }
        }

        return copy
    }

    /// Is `true` when viewport is idle.
    public var isIdle: Bool {
        return storage == .idle
    }

    /// Is `true` when camera is configured from the default style camera properties.
    public var isStyleDefault: Bool {
        return storage == .styleDefault
    }

    /// Returns the camera options if viewport is configured with camera options.
    ///
    /// - Note: The ``CameraOptions/padding`` is ignored, it is replaced with ``insetConfig``, see ``inset(by:ignoringSafeArea:)``.
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

@available(iOS 13.0, *)
extension Viewport {
    func makeState(with mapView: MapView, layoutDirection: LayoutDirection) -> ViewportState? {
        // TODO: mapView's safeAreaInsets don't reflect the real safe area added by SwiftUI views (such as toolbars).
        let padding = padding(with: layoutDirection, safeAreaInsets: mapView.safeAreaInsets)
        switch storage {
        case .idle:
            return nil
        case .camera(var cameraOptions):
            cameraOptions.padding = padding
            return CameraViewportState(cameraOptions: cameraOptions)
        case .overview(let options):
            let options = OverviewViewportStateOptions(
                geometry: options.geometry,
                padding: padding,
                bearing: options.bearing,
                pitch: options.pitch,
                animationDuration: 0)
            return mapView.viewport.makeOverviewViewportState(options: options)
        case .styleDefault:
            return DefaultStyleViewportState(
                mapboxMap: mapView.mapboxMap,
                styleManager: mapView.mapboxMap,
                padding: padding)
        case .followPuck(let options):
            let options = FollowPuckViewportStateOptions(
                padding: padding,
                zoom: options.zoom,
                bearing: options.bearing,
                pitch: options.pitch)
            return mapView.viewport.makeFollowPuckViewportState(options: options)
        }
    }

    private func padding(with layoutDirection: LayoutDirection, safeAreaInsets: UIEdgeInsets) -> UIEdgeInsets {
        var result = SwiftUI.EdgeInsets(uiInsets: safeAreaInsets, layoutDirection: layoutDirection)

        for (edge, keyPath) in edgeToInsetMapping where insetOptions.ignoredSafeAreaEdges.contains(edge) {
            result[keyPath: keyPath] = 0
        }

        result += insetOptions.insets

        return UIEdgeInsets(insets: result, layoutDirection: layoutDirection)
    }
}
