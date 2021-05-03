import UIKit

private let defaultOrnamentsMargin = CGPoint(x: 8.0, y: 8.0)

/// Used to configure Ornament-specific capabilities of the map
///
/// All margin values are relative to the MapView's safe area. To allow the safe area
/// (and thereby ornaments) to track the presence of navigation bars and tab bars,
/// make MapView the root view of a view controller.
public struct OrnamentOptions: Equatable {

    // MARK: - Scale Bar
    public var scaleBarOptions: CompassScaleBarOptions = CompassScaleBarOptions(position: .topLeft)

    // MARK: - Compass
    public var compassViewOptions: CompassScaleBarOptions = CompassScaleBarOptions(position: .topRight)
    // MARK: - Logo View

    /**
     Per our terms of service, a Mapbox map is required to display both
     a Mapbox logo as well as an information icon that contains attribution
     information. See https://docs.mapbox.com/help/how-mapbox-works/attribution/
     for details.
     */
    public var logoViewOptions: AttributionLogoViewOptions = AttributionLogoViewOptions(position: .bottomLeft)

    // MARK: - Attribution Button
    public var attributionButtonOptions: AttributionLogoViewOptions = AttributionLogoViewOptions(position: .bottomLeft)
}

public struct CompassScaleBarOptions: Equatable {
    public var position: OrnamentPosition
    public var margins: CGPoint = defaultOrnamentsMargin
    public var visibility: OrnamentVisibility = .adaptive
}

public struct AttributionLogoViewOptions: Equatable {
    public var position: OrnamentPosition
    public var margins: CGPoint = defaultOrnamentsMargin
    public var _isVisible: Bool = true
}
