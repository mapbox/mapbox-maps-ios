// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

@available(iOS 13.0, *)
final class PointAnnotationGroupTests: XCTestCase {

    var mockAnnotationOrchestratorImpl: MockAnnotationOrchestatorImpl!
    var annotationOrchestrator: AnnotationOrchestrator!

    override func setUp() {
        super.setUp()

        mockAnnotationOrchestratorImpl = MockAnnotationOrchestatorImpl()
        annotationOrchestrator = AnnotationOrchestrator(impl: mockAnnotationOrchestratorImpl)
    }

    override func tearDown() {
        mockAnnotationOrchestratorImpl.makePointAnnotationManagerStub.reset()
        mockAnnotationOrchestratorImpl.annotationManagersById = [:]
        super.tearDown()
    }

    func testNewAnnotationManager() throws {
        // Given
        let group = PointAnnotationGroup((0...4), id: \.self) { _ in
            PointAnnotation(coordinate: .random())
        }

        // When
        let erased = group.eraseToAny([0])
        let annotationManagerId = UUID().uuidString
        var annotationIds: [AnyHashable: String] = [:]

        erased.update(annotationOrchestrator, annotationManagerId, &annotationIds)

        // Then
        let stubbed = mockAnnotationOrchestratorImpl.makePointAnnotationManagerStub.invocations[0]
        let createdAnnotationManager = try XCTUnwrap(stubbed.returnValue as? PointAnnotationManager)
        XCTAssertEqual(stubbed.parameters.id, annotationManagerId)
        XCTAssertEqual(createdAnnotationManager.annotations.count, group.data.count)
        XCTAssertTrue(try group.data.allSatisfy {
            let hash = [0, $0]
            let annotationId = try XCTUnwrap(annotationIds[hash])
            return createdAnnotationManager.annotations.contains(where: { $0.id == annotationId })
        })
    }

    func testUpdatingAnnotationManager() {
        let group = PointAnnotationGroup((0...4), id: \.self) { _ in
            PointAnnotation(coordinate: .random())
        }

        // When
        let existingAnnotationManager = mockAnnotationOrchestratorImpl.makePointAnnotationManagerStub.defaultReturnValue as! PointAnnotationManager
        XCTAssertTrue(existingAnnotationManager.annotations.isEmpty)

        let erased = group.eraseToAny([0])
        let annotationManagerId = UUID().uuidString
        var annotationIds: [AnyHashable: String] = [:]
        mockAnnotationOrchestratorImpl.annotationManagersById[annotationManagerId] = existingAnnotationManager
        erased.update(annotationOrchestrator, annotationManagerId, &annotationIds)

        // Then
        XCTAssertTrue(mockAnnotationOrchestratorImpl.makePointAnnotationManagerStub.invocations.isEmpty)

        XCTAssertEqual(existingAnnotationManager.annotations.count, group.data.count)
        XCTAssertTrue(try group.data.allSatisfy {
            let hash = [0, $0]
            let annotationId = try XCTUnwrap(annotationIds[hash])
            return existingAnnotationManager.annotations.contains(where: { $0.id == annotationId })
        })
    }

    func testOverrideExistingAnnotationManager() throws {
        // Given
        let group = PointAnnotationGroup((0...4), id: \.self) { _ in
            PointAnnotation(coordinate: .random())
        }

        // When
        let dummyAnnotationManager = DummyAnnotationManager()
        let annotationManagerId = UUID().uuidString
        mockAnnotationOrchestratorImpl.annotationManagersById[annotationManagerId] = dummyAnnotationManager
        var annotationIds: [AnyHashable: String] = [:]

        let erased = group.eraseToAny([0])
        erased.update(annotationOrchestrator, annotationManagerId, &annotationIds)

        // Then
        let stubbed = mockAnnotationOrchestratorImpl.makePointAnnotationManagerStub.invocations[0]
        let createdAnnotationManager = try XCTUnwrap(stubbed.returnValue as? PointAnnotationManager)
        XCTAssertEqual(stubbed.parameters.id, annotationManagerId)
        XCTAssertEqual(createdAnnotationManager.annotations.count, group.data.count)
        XCTAssertTrue(try group.data.allSatisfy {
            let hash = [0, $0]
            let annotationId = try XCTUnwrap(annotationIds[hash])
            return createdAnnotationManager.annotations.contains(where: { $0.id == annotationId })
        })
    }
}
// End generated file
