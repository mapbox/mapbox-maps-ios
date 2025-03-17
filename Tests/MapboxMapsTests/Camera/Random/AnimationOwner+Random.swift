import MapboxMaps

extension AnimationOwner {
    static func testConstantValue() -> Self {
        return AnimationOwner(rawValue: .testConstantASCII(withLength: 10))
    }
}
