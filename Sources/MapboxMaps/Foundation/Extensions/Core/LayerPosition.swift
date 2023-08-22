import MapboxCoreMaps

/// Specifies the position at which a layer will be added when using
/// `Style.addLayer`.
public enum LayerPosition: Equatable {
    /// Default behavior; add to the top of the layers stack.
    case `default`

    /// Layer should be positioned above the specified layer id.
    case above(String)

    /// Layer should be positioned below the specified layer id.
    case below(String)

    /// Layer should be positioned at the specified index in the layers stack.
    case at(Int)

    internal var corePosition: MapboxCoreMaps.LayerPosition {
        switch self {
        case .default:
            return MapboxCoreMaps.LayerPosition()
        case .above(let layerId):
            return MapboxCoreMaps.LayerPosition(above: layerId)
        case .below(let layerId):
            return MapboxCoreMaps.LayerPosition(below: layerId)
        case .at(let index):
            return MapboxCoreMaps.LayerPosition(at: index)
        }
    }
}

// MARK: - MapboxCoreMaps.LayerPosition conveniences

extension MapboxCoreMaps.LayerPosition {

    internal convenience init(above: String? = nil, below: String? = nil, at: Int? = nil) {
        self.init(__above: above, below: below, at: at?.NSNumber)
    }

    /// Layer should be positioned at a specified index in the layers stack
    internal var at: UInt32? {
        return __at?.uint32Value
    }
}
