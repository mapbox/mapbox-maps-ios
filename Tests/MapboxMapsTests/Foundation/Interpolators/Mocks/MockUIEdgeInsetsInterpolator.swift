@testable import MapboxMaps
import UIKit

final class MockUIEdgeInsetsInterpolator: UIEdgeInsetsInterpolatorProtocol {
    struct InterpolateParams {
        var from: UIEdgeInsets
        var to: UIEdgeInsets
        var fraction: Double
    }
    let interpolateStub = Stub<InterpolateParams, UIEdgeInsets>(defaultReturnValue: .random())
    func interpolate(from: UIEdgeInsets,
                     to: UIEdgeInsets,
                     fraction: Double) -> UIEdgeInsets {
        interpolateStub.call(with: .init(
            from: from,
            to: to,
            fraction: fraction))
    }
}
