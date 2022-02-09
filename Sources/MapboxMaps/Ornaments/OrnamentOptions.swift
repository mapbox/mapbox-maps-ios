import UIKit

private let defaultOrnamentsMargin = CGPoint(x: 8.0, y: 8.0)

/// Used to configure Ornament-specific capabilities of the map
///
/// All margin values are relative to the MapView's safe area. To allow the safe area
/// (and thereby ornaments) to track the presence of navigation bars and tab bars,
/// make MapView the root view of a view controller.
public struct OrnamentOptions: Equatable {

    // MARK: - Scale Bar
    /// The ornament options for the map's scale bar..
    public var scaleBar = ScaleBarViewOptions()

    // MARK: - Compass

    /// The ornament options for the map's compass view.
    public var compass = CompassViewOptions()

    // MARK: - Logo View
    /**
     Per our terms of service, a Mapbox map is required to display both
     a Mapbox logo as well as an information icon that contains attribution
     information. See https://docs.mapbox.com/help/how-mapbox-works/attribution/
     for details.
     */

    /// The ornament options for the map's logo view.
    public var logo = LogoViewOptions()

    // MARK: - Attribution Button

    /// The ornament options for the map's attribution button.
    public var attributionButton = AttributionButtonOptions()
}

/// :nodoc:
/// Deprecated. This protocol will be removed in a future major version.
public protocol OrnamentOptionsProtocol {
    var position: OrnamentPosition { get set }
    var margins: CGPoint { get set }
}

/// Used to configure position, margin, and visibility for the map's scale bar view.
public struct ScaleBarViewOptions: OrnamentOptionsProtocol, Equatable {
    /// The default value for this property is `.topLeft`.
    public var position: OrnamentPosition = .topLeft
    /// The default value for this property is `CGPoint(x: 8.0, y: 8.0)`.
    public var margins: CGPoint = defaultOrnamentsMargin
    /// The default value for this property is `.adaptive`.
    public var visibility: OrnamentVisibility = .adaptive
}

/// Used to configure position, margin, and visibility for the map's compass view.
public struct CompassViewOptions: OrnamentOptionsProtocol, Equatable {
    /// The default value for this property is `.topRight`.
    public var position: OrnamentPosition = .topRight
    /// The default value for this property is `CGPoint(x: 8.0, y: 8.0)`.
    public var margins: CGPoint = defaultOrnamentsMargin
    /// The default value for this property is `.adaptive`.
    public var visibility: OrnamentVisibility = .adaptive
}

/// Used to configure position, margin, and visibility for the map's attribution button.
public struct AttributionButtonOptions: OrnamentOptionsProtocol, Equatable {
    /// The default value for this property is `.bottomRight`.
    public var position: OrnamentPosition = .bottomRight
    /// The default value for this property is `CGPoint(x: 8.0, y: 8.0)`.
    public var margins: CGPoint = defaultOrnamentsMargin
    /// The default value for this property is `visible`. Setting this property to `.adaptive`
    /// will lead to the same behavior as `.visible`. The attribution button will be visible
    /// as long as the map view is visible.
    /// :nodoc:
    /// Restricted API. Please contact Mapbox to discuss your use case if you intend to use this property.
    @_spi(Restricted) public var visibility: OrnamentVisibility = .visible
}

/// Used to configure position, margin, and visibility for the map's logo view.
public struct LogoViewOptions: OrnamentOptionsProtocol, Equatable {
    /// The default value for this property is `.bottomLeft`.
    public var position: OrnamentPosition = .bottomLeft
    /// The default value for this property is `CGPoint(x: 8.0, y: 8.0)`.
    public var margins: CGPoint = defaultOrnamentsMargin
    /// The default value for this property is `visible`. Setting this property to `.adaptive`
    /// willl lead to the same behavior as `.visible`. The logo view will be visible as long
    /// as the map view is visible.
    /// :nodoc:
    /// Restricted API. Please contact Mapbox to discuss your use case if you intend to use this property.
    @_spi(Restricted) public var visibility: OrnamentVisibility = .visible
}
