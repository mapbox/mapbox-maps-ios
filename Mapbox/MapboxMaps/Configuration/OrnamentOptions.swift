import UIKit
import MapboxMapsOrnaments


private let defaultOrnamentsMargin = CGPoint(x: 8.0, y: 8.0)

/// Used to configure Ornament-specific capabilities of the map
public struct OrnamentOptions: Equatable {

    /// Scale Bar options
    public var showsScale: Bool = true
    public var scaleBarPosition: LayoutPosition = .topLeft
    public var scaleBarMargins: CGPoint = defaultOrnamentsMargin

    /// Compass options
    public var showsCompass: Bool = true
    public var compassViewPosition: LayoutPosition = .topRight
    public var compassViewMargins: CGPoint = defaultOrnamentsMargin
    public var compassVisiblity: LayoutVisibility = .adaptive

    /// Logo view options
    public private(set) var showsLogoView: Bool = true
    public var logoViewPosition: LayoutPosition = .bottomLeft
    public var logoViewMargins: CGPoint = defaultOrnamentsMargin

    /// Attribution options
    public private(set) var showsAttributionButton: Bool = true
    public var attributionButtonPosition: LayoutPosition = .bottomRight
    public var attributionButtonMargins: CGPoint = defaultOrnamentsMargin

    /// Used to generate the internal `OrnamentConfig` used by the `OrnamentsManager` to configure the map.
    internal func makeConfig() -> OrnamentConfig {

        var supportedOrnaments: [OrnamentType: OrnamentPosition] = [:]
        var supportedOrnamentMargins: [OrnamentType: OrnamentMargins] = [:]
        var ornamentVisibility: [OrnamentType: OrnamentVisibility] = [:]

        if showsScale {
            supportedOrnaments[.mapboxScaleBar] = scaleBarPosition.ornamentPosition
            supportedOrnamentMargins[.mapboxScaleBar] = scaleBarMargins
        }

        if showsCompass {
            supportedOrnaments[.compass] = compassViewPosition.ornamentPosition
            supportedOrnamentMargins[.compass] = compassViewMargins
            ornamentVisibility[.compass] = compassVisiblity.ornamentVisibility
        }

        if showsLogoView {
            supportedOrnaments[.mapboxLogoView] = logoViewPosition.ornamentPosition
            supportedOrnamentMargins[.mapboxLogoView] = logoViewMargins
        }

        if showsAttributionButton {
            supportedOrnaments[.infoButton] = attributionButtonPosition.ornamentPosition
            supportedOrnamentMargins[.infoButton] = attributionButtonMargins
        }

        return OrnamentConfig(ornamentPositions: supportedOrnaments,
                              ornamentMargins: supportedOrnamentMargins, ornamentVisibility: ornamentVisibility)
    }
}
