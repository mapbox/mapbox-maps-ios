import Foundation
import XCTest
@testable import MapboxMaps

final class AnnotationOrchestratorTests: XCTestCase {
    var annotationOrchestrator: AnnotationOrchestrator!
    var mockOrchestrator = MockAnnotationOrchestatorImpl()

    override func setUp() {
        super.setUp()

        annotationOrchestrator = AnnotationOrchestrator(impl: mockOrchestrator)
    }

    override func tearDown() {
        super.tearDown()

        annotationOrchestrator = nil
    }

    func testPointAnnotationnManagerInit() {
        //given
        let id = "managerId"
        let layerPosition: LayerPosition? = .random(.at(.random(in: 0...10)))
        let clusterOptions: ClusterOptions? = .random(.init())

        //when
        _ = annotationOrchestrator.makePointAnnotationManager(id: id, layerPosition: layerPosition, clusterOptions: clusterOptions)

        //then
        XCTAssertEqual(mockOrchestrator.makePointAnnotationManagerStub.invocations.count, 1)
        let param = try! XCTUnwrap(mockOrchestrator.makePointAnnotationManagerStub.invocations.first?.parameters)
        XCTAssertEqual(param.id, id)
        XCTAssertEqual(param.layerPosition, layerPosition)
        XCTAssertEqual(param.clusterOptions, clusterOptions)
    }

    func testPolygonAnnotationManagerInit() {
        //given
        let id = "managerId"
        let layerPosition: LayerPosition? = .random(.at(.random(in: 0...10)))

        //when
        _ = annotationOrchestrator.makePolygonAnnotationManager(id: id, layerPosition: layerPosition) as AnnotationManagerInternal

        //then
        XCTAssertEqual(mockOrchestrator.makePolygonAnnotationManagerStub.invocations.count, 1)
        let param = try! XCTUnwrap(mockOrchestrator.makePolygonAnnotationManagerStub.invocations.first?.parameters)
        XCTAssertEqual(param.id, id)
        XCTAssertEqual(param.layerPosition, layerPosition)
    }

    func testPolylineAnnotationManagerInit() {
        //given
        let id = "managerId"
        let layerPosition: LayerPosition? = .random(.at(.random(in: 0...10)))

        //when
        _ = annotationOrchestrator.makePolylineAnnotationManager(id: id, layerPosition: layerPosition)

        //then
        XCTAssertEqual(mockOrchestrator.makePolylineAnnotationManagerStub.invocations.count, 1)
        let param = try! XCTUnwrap(mockOrchestrator.makePolylineAnnotationManagerStub.invocations.first?.parameters)
        XCTAssertEqual(param.id, id)
        XCTAssertEqual(param.layerPosition, layerPosition)
    }

    func testCircleAnnotationManagerInit() {
        //given
        let id = "managerId"
        let layerPosition: LayerPosition? = .random(.at(.random(in: 0...10)))

        //when
        _ = annotationOrchestrator.makeCircleAnnotationManager(id: id, layerPosition: layerPosition)

        //then
        XCTAssertEqual(mockOrchestrator.makeCircleAnnotationManagerStub.invocations.count, 1)

        let param = try! XCTUnwrap(mockOrchestrator.makeCircleAnnotationManagerStub.invocations.first?.parameters)
        XCTAssertEqual(param.id, id)
        XCTAssertEqual(param.layerPosition, layerPosition)
    }
}
