///The adapter allows representing any instance of ``MapStyleContent`` as ``MapContent``.

@available(iOS 13.0, *)
protocol AdaptingMapContent: PrimitiveMapContent {}

@available(iOS 13.0, *)
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
