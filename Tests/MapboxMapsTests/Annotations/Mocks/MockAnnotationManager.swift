import XCTest
@testable import MapboxMaps

internal final class MockAnnotationManager: AnnotationManagerImplProtocol {

    @Stubbed var id: String = ""

    @Stubbed var allLayerIds: [String] = []

    let destroyStub = Stub<Void, Void>()
    func destroy() {
        destroyStub()
    }

    struct GestureParams {
        var layerId: String
        var feature: Feature
        var context: InteractionContext
    }

    let handleTapStub = Stub<GestureParams, Bool>(defaultReturnValue: false)
    func handleTap(layerId: String, feature: Feature, context: InteractionContext) -> Bool {
        handleTapStub(with: GestureParams(layerId: layerId, feature: feature, context: context))
    }

    let handleLongPressStub = Stub<GestureParams, Bool>(defaultReturnValue: false)
    func handleLongPress(layerId: String, feature: Feature, context: InteractionContext) -> Bool {
        handleLongPressStub(with: GestureParams(layerId: layerId, feature: feature, context: context))
    }

    struct DragGestureParams {
        var featureId: String
        var context: InteractionContext
    }

    let handleDragBeginStub = Stub<DragGestureParams, Bool>(defaultReturnValue: false)
    func handleDragBegin(with featureId: String, context: InteractionContext) -> Bool {
        handleDragBeginStub(with: DragGestureParams(featureId: featureId, context: context))
    }

    struct DragParams {
        var translation: CGPoint
        var context: InteractionContext
    }
    let handleDragChangeStub = Stub<DragParams, Void>()
    func handleDragChange(with translation: CGPoint, context: InteractionContext) {
        handleDragChangeStub(with: DragParams(translation: translation, context: context))
    }

    let handleDragEndStub = Stub<InteractionContext, Void>()
    func handleDragEnd(context: InteractionContext) {
        handleDragEndStub.call(with: context)
    }
}
