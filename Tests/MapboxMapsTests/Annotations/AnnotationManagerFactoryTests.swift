import Foundation
import XCTest
@testable import MapboxMaps

final class AnnotationManagerFactoryTests: XCTestCase {
    var style: MockStyle!
    var offsetPointCalculator: OffsetPointCalculator!
    var offsetLineStringCalculator: OffsetLineStringCalculator!
    var offsetPolygonCalculator: OffsetPolygonCalculator!
    var mapFeatureQueryable: MapFeatureQueryable!
    var factory: AnnotationManagerFactory!
    @TestSignal var displayLink: Signal<Void>

    override func setUp() {
        super.setUp()

        style = MockStyle()
        offsetPointCalculator = OffsetPointCalculator(mapboxMap: MockMapboxMap())
        offsetLineStringCalculator = OffsetLineStringCalculator(mapboxMap: MockMapboxMap())
        offsetPolygonCalculator = OffsetPolygonCalculator(mapboxMap: MockMapboxMap())
        mapFeatureQueryable = MockMapFeatureQueryable()
        factory = AnnotationManagerFactory(
            style: style,
            displayLink: displayLink,
            offsetPointCalculator: offsetPointCalculator,
            offsetPolygonCalculator: offsetPolygonCalculator,
            offsetLineStringCalculator: offsetLineStringCalculator,
            mapFeatureQueryable: mapFeatureQueryable)
    }

    override func tearDown() {
        super.tearDown()

        style = nil
        offsetPointCalculator = nil
        offsetLineStringCalculator = nil
        offsetPolygonCalculator = nil
        mapFeatureQueryable = nil
        factory = nil
    }

    // test return values for factory
    func testReturnedPointAnnotationManager() {
        let id = "managerId"
        let layerPosition: LayerPosition = .at(50)
        let clusterOptions = ClusterOptions()

        //when
        let manager = factory.makePointAnnotationManager(id: id, layerPosition: layerPosition, clusterOptions: clusterOptions)

        //then
        XCTAssertTrue(manager is PointAnnotationManager)

    }

    func testReturnedPolygonAnnotationManager() {
        let id = "managerId"
        let layerPosition: LayerPosition? = .at(81)

        //when
        let manager = factory.makePolygonAnnotationManager(id: id, layerPosition: layerPosition)

        //then
        XCTAssertTrue(manager is PolygonAnnotationManager)

    }

    func testReturnedPolylineAnnotationManager() {
        let id = "managerId"
        let layerPosition: LayerPosition? = .at(56)

        //when
        let manager = factory.makePolylineAnnotationManager(id: id, layerPosition: layerPosition)

        //then
        XCTAssertTrue(manager is PolylineAnnotationManager)

    }

    func testReturnedCircleAnnotationManager() {
        //given
        let id = "managerId"
        let layerPosition: LayerPosition? = .at(18)

        //when
        let manager = factory.makeCircleAnnotationManager(id: id, layerPosition: layerPosition)

        //then
        XCTAssertTrue(manager is CircleAnnotationManager)

    }

}
