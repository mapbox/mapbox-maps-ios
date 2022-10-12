import Foundation
@testable import MapboxMaps

final class MockCoordinateBoundsAnimator: CoordinateBoundsAnimator {

    struct ShowCoordinateBoundsParameters {
        let coordinateBounds: CoordinateBounds
        let padding: UIEdgeInsets
        let pitch: CGFloat?
        let animationDuration: TimeInterval
    }

    let showCoordinateBoundsStub = Stub<ShowCoordinateBoundsParameters, Void>()
    func show(
        coordinateBounds: CoordinateBounds,
        padding: UIEdgeInsets,
        pitch: CGFloat?,
        animationDuration: TimeInterval
    ) {
        let parameters = ShowCoordinateBoundsParameters(
            coordinateBounds: coordinateBounds,
            padding: padding,
            pitch: pitch,
            animationDuration: animationDuration)
        showCoordinateBoundsStub.call(with: parameters)
    }
}
