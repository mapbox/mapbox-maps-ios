import Foundation
import XCTest
@testable import MapboxMaps

final class AnnotationManagerFactoryTests: XCTestCase {
    var style: MockStyle!
    var displayLinkCoordinator: MockDisplayLinkCoordinator!
    var offsetPointCalculator: OffsetPointCalculator!
    var offsetLineStringCalculator: OffsetLineStringCalculator!
    var offsetPolygonCalculator: OffsetPolygonCalculator!
    var factory: AnnotationManagerFactory!

    override func setUp() {
        super.setUp()

        style = MockStyle()
        displayLinkCoordinator = MockDisplayLinkCoordinator()
        offsetPointCalculator = OffsetPointCalculator(mapboxMap: MockMapboxMap())
        offsetLineStringCalculator = OffsetLineStringCalculator(mapboxMap: MockMapboxMap())
        offsetPolygonCalculator = OffsetPolygonCalculator(mapboxMap: MockMapboxMap())
        factory = AnnotationManagerFactory(
            style: style,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetPointCalculator: offsetPointCalculator,
            offsetPolygonCalculator: offsetPolygonCalculator,
            offsetLineStringCalculator: offsetLineStringCalculator)
    }

    override func tearDown() {
        super.tearDown()

        style = nil
        displayLinkCoordinator = nil
        offsetPointCalculator = nil
        offsetLineStringCalculator = nil
        offsetPolygonCalculator = nil
        factory = nil
    }

    // test return values for factory
    func testReturnedPointAnnotationManager() {
        let id = "managerId"
        let layerPosition: LayerPosition? = .random(.at(.random(in: 0...10)))
        let clusterOptions = ClusterOptions()

        //when
        let manager = factory.makePointAnnotationManager(id: id, layerPosition: layerPosition, clusterOptions: clusterOptions)

        //then
        XCTAssertTrue(manager is PointAnnotationManager)

    }

    func testReturnedPolygonAnnotationManager() {
        let id = "managerId"
        let layerPosition: LayerPosition? = .random(.at(.random(in: 0...10)))

        //when
        let manager = factory.makePolygonAnnotationManager(id: id, layerPosition: layerPosition)

        //then
        XCTAssertTrue(manager is PolygonAnnotationManager)

    }

    func testReturnedPolylineAnnotationManager() {
        let id = "managerId"
        let layerPosition: LayerPosition? = .random(.at(.random(in: 0...10)))

        //when
        let manager = factory.makePolylineAnnotationManager(id: id, layerPosition: layerPosition)

        //then
        XCTAssertTrue(manager is PolylineAnnotationManager)

    }

    func testReturnedCircleAnnotationManager() {
        //given
        let id = "managerId"
        let layerPosition: LayerPosition? = .random(.at(.random(in: 0...10)))

        //when
        let manager = factory.makeCircleAnnotationManager(id: id, layerPosition: layerPosition)

        //then
        XCTAssertTrue(manager is CircleAnnotationManager)

    }

}
