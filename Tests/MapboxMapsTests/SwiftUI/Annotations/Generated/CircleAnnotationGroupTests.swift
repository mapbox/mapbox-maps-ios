// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

@available(iOS 13.0, *)
final class CircleAnnotationGroupTests: XCTestCase {

    var orchestratorImpl: MockAnnotationOrchestatorImpl!
    var orchestrator: AnnotationOrchestrator!
    var visitor: DefaultMapContentVisitor!

    override func setUp() {
        super.setUp()

        self.visitor = DefaultMapContentVisitor()
        orchestratorImpl = MockAnnotationOrchestatorImpl()
        orchestrator = AnnotationOrchestrator(impl: orchestratorImpl)
    }

    override func tearDown() {
        visitor = nil
        orchestratorImpl = nil
        orchestrator = nil
        super.tearDown()
    }

    func testNewAnnotationManager() throws {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let layerId = "layer-id"
        let slot = "bottom"
        let group = CircleAnnotationGroup {
            CircleAnnotation(centerCoordinate: coordinate)
        }
        .layerId(layerId)
        .slot(slot)

        var annotationIds: [AnyHashable: String] = [:]

        // When
        visitor.visit(id: "any-id", content: group)
        let addedGroup = try XCTUnwrap(visitor.annotationGroups.first)
        XCTAssertEqual(addedGroup.positionalId, ["any-id"])
        XCTAssertEqual(addedGroup.layerId, layerId)
        addedGroup.update(orchestrator, layerId, &annotationIds)

        // Then
        let stubbed = orchestratorImpl.makeCircleAnnotationManagerStub.invocations[0]
        let manager = try XCTUnwrap(stubbed.returnValue as? CircleAnnotationManager)
        XCTAssertEqual(stubbed.parameters.id, layerId)
        XCTAssertEqual(manager.annotations.count, 1)
        XCTAssertEqual(manager.slot, slot)

        let annotation = try XCTUnwrap(manager.annotations.first)
        let annotationId = try XCTUnwrap(annotationIds[0])
        XCTAssertEqual(annotation.id, annotationId)
    }
}
// End generated file
