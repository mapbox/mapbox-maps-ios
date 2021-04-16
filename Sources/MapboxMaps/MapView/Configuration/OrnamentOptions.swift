import UIKit

private let defaultOrnamentsMargin = CGPoint(x: 8.0, y: 8.0)

/// Used to configure Ornament-specific capabilities of the map
public struct OrnamentOptions: Equatable {

    /// Scale Bar options
    public var scaleBarPosition: OrnamentPosition = .topLeft
    public var scaleBarMargins: CGPoint = defaultOrnamentsMargin
    public var scaleBarVisibility: OrnamentVisibility = .adaptive

    /// Compass options
    public var compassViewPosition: OrnamentPosition = .topRight
    public var compassViewMargins: CGPoint = defaultOrnamentsMargin
    public var compassVisibility: OrnamentVisibility = .adaptive

    /// Logo view options
    public var _logoViewIsVisible: Bool = true
    public var logoViewPosition: OrnamentPosition = .bottomLeft
    public var logoViewMargins: CGPoint = defaultOrnamentsMargin

    /// Attribution options
    public var _attributionButtonIsVisible: Bool = true
    public var attributionButtonPosition: OrnamentPosition = .bottomRight
    public var attributionButtonMargins: CGPoint = defaultOrnamentsMargin

    /// Used to generate the internal `OrnamentConfig` used by the `OrnamentsManager` to configure the map.
    internal func makeConfig() -> OrnamentConfig {

        var supportedOrnaments: [OrnamentType: OrnamentPosition] = [:]
        var supportedOrnamentMargins: [OrnamentType: OrnamentMargins] = [:]
        var ornamentVisibility: [OrnamentType: OrnamentVisibility] = [:]

        if scaleBarVisibility != .hidden {
            supportedOrnaments[.mapboxScaleBar] = scaleBarPosition
            supportedOrnamentMargins[.mapboxScaleBar] = scaleBarMargins
        }

        if compassVisibility != .hidden {
            supportedOrnaments[.compass] = compassViewPosition
            supportedOrnamentMargins[.compass] = compassViewMargins
            ornamentVisibility[.compass] = compassVisibility
        }

        if _logoViewIsVisible {
            supportedOrnaments[.mapboxLogoView] = logoViewPosition
            supportedOrnamentMargins[.mapboxLogoView] = logoViewMargins
        }

        if _attributionButtonIsVisible {
            supportedOrnaments[.infoButton] = attributionButtonPosition
            supportedOrnamentMargins[.infoButton] = attributionButtonMargins
        }

        return OrnamentConfig(ornamentPositions: supportedOrnaments,
                              ornamentMargins: supportedOrnamentMargins, ornamentVisibility: ornamentVisibility)
    }
}
