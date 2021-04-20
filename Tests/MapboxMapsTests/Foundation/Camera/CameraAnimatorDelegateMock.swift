import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsFoundation
#endif

final class CameraAnimatorDelegateMock: CameraAnimatorDelegate {

    struct SchedulePendingCompletionParameters {
        var animator: CameraAnimator
        var completion: AnimationCompletion
        var animatingPosition: UIViewAnimatingPosition
    }

    let schedulePendingCompletionStub = Stub<SchedulePendingCompletionParameters, Void>()

    public func schedulePendingCompletion(forAnimator animator: CameraAnimator,
                                          completion: @escaping AnimationCompletion,
                                          animatingPosition: UIViewAnimatingPosition) {
        schedulePendingCompletionStub.call(with: SchedulePendingCompletionParameters(animator: animator,
                                                                                     completion: completion,
                                                                                     animatingPosition: animatingPosition))
    }

    let animatorFinishedStub = Stub<CameraAnimator, Void>()
    public func animatorIsFinished(forAnimator animator: CameraAnimator) {
        animatorFinishedStub.call(with: animator)
    }
    
    var camera: CameraOptions {
        return CameraOptions(center: .init(latitude: 10, longitude: 10),
                             padding: .init(top: 10, left: 10, bottom: 10, right: 10),
                             zoom: 10,
                             bearing: 10,
                             pitch: 20)
    }

    let jumpToStub = Stub<CameraOptions, Void>()
    func jumpTo(camera: CameraOptions) {
        jumpToStub.call(with: camera)
    }

    let addViewToViewHeirarchyStub = Stub<CameraView, Void>()
    func addViewToViewHeirarchy(_ view: CameraView) {
        addViewToViewHeirarchyStub.call(with: view)
    }
    
    let anchorAfterPaddingStub = Stub<Void, CGPoint>(defaultReturnValue: .zero)
    func anchorAfterPadding() -> CGPoint  {
        return anchorAfterPaddingStub.call()
    }
}
