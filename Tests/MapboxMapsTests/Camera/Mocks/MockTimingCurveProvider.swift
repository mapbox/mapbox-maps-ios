import UIKit

final class MockTimingCurveProvider: UITimingCurveProvider {

    var timingCurveType: UITimingCurveType = .cubic

    var cubicTimingParameters: UICubicTimingParameters?

    var springTimingParameters: UISpringTimingParameters?

    init() {
    }

    // MARK: - NSCoding

    init?(coder: NSCoder) {
    }

    func encode(with coder: NSCoder) {
    }

    // MARK: - NSCopying

    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}
