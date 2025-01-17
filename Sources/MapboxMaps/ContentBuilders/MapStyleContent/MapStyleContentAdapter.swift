///The adapter allows representing any instance of ``MapStyleContent`` as ``MapContent``.

protocol AdaptingMapContent: PrimitiveMapContent {}

struct MapStyleContentAdapter<S: MapStyleContent>: MapContent, AdaptingMapContent {
    private let subject: S

    init(_ subject: S) {
        self.subject = subject
    }

    func visit(_ node: MapContentNode) {
        if let primitive = subject as? PrimitiveMapContent {
            node.update(with: primitive)
        } else {
            node.update(newContent: subject) { nextNode in
                MapStyleContentAdapter<S.Body>(subject.body).visit(nextNode)
            }
        }
    }
}
