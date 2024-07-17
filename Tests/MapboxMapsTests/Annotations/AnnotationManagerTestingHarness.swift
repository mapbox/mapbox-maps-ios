@testable import MapboxMaps

class AnnotationManagerTestingHarness {
    let style = MockStyle()
    let map = MockMapboxMap()
    let mapFeatureQueryable = MockMapFeatureQueryable()
    let imagesManager = MockAnnotationImagesManager()
    let id = UUID().uuidString
    @TestSignal
    var displayLink: Signal<Void>

    func makeDeps() -> AnnotationManagerDeps {
        AnnotationManagerDeps(
            map: map,
            style: style,
            queryable: mapFeatureQueryable,
            imagesManager: imagesManager,
            displayLink: displayLink)
    }

    func makeParams() -> AnnotationManagerParams {
        AnnotationManagerParams(id: id, layerPosition: nil, clusterOptions: nil)
    }

    func triggerDisplayLink() {
        $displayLink.send()
    }
}
