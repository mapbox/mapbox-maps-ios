import UIKit

private let defaultOrnamentsMargin = CGPoint(x: 8.0, y: 8.0)

/// Used to configure Ornament-specific capabilities of the map
public struct OrnamentOptions: Equatable {

    // MARK: - Scale Bar

    public var scaleBarPosition: OrnamentPosition = .topLeft
    public var scaleBarMargins: CGPoint = defaultOrnamentsMargin
    public var scaleBarVisibility: OrnamentVisibility = .adaptive

    // MARK: - Compass

    public var compassViewPosition: OrnamentPosition = .topRight
    public var compassViewMargins: CGPoint = defaultOrnamentsMargin
    public var compassVisibility: OrnamentVisibility = .adaptive

    // MARK: - Logo View

    /**
     Per our terms of service, a Mapbox map is required to display both
     a Mapbox logo as well as an information icon that contains attribution
     information. See https://docs.mapbox.com/help/how-mapbox-works/attribution/
     for details.
     */

    public var _logoViewIsVisible: Bool = true
    public var logoViewPosition: OrnamentPosition = .bottomLeft
    public var logoViewMargins: CGPoint = defaultOrnamentsMargin
    public var telemetryOptOutShownInApp: Bool = false

    // MARK: - Attribution Button

    public var _attributionButtonIsVisible: Bool = true
    public var attributionButtonPosition: OrnamentPosition = .bottomRight
    public var attributionButtonMargins: CGPoint = defaultOrnamentsMargin

    // MARK: - Validation

    /// `true` if there is at most one non-hidden ornament in each position; `false` otherwise.
    internal var isValid: Bool {
        let positions = [
            scaleBarVisibility != .hidden ? scaleBarPosition : nil,
            compassVisibility != .hidden ? compassViewPosition : nil,
            _logoViewIsVisible ? logoViewPosition : nil,
            _attributionButtonIsVisible ? attributionButtonPosition : nil].compactMap { $0 }
        return Set(positions).count == positions.count
    }
}
