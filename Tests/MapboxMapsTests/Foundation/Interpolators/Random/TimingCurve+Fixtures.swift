@testable import MapboxMaps

extension TimingCurve {
    static func testConstantValue() -> Self {
        return TimingCurve(p1: .testConstantValue(), p2: .testConstantValue())
    }
}
