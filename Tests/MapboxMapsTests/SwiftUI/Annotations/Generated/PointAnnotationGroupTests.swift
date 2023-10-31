// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

@available(iOS 13.0, *)
final class PointAnnotationGroupTests: XCTestCase {

    var mockAnnotationOrchestratorImpl: MockAnnotationOrchestatorImpl!
    var annotationOrchestrator: AnnotationOrchestrator!
    var visitor: DefaultMapContentVisitor!

    override func setUp() {
        super.setUp()

        self.visitor = DefaultMapContentVisitor()
        mockAnnotationOrchestratorImpl = MockAnnotationOrchestatorImpl()
        annotationOrchestrator = AnnotationOrchestrator(impl: mockAnnotationOrchestratorImpl)
    }

    override func tearDown() {
        visitor = nil
        mockAnnotationOrchestratorImpl = nil
        super.tearDown()
    }

    func testNewAnnotationManager() throws {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let layerId = "layer-id"
        let group = PointAnnotationGroup {
            PointAnnotation(coordinate: coordinate)
        }
        .layerId(layerId)

        var annotationIds: [AnyHashable: String] = [:]

        // When
        visitor.visit(id: "any-id", content: group)
        let addedGroup = try XCTUnwrap(visitor.annotationGroups.first)
        XCTAssertEqual(addedGroup.0, ["any-id"])
        XCTAssertEqual(addedGroup.1.layerId, layerId)
        addedGroup.1.update(annotationOrchestrator, layerId, &annotationIds)

        // Then
        let stubbed = mockAnnotationOrchestratorImpl.makePointAnnotationManagerStub.invocations[0]
        let manager = try XCTUnwrap(stubbed.returnValue as? PointAnnotationManager)
        XCTAssertEqual(stubbed.parameters.id, layerId)
        XCTAssertEqual(manager.annotations.count, 1)

        let annotation = try XCTUnwrap(manager.annotations.first)
        let annotationId = try XCTUnwrap(annotationIds[0])
        XCTAssertEqual(annotation.id, annotationId)
    }
}
// End generated file
