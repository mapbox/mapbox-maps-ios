import Foundation
import XCTest
@testable import MapboxMaps

final class AnnotationOrchestratorTests: XCTestCase {
    var tapGestureRecognizer: MockGestureRecognizer!
    var longPressGestureRecognizer: MockLongPressGestureRecognizer!
    var mapFeatureQueryable: MockMapFeatureQueryable!
    var style: MockStyle!
    var displayLinkCoordinator: MockDisplayLinkCoordinator!
    var offsetPointCalculator: OffsetPointCalculator!
    var offsetLineStringCalculator: OffsetLineStringCalculator!
    var offsetPolygonCalculator: OffsetPolygonCalculator!
    var factory: MockAnnotationManagerFactory!
    var impl: AnnotationOrchestratorImpl!
    var annotationOrchestrator: AnnotationOrchestrator!
    var mockOrchestrator = MockAnnotationOrchestatorImpl()

    override func setUp() {
        super.setUp()

        tapGestureRecognizer = MockGestureRecognizer()
        longPressGestureRecognizer = MockLongPressGestureRecognizer()
        mapFeatureQueryable = MockMapFeatureQueryable()
        style = MockStyle()
        displayLinkCoordinator = MockDisplayLinkCoordinator()
        offsetPointCalculator = OffsetPointCalculator(mapboxMap: MockMapboxMap())
        offsetLineStringCalculator = OffsetLineStringCalculator(mapboxMap: MockMapboxMap())
        offsetPolygonCalculator = OffsetPolygonCalculator(mapboxMap: MockMapboxMap())
        factory = MockAnnotationManagerFactory()
        impl = AnnotationOrchestratorImpl(
            tapGestureRecognizer: tapGestureRecognizer,
            longPressGestureRecognizer: longPressGestureRecognizer,
            mapFeatureQueryable: mapFeatureQueryable,
            factory: factory)
        annotationOrchestrator = AnnotationOrchestrator(impl: mockOrchestrator)
    }

    override func tearDown() {
        super.tearDown()

        tapGestureRecognizer = nil
        longPressGestureRecognizer = nil
        mapFeatureQueryable = nil
        style = nil
        displayLinkCoordinator = nil
        offsetPointCalculator = nil
        offsetLineStringCalculator = nil
        offsetPolygonCalculator = nil
        factory = nil
        impl = nil
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
