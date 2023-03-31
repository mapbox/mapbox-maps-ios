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

    let handlequeriedFeatureIdsStub = Stub<[String], Void>()
    func handleQueriedFeatureIds(_ queriedFeatureIds: [String]) {
        handlequeriedFeatureIdsStub.call(with: queriedFeatureIds)
    }

    let handleDragBeginStub = Stub<[String], Void>()
    func handleDragBegin(with featureIdentifiers: [String]) {
        handleDragBeginStub.call(with: featureIdentifiers)
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
