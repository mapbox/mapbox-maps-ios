import MapboxMaps

extension AnimationOwner {
    static func random() -> Self {
        return AnimationOwner(rawValue: .randomASCII(withLength: .random(in: 0...10)))
    }
}
