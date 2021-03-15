import UIKit

public typealias OrnamentMargins = CGPoint

public class Ornament: Equatable {
    public var view: UIView?
    public let type: OrnamentType
    public let position: OrnamentPosition
    public let margins: OrnamentMargins
    public let visibility: OrnamentVisibility

    convenience internal init(view: UIView?,
                              type: OrnamentType,
                              position: OrnamentPosition,
                              visibility: OrnamentVisibility = .visible) {
        self.init(view: view, type: type, position: position, margins: .defaultMargins, visibility: visibility)
    }

    public init(view: UIView?,
                type: OrnamentType,
                position: OrnamentPosition,
                margins: OrnamentMargins,
                visibility: OrnamentVisibility) {
        self.view = view
        self.type = type
        self.position = position
        self.margins = margins
        self.visibility = visibility
    }

    public static func == (lhs: Ornament, rhs: Ornament) -> Bool {
        return lhs.type == rhs.type && lhs.position == rhs.position && lhs.margins == rhs.margins
    }
}

public struct OrnamentConfig: Equatable {
    internal let ornaments: [Ornament]

    /**
     Mapbox maps must provide a way to opt out of telemetry. Set this property to `true` when you implement a custom
     opt-out method.
     */
    internal let telemetryOptOutShownInApp: Bool

    internal init(ornamentPositions: [OrnamentType: OrnamentPosition],
                  ornamentMargins: [OrnamentType: OrnamentMargins],
                  ornamentVisibility: [OrnamentType: OrnamentVisibility], telemetryOptOutShownInApp: Bool = false) {
        assert(ornamentPositions.count == ornamentMargins.count)

        var ornaments = [Ornament]()

        for ornamentType in ornamentPositions.keys {
            guard
                let position = ornamentPositions[ornamentType]
            else { continue }

            let ornament = Ornament(view: nil,
                                    type: ornamentType,
                                    position: position,
                                    margins: ornamentMargins[ornamentType] ?? .defaultMargins,
                                    visibility: ornamentVisibility[ornamentType] ?? .visible)

            ornaments.append(ornament)
        }

        self.ornaments = ornaments
        self.telemetryOptOutShownInApp = telemetryOptOutShownInApp
    }

    internal init(ornaments: [Ornament], telemetryOptOutShownInApp: Bool = false) {
        self.ornaments = ornaments
        self.telemetryOptOutShownInApp = telemetryOptOutShownInApp
    }

    internal init() {
        ornaments = []
        telemetryOptOutShownInApp = false
    }

    internal func with(ornament: Ornament) -> OrnamentConfig {
        return union(with: OrnamentConfig(ornaments: [ornament]))
    }

    internal func without(ornament: Ornament) -> OrnamentConfig {
        return complement(with: OrnamentConfig(ornaments: [ornament]))
    }

    internal func intersection(with config: OrnamentConfig) -> OrnamentConfig {
        return OrnamentConfig(ornaments:
            ornaments.filter { ornament in config.ornaments.contains(ornament) }
        )
    }

    internal func union(with config: OrnamentConfig) -> OrnamentConfig {
        var ornaments = self.ornaments
        for ornament in config.ornaments {
            if !ornaments.contains(ornament) {
                ornaments.append(ornament)
            }
        }
        return OrnamentConfig(ornaments: ornaments)
    }

    internal func complement(with config: OrnamentConfig) -> OrnamentConfig {
        var ornaments = self.ornaments
        for ornament in config.ornaments {
            ornaments.removeAll { contained in
                contained == ornament
            }
        }
        return OrnamentConfig(ornaments: ornaments)
    }

    internal func symmetricDifference(with config: OrnamentConfig) -> OrnamentConfig {
        return union(with: config).complement(with: intersection(with: config))
    }

    internal func isValid() -> Bool {
        var positions = Set<OrnamentPosition>()
        for ornament in ornaments {
            if positions.contains(ornament.position) {
                return false
            }
            positions.insert(ornament.position)
        }
        return true
    }
}

extension OrnamentMargins {
    internal static var defaultMargins: OrnamentMargins {
        CGPoint(x: 8, y: 0)
    }
}
