import MapboxCoreMaps

extension LayerPosition {
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
