import XCTest
@testable import MapboxMaps

internal final class MockAnnotationManager: AnnotationManagerInternal {

    @Stubbed var id: String = ""

    @Stubbed var sourceId: String = ""

    @Stubbed var layerId: String = ""

    @Stubbed var allLayerIds: [String] = []

    let destroyStub = Stub<Void, Void>()
    func destroy() {
        destroyStub.call()
    }

    struct GestureParams {
        var featureId: String
        var context: MapContentGestureContext
    }

    let handleTapStub = Stub<GestureParams, Bool>(defaultReturnValue: false)
    func handleTap(with featureId: String, context: MapContentGestureContext) -> Bool {
        handleTapStub.call(with: GestureParams(featureId: featureId, context: context))
    }

    let handleLongPressStub = Stub<GestureParams, Bool>(defaultReturnValue: false)
    func handleLongPress(with featureId: String, context: MapContentGestureContext) -> Bool {
        handleLongPressStub.call(with: GestureParams(featureId: featureId, context: context))
    }

    let handleDragBeginStub = Stub<GestureParams, Bool>(defaultReturnValue: false)
    func handleDragBegin(with featureId: String, context: MapContentGestureContext) -> Bool {
        handleDragBeginStub.call(with: GestureParams(featureId: featureId, context: context))
    }

    let handleDragChangedStub = Stub<CGPoint, Void>()
    func handleDragChanged(with translation: CGPoint) {
        handleDragChangedStub.call(with: translation)
    }

    let handleDragEndedStub = Stub<Void, Void>()
    func handleDragEnded() {
        handleDragEndedStub.call()
    }
}
