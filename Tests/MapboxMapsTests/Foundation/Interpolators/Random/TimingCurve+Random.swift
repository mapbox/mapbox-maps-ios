@testable import MapboxMaps

extension TimingCurve {
    static func random() -> Self {
        return TimingCurve(p1: .testConstantValue(), p2: .testConstantValue())
    }
}
