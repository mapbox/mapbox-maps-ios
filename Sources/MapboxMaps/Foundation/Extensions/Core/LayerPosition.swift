import MapboxCoreMaps

/// Specifies the position at which a layer will be added when using `Style.addLayer`.
public enum LayerPosition: Equatable, Codable, Sendable {
    /// Default behavior; add to the top of the layers stack.
    case `default`

    /// Layer should be positioned above the specified layer id.
    case above(String)

    /// Layer should be positioned below the specified layer id.
    case below(String)

    /// Layer should be positioned at the specified index in the layers stack.
    case at(Int)

    internal var corePosition: CoreLayerPosition {
        switch self {
        case .default:
            return CoreLayerPosition()
        case .above(let layerId):
            return CoreLayerPosition(above: layerId)
        case .below(let layerId):
            return CoreLayerPosition(below: layerId)
        case .at(let index):
            return CoreLayerPosition(at: index)
        }
    }
}

// MARK: - CoreLayerPosition conveniences

extension CoreLayerPosition {

    internal convenience init(above: String? = nil, below: String? = nil, at: Int? = nil) {
        self.init(__above: above, below: below, at: at?.NSNumber)
    }

    /// Layer should be positioned at a specified index in the layers stack
    internal var at: UInt32? {
        return __at?.uint32Value
    }
}
