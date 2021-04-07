import MapboxCoreMaps

extension LayerPosition {

    /// Convenience initializer for LayerPosition
    /// - Parameters:
    ///   - above: Layer should be positioned above specified layer id
    ///   - below: Layer should be positioned below specified layer id
    ///   - at: Layer should be positioned at specified index in a layers stack
    public convenience init(above: String? = nil, below: String? = nil, at: Int? = nil) {
        self.init(__above: above, below: below, at: at?.NSNumber)
    }

    /// Layer should be positioned at a specified index in the layers stack
    public var at: UInt32? {
        return __at?.uint32Value
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? LayerPosition else {
            return false
        }

        return
            (above == object.above) &&
            (below == object.below) &&
            (at == object.at)
    }
}
