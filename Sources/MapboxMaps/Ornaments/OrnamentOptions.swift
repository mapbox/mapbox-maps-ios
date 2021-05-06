import UIKit

private let defaultOrnamentsMargin = CGPoint(x: 8.0, y: 8.0)

/// Used to configure Ornament-specific capabilities of the map
///
/// All margin values are relative to the MapView's safe area. To allow the safe area
/// (and thereby ornaments) to track the presence of navigation bars and tab bars,
/// make MapView the root view of a view controller.
public struct OrnamentOptions: Equatable {

    // MARK: - Scale Bar
    /// Used to configure position, margin, and visibility for the map's scale bar.
    /// The scale bar's default position is `.topLeft`.
    public var scaleBar = BaseOrnamentOptions(position: .topLeft)

    // MARK: - Compass

    /// Used to configure position, margin, and visibility for the map's compass view.
    /// The default position for the compass view is `.topRight`.
    public var compass = BaseOrnamentOptions(position: .topRight)

    // MARK: - Logo View
    /**
     Per our terms of service, a Mapbox map is required to display both
     a Mapbox logo as well as an information icon that contains attribution
     information. See https://docs.mapbox.com/help/how-mapbox-works/attribution/
     for details.
     */

    /// Used to configure position, margin, and visibility for the map's logo view.
    /// The default position for the logo view is `.bottomLeft`.
    /// Setting visibility to `.adaptive` willl lead to the same behavior as
    /// `.visible` . The logo view will be visible when the map view is visible.
    public var logo = BaseOrnamentOptions(position: .bottomLeft)

    // MARK: - Attribution Button

    /// Used to configure position, margin, and visibility for the map's attribution button.
    /// The default position for the attribution button is `.bottomRight`.
    /// Setting visibility to `.adaptive` willl lead to the same behavior as
    /// `.visible` . The attribution will be visible when the map view is visible.
    public var attributionButton = BaseOrnamentOptions(position: .bottomRight)
}

public struct BaseOrnamentOptions: Equatable {
    public var position: OrnamentPosition
    /// The default value for this property is `CGPoint(x: 8.0, y: 8.0)`.
    public var margins: CGPoint = defaultOrnamentsMargin
    /// The default value for this property is `.adaptive`
    public var visibility: OrnamentVisibility = .adaptive
}
