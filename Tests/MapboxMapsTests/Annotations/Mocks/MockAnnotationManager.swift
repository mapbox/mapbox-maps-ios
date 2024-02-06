import XCTest
@testable import MapboxMaps

internal final class MockAnnotationManager: AnnotationManagerInternal {

    @Stubbed var id: String = ""

    @Stubbed var sourceId: String = ""

    @Stubbed var layerId: String = ""

    @Stubbed var allLayerIds: [String] = []

    @Stubbed var slot: String?

    let destroyStub = Stub<Void, Void>()
    func destroy() {
        destroyStub()
    }

    struct GestureParams {
        var layerId: String
        var feature: Feature
        var context: MapContentGestureContext
    }

    let handleTapStub = Stub<GestureParams, Bool>(defaultReturnValue: false)
    func handleTap(layerId: String, feature: Feature, context: MapContentGestureContext) -> Bool {
        handleTapStub(with: GestureParams(layerId: layerId, feature: feature, context: context))
    }

    let handleLongPressStub = Stub<GestureParams, Bool>(defaultReturnValue: false)
    func handleLongPress(layerId: String, feature: Feature, context: MapContentGestureContext) -> Bool {
        handleLongPressStub(with: GestureParams(layerId: layerId, feature: feature, context: context))
    }

    struct DragGestureParams {
        var featureId: String
        var context: MapContentGestureContext
    }

    let handleDragBeginStub = Stub<DragGestureParams, Bool>(defaultReturnValue: false)
    func handleDragBegin(with featureId: String, context: MapContentGestureContext) -> Bool {
        handleDragBeginStub(with: DragGestureParams(featureId: featureId, context: context))
    }

    struct DragParams {
        var translation: CGPoint
        var context: MapContentGestureContext
    }
    let handleDragChangeStub = Stub<DragParams, Void>()
    func handleDragChange(with translation: CGPoint, context: MapContentGestureContext) {
        handleDragChangeStub(with: DragParams(translation: translation, context: context))
    }

    let handleDragEndStub = Stub<MapContentGestureContext, Void>()
    func handleDragEnd(context: MapContentGestureContext) {
        handleDragEndStub.call(with: context)
    }
}
