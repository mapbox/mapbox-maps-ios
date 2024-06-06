import Foundation
import XCTest
@testable import MapboxMaps

final class AnnotationOrchestratorTests: XCTestCase {
    var annotationOrchestrator: AnnotationOrchestrator!
    var orchestratorImpl: MockAnnotationOrchestatorImpl!

    override func setUp() {
        super.setUp()

        orchestratorImpl = MockAnnotationOrchestatorImpl()
        annotationOrchestrator = AnnotationOrchestrator(impl: orchestratorImpl)
    }

    override func tearDown() {
        super.tearDown()

        orchestratorImpl = nil
        annotationOrchestrator = nil
    }

    func testPointAnnotationnManagerInit() throws {
        //given
        let id = "managerId"
        let layerPosition: LayerPosition? = .at(38)
        let clusterOptions: ClusterOptions? = .init()

        //when
        _ = annotationOrchestrator.makePointAnnotationManager(id: id, layerPosition: layerPosition, clusterOptions: clusterOptions)

        //then
        XCTAssertEqual(orchestratorImpl.makePointAnnotationManagerStub.invocations.count, 1)
        let param = try XCTUnwrap(orchestratorImpl.makePointAnnotationManagerStub.invocations.first?.parameters)
        XCTAssertEqual(param.id, id)
        XCTAssertEqual(param.layerPosition, layerPosition)
        XCTAssertEqual(param.clusterOptions, clusterOptions)
    }

    func testPolygonAnnotationManagerInit() throws {
        //given
        let id = "managerId"
        let layerPosition: LayerPosition? = .at(81)

        //when
        _ = annotationOrchestrator.makePolygonAnnotationManager(id: id, layerPosition: layerPosition) as AnnotationManagerInternal

        //then
        XCTAssertEqual(orchestratorImpl.makePolygonAnnotationManagerStub.invocations.count, 1)
        let param = try XCTUnwrap(orchestratorImpl.makePolygonAnnotationManagerStub.invocations.first?.parameters)
        XCTAssertEqual(param.id, id)
        XCTAssertEqual(param.layerPosition, layerPosition)
    }

    func testPolylineAnnotationManagerInit() throws {
        //given
        let id = "managerId"
        let layerPosition: LayerPosition? = .at(48)

        //when
        _ = annotationOrchestrator.makePolylineAnnotationManager(id: id, layerPosition: layerPosition)

        //then
        XCTAssertEqual(orchestratorImpl.makePolylineAnnotationManagerStub.invocations.count, 1)
        let param = try XCTUnwrap(orchestratorImpl.makePolylineAnnotationManagerStub.invocations.first?.parameters)
        XCTAssertEqual(param.id, id)
        XCTAssertEqual(param.layerPosition, layerPosition)
    }

    func testCircleAnnotationManagerInit() throws {
        //given
        let id = "managerId"
        let layerPosition: LayerPosition? = .at(91)

        //when
        _ = annotationOrchestrator.makeCircleAnnotationManager(id: id, layerPosition: layerPosition)

        //then
        XCTAssertEqual(orchestratorImpl.makeCircleAnnotationManagerStub.invocations.count, 1)

        let param = try XCTUnwrap(orchestratorImpl.makeCircleAnnotationManagerStub.invocations.first?.parameters)
        XCTAssertEqual(param.id, id)
        XCTAssertEqual(param.layerPosition, layerPosition)
    }
}
