import UIKit

private let defaultOrnamentsMargin = CGPoint(x: 8.0, y: 8.0)

/// Used to configure Ornament-specific capabilities of the map
///
/// All margin values are relative to the MapView's safe area. To allow the safe area
/// (and thereby ornaments) to track the presence of navigation bars and tab bars,
/// make MapView the root view of a view controller.
public struct OrnamentOptions: Equatable {

    // MARK: - Scale Bar
    /// The ornament options for the scale bar. The scale bar has a default position of `.topLeft`.
    public var scaleBarOptions: CompassScaleBarOptions = CompassScaleBarOptions(position: .topLeft)

    // MARK: - Compass

    /// The ornament options for the compass view. The compass view has a default position of `.topRight`.
    public var compassViewOptions: CompassScaleBarOptions = CompassScaleBarOptions(position: .topRight)

    // MARK: - Logo View
    /**
     Per our terms of service, a Mapbox map is required to display both
     a Mapbox logo as well as an information icon that contains attribution
     information. See https://docs.mapbox.com/help/how-mapbox-works/attribution/
     for details.
     */
    /// The ornament options for the logo view. The logo view has a default position of `.bottomLeft`.
    public var logoViewOptions: AttributionLogoViewOptions = AttributionLogoViewOptions(position: .bottomLeft)

    // MARK: - Attribution Button
    /// The ornament options for the attribution button. The attribution button has a default position of `.bottomRight`.
    public var attributionButtonOptions: AttributionLogoViewOptions = AttributionLogoViewOptions(position: .bottomRight)
}

/// Used to configure position, margin, and visibility for the map's scale bar and compass view.
public struct CompassScaleBarOptions: Equatable {
    public var position: OrnamentPosition
    /// The default value for this property is `CGPoint(x: 8.0, y: 8.0)`.
    public var margins: CGPoint = defaultOrnamentsMargin
    /// The default value for this property is `.adaptive`.
    public var visibility: OrnamentVisibility = .adaptive
}

/// Used to configure the map's logo view and attribution button.
public struct AttributionLogoViewOptions: Equatable {
    public var position: OrnamentPosition
    /// The default value for this property is `CGPoint(x: 8.0, y: 8.0)`.
    public var margins: CGPoint = defaultOrnamentsMargin
    /// The default value for this property is `true`.
    public var _isVisible: Bool = true
}
