// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

@available(iOS 13.0, *)
final class PolylineAnnotationGroupTests: XCTestCase {

    var mockAnnotationOrchestratorImpl: MockAnnotationOrchestatorImpl!
    var annotationOrchestrator: AnnotationOrchestrator!

    override func setUp() {
        super.setUp()

        mockAnnotationOrchestratorImpl = MockAnnotationOrchestatorImpl()
        annotationOrchestrator = AnnotationOrchestrator(impl: mockAnnotationOrchestratorImpl)
    }

    override func tearDown() {
        mockAnnotationOrchestratorImpl.makePolylineAnnotationManagerStub.reset()
        mockAnnotationOrchestratorImpl.annotationManagersById = [:]
        super.tearDown()
    }

    func testNewAnnotationManager() throws {
        // Given
        let group = PolylineAnnotationGroup((0...4), id: \.self) { _ in
            PolylineAnnotation(lineCoordinates: [CLLocationCoordinate2D(latitude: 0, longitude: 0), CLLocationCoordinate2D(latitude: 10, longitude: 10)])
        }

        // When
        let erased = group.eraseToAny([0])
        let annotationManagerId = UUID().uuidString
        var annotationIds: [AnyHashable: String] = [:]

        erased.update(annotationOrchestrator, annotationManagerId, &annotationIds)

        // Then
        let stubbed = mockAnnotationOrchestratorImpl.makePolylineAnnotationManagerStub.invocations[0]
        let createdAnnotationManager = try XCTUnwrap(stubbed.returnValue as? PolylineAnnotationManager)
        XCTAssertEqual(stubbed.parameters.id, annotationManagerId)
        XCTAssertEqual(createdAnnotationManager.annotations.count, group.data.count)
        XCTAssertTrue(try group.data.allSatisfy {
            let hash = [0, $0]
            let annotationId = try XCTUnwrap(annotationIds[hash])
            return createdAnnotationManager.annotations.contains(where: { $0.id == annotationId })
        })
    }

    func testUpdatingAnnotationManager() {
        let group = PolylineAnnotationGroup((0...4), id: \.self) { _ in
            PolylineAnnotation(lineCoordinates: [CLLocationCoordinate2D(latitude: 0, longitude: 0), CLLocationCoordinate2D(latitude: 10, longitude: 10)])
        }

        // When
        let existingAnnotationManager = mockAnnotationOrchestratorImpl.makePolylineAnnotationManagerStub.defaultReturnValue as! PolylineAnnotationManager
        XCTAssertTrue(existingAnnotationManager.annotations.isEmpty)

        let erased = group.eraseToAny([0])
        let annotationManagerId = UUID().uuidString
        var annotationIds: [AnyHashable: String] = [:]
        mockAnnotationOrchestratorImpl.annotationManagersById[annotationManagerId] = existingAnnotationManager
        erased.update(annotationOrchestrator, annotationManagerId, &annotationIds)

        // Then
        XCTAssertTrue(mockAnnotationOrchestratorImpl.makePolylineAnnotationManagerStub.invocations.isEmpty)

        XCTAssertEqual(existingAnnotationManager.annotations.count, group.data.count)
        XCTAssertTrue(try group.data.allSatisfy {
            let hash = [0, $0]
            let annotationId = try XCTUnwrap(annotationIds[hash])
            return existingAnnotationManager.annotations.contains(where: { $0.id == annotationId })
        })
    }

    func testOverrideExistingAnnotationManager() throws {
        // Given
        let group = PolylineAnnotationGroup((0...4), id: \.self) { _ in
            PolylineAnnotation(lineCoordinates: [CLLocationCoordinate2D(latitude: 0, longitude: 0), CLLocationCoordinate2D(latitude: 10, longitude: 10)])
        }

        // When
        let dummyAnnotationManager = DummyAnnotationManager()
        let annotationManagerId = UUID().uuidString
        mockAnnotationOrchestratorImpl.annotationManagersById[annotationManagerId] = dummyAnnotationManager
        var annotationIds: [AnyHashable: String] = [:]

        let erased = group.eraseToAny([0])
        erased.update(annotationOrchestrator, annotationManagerId, &annotationIds)

        // Then
        let stubbed = mockAnnotationOrchestratorImpl.makePolylineAnnotationManagerStub.invocations[0]
        let createdAnnotationManager = try XCTUnwrap(stubbed.returnValue as? PolylineAnnotationManager)
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
