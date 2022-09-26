import Foundation
import XCTest
@testable import MapboxMaps

final class CircleAnnotationManagerTests: XCTestCase {

    var manager: CircleAnnotationManager!
    var style: MockStyle!
    var displayLinkCoordinator: DisplayLinkCoordinator!
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
        manager.annotations = annotations

        // then
        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.source.type, SourceType.geoJson)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.id, manager.id)
    }

    func testAddLayer() {
        // when
        manager.annotations = annotations

        // then
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.type, LayerType.circle)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.id, manager.id)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.source, manager.sourceId)
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
        // when
        manager.circleTranslateAnchor = CircleTranslateAnchor(rawValue: "map")

        // then
        XCTAssertEqual(manager.circleTranslateAnchor, CircleTranslateAnchor(rawValue: "map"))
    }
}
