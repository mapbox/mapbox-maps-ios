import XCTest
@_spi(Experimental) @testable import MapboxMaps

@available(iOS 13.0, *)
final class LayerAnnotationCoordinatorTests: XCTestCase {

    func testUpdate() {
        let mockAnnotationOrchestratorImpl = MockAnnotationOrchestatorImpl()
        let annotationOrchestrator = AnnotationOrchestrator(impl: mockAnnotationOrchestratorImpl)
        let sut = LayerAnnotationCoordinator(annotationOrchestrator: annotationOrchestrator)

        var group1Id: String?
        let annotationGroup1 = AnnotationGroup(
            positionalId: 0,
            layerId: "layer",
            update: { orchestrator, groupId, _ in
                XCTAssertIdentical(orchestrator, annotationOrchestrator)
                group1Id = groupId
            }
        )

        sut.update(annotations: [annotationGroup1])
        XCTAssertNotNil(group1Id)

        let annotationGroup2 =  AnnotationGroup(positionalId: 0, layerId: "layer") { orchestrator, groupId, _ in
            XCTAssertIdentical(orchestrator, annotationOrchestrator)
            XCTAssertEqual(groupId, group1Id, "Update with previously registered annotation group")
        }
        sut.update(annotations: [annotationGroup2])

        sut.update(annotations: [])
        XCTAssertEqual(mockAnnotationOrchestratorImpl.removeAnnotationManagerStub.invocations.last?.parameters, group1Id)
    }
}
