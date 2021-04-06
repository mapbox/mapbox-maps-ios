import UIKit

private let defaultOrnamentsMargin = CGPoint(x: 8.0, y: 8.0)

/// Used to configure Ornament-specific capabilities of the map
public struct OrnamentOptions: Equatable {

    /// Scale Bar options
    public var showsScale: Bool = true
    public var scaleBarPosition: OrnamentPosition = .topLeft
    public var scaleBarMargins: CGPoint = defaultOrnamentsMargin

    /// Compass options
    public var showsCompass: Bool = true
    public var compassViewPosition: OrnamentPosition = .topRight
    public var compassViewMargins: CGPoint = defaultOrnamentsMargin
    public var compassVisiblity: OrnamentVisibility = .adaptive

    /// Logo view options
    public private(set) var showsLogoView: Bool = true
    public var logoViewPosition: OrnamentPosition = .bottomLeft
    public var logoViewMargins: CGPoint = defaultOrnamentsMargin

    /// Attribution options
    public private(set) var showsAttributionButton: Bool = true
    public var attributionButtonPosition: OrnamentPosition = .bottomRight
    public var attributionButtonMargins: CGPoint = defaultOrnamentsMargin

    /// Used to generate the internal `OrnamentConfig` used by the `OrnamentsManager` to configure the map.
    internal func makeConfig() -> OrnamentConfig {

        var supportedOrnaments: [OrnamentType: OrnamentPosition] = [:]
        var supportedOrnamentMargins: [OrnamentType: OrnamentMargins] = [:]
        var ornamentVisibility: [OrnamentType: OrnamentVisibility] = [:]

        if showsScale {
            supportedOrnaments[.mapboxScaleBar] = scaleBarPosition
            supportedOrnamentMargins[.mapboxScaleBar] = scaleBarMargins
        }

        if showsCompass {
            supportedOrnaments[.compass] = compassViewPosition
            supportedOrnamentMargins[.compass] = compassViewMargins
            ornamentVisibility[.compass] = compassVisiblity
        }

        if showsLogoView {
            supportedOrnaments[.mapboxLogoView] = logoViewPosition
            supportedOrnamentMargins[.mapboxLogoView] = logoViewMargins
        }

        if showsAttributionButton {
            supportedOrnaments[.infoButton] = attributionButtonPosition
            supportedOrnamentMargins[.infoButton] = attributionButtonMargins
        }

        return OrnamentConfig(ornamentPositions: supportedOrnaments,
                              ornamentMargins: supportedOrnamentMargins, ornamentVisibility: ornamentVisibility)
    }
}
