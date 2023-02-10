@testable import MapboxMaps

extension TimingCurve {
    static func random() -> Self {
        return TimingCurve(p1: .random(), p2: .random())
    }
}
