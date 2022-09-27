import Foundation
import XCTest
@testable import MapboxMaps
import Turf

final class CircleAnnotationManagerTests: XCTestCase {

    var manager: CircleAnnotationManager!
    var style: MockStyle!
    var displayLinkCoordinator: MockDisplayLinkCoordinator!
    var id = UUID().uuidString
    var annotations = [CircleAnnotation]()

    override func setUp() {
        super.setUp()

        style = MockStyle()
        displayLinkCoordinator = MockDisplayLinkCoordinator()
        manager = CircleAnnotationManager(id: id,
                                          style: style,
                                          layerPosition: nil,
                                          displayLinkCoordinator: displayLinkCoordinator)

        for _ in 0...100 {
            var annotation = CircleAnnotation(centerCoordinate: .random())
            annotation.circleColor = StyleColor(.random())
            annotation.circleRadius = 12
            annotations.append(annotation)
        }
    }

    override func tearDown() {
        style = nil
        displayLinkCoordinator = nil
        manager = nil

        super.tearDown()
    }

    func testAddSource() {
        // when
        _ = CircleAnnotationManager(id: id,
                                 style: style,
                                 layerPosition: nil,
                                 displayLinkCoordinator: displayLinkCoordinator)

        // then
        XCTAssertEqual(style.addSourceStub.invocations.count, 2) // once for init in setUp and once here
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.source.type, SourceType.geoJson)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.id, manager.id)
    }

    func testAddLayer() {
        // when
        let initializedManager = CircleAnnotationManager(id: id,
                                                         style: style,
                                                         layerPosition: nil,
                                                         displayLinkCoordinator: displayLinkCoordinator)

        // then
        XCTAssertEqual(style.addSourceStub.invocations.count, 2) // once for init in setUp and once here
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.type, LayerType.circle)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.id, initializedManager.id)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.source, initializedManager.sourceId)
        XCTAssertNil(style.addPersistentLayerStub.invocations.last?.parameters.layerPosition)
    }

    func testAddManagerWithDuplicateId() {
        // given
        var annotations2 = [CircleAnnotation]()
        for _ in 0...50 {
            var annotation = CircleAnnotation(centerCoordinate: .random())
            annotation.circleColor = StyleColor(.random())
            annotation.circleRadius = 12
            annotations2.append(annotation)
        }

        // when
        manager.annotations = annotations
        let manager2 = CircleAnnotationManager(id: manager.id,
                                               style: style,
                                               layerPosition: nil,
                                               displayLinkCoordinator: displayLinkCoordinator)
        manager2.annotations = annotations2

        // then
        XCTAssertEqual(manager.annotations.count, 101)
        XCTAssertEqual(manager2.annotations.count, 51)
    }

    func testLayerPositionPassedCorrectly() {
        // when
        let manager3 = CircleAnnotationManager(id: id,
                                               style: style,
                                               layerPosition: LayerPosition.at(4),
                                               displayLinkCoordinator: displayLinkCoordinator)
        manager3.annotations = annotations

        // then
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layerPosition, LayerPosition.at(4))
    }

    func testDestroyManager() {
        // when
        manager.destroy()

        // then
        XCTAssertEqual(style.removeLayerStub.invocations.count, 1)
        XCTAssertEqual(style.removeLayerStub.invocations.last?.parameters, manager.id)
        XCTAssertEqual(style.removeSourceStub.invocations.count, 1)
        XCTAssertEqual(style.removeSourceStub.invocations.last?.parameters, manager.id)
    }

    func testDestroyManagerTwice() {
        // when
        manager.destroy()
        manager.destroy()

        // then
        XCTAssertEqual(style.removeLayerStub.invocations.count, 1)
        XCTAssertEqual(style.removeSourceStub.invocations.count, 1)
    }

    func testSyncSourceAndLayer() {
        // when
        manager.annotations = annotations
        manager.syncSourceAndLayerIfNeeded()

        // then
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
    }

    func testDoNotSyncSourceAndLayerWhenNotNeeded() {
        // when
        manager.syncSourceAndLayerIfNeeded()

        // then
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 0)
    }

    func testInitialCirclePitchAlignment() {
        // when
        let defaultValue = manager.circlePitchAlignment

        // then
        XCTAssertNil(defaultValue)
    }

    func testSetCirclePitchAlignment() {
        // when
        manager.circlePitchAlignment = CirclePitchAlignment(rawValue: "3")

        // then
        XCTAssertEqual(manager.circlePitchAlignment, CirclePitchAlignment(rawValue: "3"))
    }

    func testInitialCirclePitchScale() {
        // when
        let defaultValue = manager.circlePitchScale

        // then
        XCTAssertNil(defaultValue)
    }

    func testSetCirclePitchScale() {
        // when
        manager.circlePitchScale = CirclePitchScale(rawValue: "4")

        // then
        XCTAssertEqual(manager.circlePitchScale, CirclePitchScale(rawValue: "4"))
    }

    func testInitialCircleTranslate() {
        // when
        let defaultValue = manager.circleTranslate

        // then
        XCTAssertNil(defaultValue)
    }

    func testSetCircleTranslate() {
        // when
        manager.circleTranslate = [23.34, 234.5]

        // then
        XCTAssertEqual(manager.circleTranslate, [23.34, 234.5])
    }

    func testInitialCircleTranslateAnchor() {
        // when
        let defaultValue = manager.circleTranslateAnchor

        // then
        XCTAssertNil(defaultValue)
    }

    func testSetCircleTranslateAnchor() {
        // given
        let newCircleTranslateAnchorProperty = CircleTranslateAnchor(rawValue: "map")

        // when
        manager.circleTranslateAnchor = newCircleTranslateAnchorProperty

        // then
        XCTAssertEqual(manager.circleTranslateAnchor, CircleTranslateAnchor(rawValue: "map"))
    }

    func testManagerSubscribestoDisplayLinkCoordinator() {
        // then
        XCTAssertEqual(displayLinkCoordinator.addStub.invocations.count, 1)
        XCTAssertEqual(displayLinkCoordinator.removeStub.invocations.count, 0)
    }

    func testDestroyManagerRemovesDisplayLinkParticipant() {
        // when
        manager.destroy()

        // then
        XCTAssertEqual(displayLinkCoordinator.removeStub.invocations.count, 1)
    }

    func testSyncSourceAndLayerWhenNewPropertiesSet() {
        // when
        manager.circleTranslate = [23.34, 234.5]
        manager.syncSourceAndLayerIfNeeded()

        // then
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
    }

    func testAnnotationPropertiesAdded() {
        // given
        let newCircleTranslateProperty = [23.34, 234.5]

        // when
        manager.circleTranslate = newCircleTranslateProperty
        manager.syncSourceAndLayerIfNeeded()

        // then
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate"] as! [Double], newCircleTranslateProperty)
    }

    func testAnnotationPropertiesAddedWithoutDuplicate() {
        // given
        let newCircleTranslateProperty = [23.34, 234.5]
        let secondNewCircleTranslateProperty = [324.432, 324.432]

        // when
        manager.circleTranslate = newCircleTranslateProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.circleTranslate = secondNewCircleTranslateProperty
        manager.syncSourceAndLayerIfNeeded()

        // then
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate"] as! [Double], secondNewCircleTranslateProperty)
    }

    func testAnnotationPropertiesMergedWithManagersLayerProperties() {
        // given
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            var annotation = CircleAnnotation(centerCoordinate: CLLocationCoordinate2D(latitude: 38.9, longitude: -77.1))
            annotation.circleColor = StyleColor(UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0))
            annotation.circleRadius = 12
            annotations.append(annotation)
        }
        let newCircleTranslateProperty = [23.34, 234.5]

        // when
        manager.annotations = annotations
        manager.circleTranslate = newCircleTranslateProperty
        manager.syncSourceAndLayerIfNeeded()

        // then
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-color"])
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-radius"])
        XCTAssertNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-blur"])
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate"] as! [Double], newCircleTranslateProperty)
    }

    func testAnnotationPropertiesResetProperly() {
        // given
        let newCircleTranslateProperty = [23.34, 234.5]

        // when
        manager.circleTranslate = newCircleTranslateProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.circleTranslate = nil
        manager.syncSourceAndLayerIfNeeded()

        // then
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate"] as! [Double], [0, 0])
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
    }

    func testfeatureCollectionPassedtoGeoJSON() {
        // given
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            var annotation = CircleAnnotation(centerCoordinate: CLLocationCoordinate2D(latitude: 38.9, longitude: -77.1))
            annotation.circleColor = StyleColor(UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0))
            annotation.circleRadius = 12
            annotations.append(annotation)
        }
        let featureCollection = FeatureCollection(features: annotations.map(\.feature))

        // when
        manager.annotations = annotations
        manager.syncSourceAndLayerIfNeeded()

        // then
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.last?.parameters.id, manager.id)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.last?.parameters.geojson, .featureCollection(featureCollection))
    }
}
