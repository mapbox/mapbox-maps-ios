// This file is generated
import XCTest
@testable import MapboxMaps

final class PointAnnotationManagerTests: XCTestCase, AnnotationInteractionDelegate {
    var manager: PointAnnotationManager!
    var style: MockStyle!
    var displayLinkCoordinator: MockDisplayLinkCoordinator!
    var id = UUID().uuidString
    var annotations = [PointAnnotation]()
    var expectation: XCTestExpectation?
    var delegateAnnotations: [Annotation]?
    var offsetPointCalculator: OffsetPointCalculator!

    var mapboxMap = MockMapboxMap()

    override func setUp() {
        super.setUp()

        style = MockStyle()
        displayLinkCoordinator = MockDisplayLinkCoordinator()
        offsetPointCalculator = OffsetPointCalculator(mapboxMap: mapboxMap)
        manager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetPointCalculator: offsetPointCalculator
        )

        for _ in 0...10 {
            let annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotations.append(annotation)
        }
    }

    override func tearDown() {
        style = nil
        displayLinkCoordinator = nil
        manager = nil
        expectation = nil
        delegateAnnotations = nil

        super.tearDown()
    }

    func testSourceSetup() {
        style.addSourceStub.reset()

        _ = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetPointCalculator: offsetPointCalculator
        )

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.source.type, SourceType.geoJson)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.id, manager.id)
    }

    func testAddLayer() {
        style.addSourceStub.reset()
        let initializedManager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetPointCalculator: offsetPointCalculator
        )

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.type, LayerType.symbol)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.id, initializedManager.id)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.source, initializedManager.sourceId)
        XCTAssertNil(style.addPersistentLayerStub.invocations.last?.parameters.layerPosition)
    }

    func testAddManagerWithDuplicateId() {
        var annotations2 = [PointAnnotation]()
        for _ in 0...50 {
            let annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotations2.append(annotation)
        }

        manager.annotations = annotations
        let manager2 = PointAnnotationManager(
            id: manager.id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetPointCalculator: offsetPointCalculator
        )
        manager2.annotations = annotations2

        XCTAssertEqual(manager.annotations.count, 11)
        XCTAssertEqual(manager2.annotations.count, 51)
    }

    func testLayerPositionPassedCorrectly() {
        let manager3 = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: LayerPosition.at(4),
            displayLinkCoordinator: displayLinkCoordinator,
            offsetPointCalculator: offsetPointCalculator
        )
        manager3.annotations = annotations

        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layerPosition, LayerPosition.at(4))
    }

    func testDestroyManager() {
        manager.destroy()

        XCTAssertEqual(style.removeLayerStub.invocations.count, 1)
        XCTAssertEqual(style.removeLayerStub.invocations.last?.parameters, manager.id)
        XCTAssertEqual(style.removeSourceStub.invocations.count, 1)
        XCTAssertEqual(style.removeSourceStub.invocations.last?.parameters, manager.id)
    }

    func testDestroyManagerTwice() {
        manager.destroy()
        manager.destroy()

        XCTAssertEqual(style.removeLayerStub.invocations.count, 1)
        XCTAssertEqual(style.removeSourceStub.invocations.count, 1)
    }

    func testSyncSourceAndLayer() {
        manager.annotations = annotations
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
    }

    func testDoNotSyncSourceAndLayerWhenNotNeeded() {
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 0)
    }

    func testManagerSubscribestoDisplayLinkCoordinator() {
        XCTAssertEqual(displayLinkCoordinator.addStub.invocations.count, 1)
        XCTAssertEqual(displayLinkCoordinator.removeStub.invocations.count, 0)
    }

    func testDestroyManagerRemovesDisplayLinkParticipant() {
        manager.destroy()

        XCTAssertEqual(displayLinkCoordinator.removeStub.invocations.count, 1)
    }

    func testfeatureCollectionPassedtoGeoJSON() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            let annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotations.append(annotation)
        }
        let featureCollection = FeatureCollection(features: annotations.map(\.feature))

        manager.annotations = annotations
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.last?.parameters.id, manager.id)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.last?.parameters.geojson, .featureCollection(featureCollection))
    }

    func testHandleQueriedFeatureIdsPassesNotificationToDelegate() throws {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            let annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotations.append(annotation)
        }
        let queriedFeatureIds = [annotations[0].id]
        manager.delegate = self

        manager.annotations = annotations
        manager.handleQueriedFeatureIds(queriedFeatureIds)

        let result = try XCTUnwrap(delegateAnnotations)
        XCTAssertEqual(result[0].id, annotations[0].id)
    }

    func testHandleQueriedFeatureIdsDoesNotPassNotificationToDelegateWhenNoMatch() throws {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            let annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotations.append(annotation)
        }
        let queriedFeatureIds = ["NotAnAnnotationID"]
        manager.delegate = self

        expectation?.isInverted = true
        manager.annotations = annotations
        manager.handleQueriedFeatureIds(queriedFeatureIds)

        XCTAssertNil(delegateAnnotations)
    }

    func testInitialIconAllowOverlap() {
        let initialValue = manager.iconAllowOverlap
        XCTAssertNil(initialValue)
    }

    func testSetIconAllowOverlap() {
        let value = Bool.random()
        manager.iconAllowOverlap = value
        XCTAssertEqual(manager.iconAllowOverlap, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-allow-overlap"] as! Bool, value)
    }

    func testIconAllowOverlapAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconAllowOverlapProperty = Bool.random()
        let secondIconAllowOverlapProperty = Bool.random()

        manager.iconAllowOverlap = newIconAllowOverlapProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.iconAllowOverlap = secondIconAllowOverlapProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-allow-overlap"] as! Bool, secondIconAllowOverlapProperty)
    }

    func testNewIconAllowOverlapPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconAllowOverlapProperty = Bool.random()

        manager.annotations = annotations
        manager.iconAllowOverlap = newIconAllowOverlapProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-allow-overlap"])
    }

    func testSetToNilIconAllowOverlap() {
        let newIconAllowOverlapProperty = Bool.random()
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "icon-allow-overlap").value as! Bool
        manager.iconAllowOverlap = newIconAllowOverlapProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-allow-overlap"])

        manager.iconAllowOverlap = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.iconAllowOverlap)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-allow-overlap"] as! Bool, defaultValue)
    }

    func testInitialIconIgnorePlacement() {
        let initialValue = manager.iconIgnorePlacement
        XCTAssertNil(initialValue)
    }

    func testSetIconIgnorePlacement() {
        let value = Bool.random()
        manager.iconIgnorePlacement = value
        XCTAssertEqual(manager.iconIgnorePlacement, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-ignore-placement"] as! Bool, value)
    }

    func testIconIgnorePlacementAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconIgnorePlacementProperty = Bool.random()
        let secondIconIgnorePlacementProperty = Bool.random()

        manager.iconIgnorePlacement = newIconIgnorePlacementProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.iconIgnorePlacement = secondIconIgnorePlacementProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-ignore-placement"] as! Bool, secondIconIgnorePlacementProperty)
    }

    func testNewIconIgnorePlacementPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconIgnorePlacementProperty = Bool.random()

        manager.annotations = annotations
        manager.iconIgnorePlacement = newIconIgnorePlacementProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-ignore-placement"])
    }

    func testSetToNilIconIgnorePlacement() {
        let newIconIgnorePlacementProperty = Bool.random()
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "icon-ignore-placement").value as! Bool
        manager.iconIgnorePlacement = newIconIgnorePlacementProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-ignore-placement"])

        manager.iconIgnorePlacement = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.iconIgnorePlacement)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-ignore-placement"] as! Bool, defaultValue)
    }

    func testInitialIconKeepUpright() {
        let initialValue = manager.iconKeepUpright
        XCTAssertNil(initialValue)
    }

    func testSetIconKeepUpright() {
        let value = Bool.random()
        manager.iconKeepUpright = value
        XCTAssertEqual(manager.iconKeepUpright, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-keep-upright"] as! Bool, value)
    }

    func testIconKeepUprightAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconKeepUprightProperty = Bool.random()
        let secondIconKeepUprightProperty = Bool.random()

        manager.iconKeepUpright = newIconKeepUprightProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.iconKeepUpright = secondIconKeepUprightProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-keep-upright"] as! Bool, secondIconKeepUprightProperty)
    }

    func testNewIconKeepUprightPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconKeepUprightProperty = Bool.random()

        manager.annotations = annotations
        manager.iconKeepUpright = newIconKeepUprightProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-keep-upright"])
    }

    func testSetToNilIconKeepUpright() {
        let newIconKeepUprightProperty = Bool.random()
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "icon-keep-upright").value as! Bool
        manager.iconKeepUpright = newIconKeepUprightProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-keep-upright"])

        manager.iconKeepUpright = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.iconKeepUpright)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-keep-upright"] as! Bool, defaultValue)
    }

    func testInitialIconOptional() {
        let initialValue = manager.iconOptional
        XCTAssertNil(initialValue)
    }

    func testSetIconOptional() {
        let value = Bool.random()
        manager.iconOptional = value
        XCTAssertEqual(manager.iconOptional, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-optional"] as! Bool, value)
    }

    func testIconOptionalAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconOptionalProperty = Bool.random()
        let secondIconOptionalProperty = Bool.random()

        manager.iconOptional = newIconOptionalProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.iconOptional = secondIconOptionalProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-optional"] as! Bool, secondIconOptionalProperty)
    }

    func testNewIconOptionalPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconOptionalProperty = Bool.random()

        manager.annotations = annotations
        manager.iconOptional = newIconOptionalProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-optional"])
    }

    func testSetToNilIconOptional() {
        let newIconOptionalProperty = Bool.random()
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "icon-optional").value as! Bool
        manager.iconOptional = newIconOptionalProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-optional"])

        manager.iconOptional = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.iconOptional)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-optional"] as! Bool, defaultValue)
    }

    func testInitialIconPadding() {
        let initialValue = manager.iconPadding
        XCTAssertNil(initialValue)
    }

    func testSetIconPadding() {
        let value = Double.random(in: 0...100000)
        manager.iconPadding = value
        XCTAssertEqual(manager.iconPadding, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-padding"] as! Double, value)
    }

    func testIconPaddingAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconPaddingProperty = Double.random(in: 0...100000)
        let secondIconPaddingProperty = Double.random(in: 0...100000)

        manager.iconPadding = newIconPaddingProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.iconPadding = secondIconPaddingProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-padding"] as! Double, secondIconPaddingProperty)
    }

    func testNewIconPaddingPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconPaddingProperty = Double.random(in: 0...100000)

        manager.annotations = annotations
        manager.iconPadding = newIconPaddingProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-padding"])
    }

    func testSetToNilIconPadding() {
        let newIconPaddingProperty = Double.random(in: 0...100000)
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "icon-padding").value as! Double
        manager.iconPadding = newIconPaddingProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-padding"])

        manager.iconPadding = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.iconPadding)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-padding"] as! Double, defaultValue)
    }

    func testInitialIconPitchAlignment() {
        let initialValue = manager.iconPitchAlignment
        XCTAssertNil(initialValue)
    }

    func testSetIconPitchAlignment() {
        let value = IconPitchAlignment.allCases.randomElement()!
        manager.iconPitchAlignment = value
        XCTAssertEqual(manager.iconPitchAlignment, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-pitch-alignment"] as! String, value.rawValue)
    }

    func testIconPitchAlignmentAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconPitchAlignmentProperty = IconPitchAlignment.allCases.randomElement()!
        let secondIconPitchAlignmentProperty = IconPitchAlignment.allCases.randomElement()!

        manager.iconPitchAlignment = newIconPitchAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.iconPitchAlignment = secondIconPitchAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-pitch-alignment"] as! String, secondIconPitchAlignmentProperty.rawValue)
    }

    func testNewIconPitchAlignmentPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconPitchAlignmentProperty = IconPitchAlignment.allCases.randomElement()!

        manager.annotations = annotations
        manager.iconPitchAlignment = newIconPitchAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-pitch-alignment"])
    }

    func testSetToNilIconPitchAlignment() {
        let newIconPitchAlignmentProperty = IconPitchAlignment.allCases.randomElement()!
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "icon-pitch-alignment").value as! String
        manager.iconPitchAlignment = newIconPitchAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-pitch-alignment"])

        manager.iconPitchAlignment = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.iconPitchAlignment)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-pitch-alignment"] as! String, defaultValue)
    }

    func testInitialIconRotationAlignment() {
        let initialValue = manager.iconRotationAlignment
        XCTAssertNil(initialValue)
    }

    func testSetIconRotationAlignment() {
        let value = IconRotationAlignment.allCases.randomElement()!
        manager.iconRotationAlignment = value
        XCTAssertEqual(manager.iconRotationAlignment, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-rotation-alignment"] as! String, value.rawValue)
    }

    func testIconRotationAlignmentAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconRotationAlignmentProperty = IconRotationAlignment.allCases.randomElement()!
        let secondIconRotationAlignmentProperty = IconRotationAlignment.allCases.randomElement()!

        manager.iconRotationAlignment = newIconRotationAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.iconRotationAlignment = secondIconRotationAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-rotation-alignment"] as! String, secondIconRotationAlignmentProperty.rawValue)
    }

    func testNewIconRotationAlignmentPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconRotationAlignmentProperty = IconRotationAlignment.allCases.randomElement()!

        manager.annotations = annotations
        manager.iconRotationAlignment = newIconRotationAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-rotation-alignment"])
    }

    func testSetToNilIconRotationAlignment() {
        let newIconRotationAlignmentProperty = IconRotationAlignment.allCases.randomElement()!
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "icon-rotation-alignment").value as! String
        manager.iconRotationAlignment = newIconRotationAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-rotation-alignment"])

        manager.iconRotationAlignment = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.iconRotationAlignment)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-rotation-alignment"] as! String, defaultValue)
    }

    func testInitialIconTextFit() {
        let initialValue = manager.iconTextFit
        XCTAssertNil(initialValue)
    }

    func testSetIconTextFit() {
        let value = IconTextFit.allCases.randomElement()!
        manager.iconTextFit = value
        XCTAssertEqual(manager.iconTextFit, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-text-fit"] as! String, value.rawValue)
    }

    func testIconTextFitAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconTextFitProperty = IconTextFit.allCases.randomElement()!
        let secondIconTextFitProperty = IconTextFit.allCases.randomElement()!

        manager.iconTextFit = newIconTextFitProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.iconTextFit = secondIconTextFitProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-text-fit"] as! String, secondIconTextFitProperty.rawValue)
    }

    func testNewIconTextFitPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconTextFitProperty = IconTextFit.allCases.randomElement()!

        manager.annotations = annotations
        manager.iconTextFit = newIconTextFitProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-text-fit"])
    }

    func testSetToNilIconTextFit() {
        let newIconTextFitProperty = IconTextFit.allCases.randomElement()!
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "icon-text-fit").value as! String
        manager.iconTextFit = newIconTextFitProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-text-fit"])

        manager.iconTextFit = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.iconTextFit)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-text-fit"] as! String, defaultValue)
    }

    func testInitialIconTextFitPadding() {
        let initialValue = manager.iconTextFitPadding
        XCTAssertNil(initialValue)
    }

    func testSetIconTextFitPadding() {
        let value = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        manager.iconTextFitPadding = value
        XCTAssertEqual(manager.iconTextFitPadding, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-text-fit-padding"] as! [Double], value)
    }

    func testIconTextFitPaddingAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconTextFitPaddingProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        let secondIconTextFitPaddingProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]

        manager.iconTextFitPadding = newIconTextFitPaddingProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.iconTextFitPadding = secondIconTextFitPaddingProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-text-fit-padding"] as! [Double], secondIconTextFitPaddingProperty)
    }

    func testNewIconTextFitPaddingPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconTextFitPaddingProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]

        manager.annotations = annotations
        manager.iconTextFitPadding = newIconTextFitPaddingProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-text-fit-padding"])
    }

    func testSetToNilIconTextFitPadding() {
        let newIconTextFitPaddingProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "icon-text-fit-padding").value as! [Double]
        manager.iconTextFitPadding = newIconTextFitPaddingProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-text-fit-padding"])

        manager.iconTextFitPadding = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.iconTextFitPadding)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-text-fit-padding"] as! [Double], defaultValue)
    }

    func testInitialSymbolAvoidEdges() {
        let initialValue = manager.symbolAvoidEdges
        XCTAssertNil(initialValue)
    }

    func testSetSymbolAvoidEdges() {
        let value = Bool.random()
        manager.symbolAvoidEdges = value
        XCTAssertEqual(manager.symbolAvoidEdges, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-avoid-edges"] as! Bool, value)
    }

    func testSymbolAvoidEdgesAnnotationPropertiesAddedWithoutDuplicate() {
        let newSymbolAvoidEdgesProperty = Bool.random()
        let secondSymbolAvoidEdgesProperty = Bool.random()

        manager.symbolAvoidEdges = newSymbolAvoidEdgesProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.symbolAvoidEdges = secondSymbolAvoidEdgesProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-avoid-edges"] as! Bool, secondSymbolAvoidEdgesProperty)
    }

    func testNewSymbolAvoidEdgesPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newSymbolAvoidEdgesProperty = Bool.random()

        manager.annotations = annotations
        manager.symbolAvoidEdges = newSymbolAvoidEdgesProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-avoid-edges"])
    }

    func testSetToNilSymbolAvoidEdges() {
        let newSymbolAvoidEdgesProperty = Bool.random()
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "symbol-avoid-edges").value as! Bool
        manager.symbolAvoidEdges = newSymbolAvoidEdgesProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-avoid-edges"])

        manager.symbolAvoidEdges = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.symbolAvoidEdges)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-avoid-edges"] as! Bool, defaultValue)
    }

    func testInitialSymbolPlacement() {
        let initialValue = manager.symbolPlacement
        XCTAssertNil(initialValue)
    }

    func testSetSymbolPlacement() {
        let value = SymbolPlacement.allCases.randomElement()!
        manager.symbolPlacement = value
        XCTAssertEqual(manager.symbolPlacement, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-placement"] as! String, value.rawValue)
    }

    func testSymbolPlacementAnnotationPropertiesAddedWithoutDuplicate() {
        let newSymbolPlacementProperty = SymbolPlacement.allCases.randomElement()!
        let secondSymbolPlacementProperty = SymbolPlacement.allCases.randomElement()!

        manager.symbolPlacement = newSymbolPlacementProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.symbolPlacement = secondSymbolPlacementProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-placement"] as! String, secondSymbolPlacementProperty.rawValue)
    }

    func testNewSymbolPlacementPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newSymbolPlacementProperty = SymbolPlacement.allCases.randomElement()!

        manager.annotations = annotations
        manager.symbolPlacement = newSymbolPlacementProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-placement"])
    }

    func testSetToNilSymbolPlacement() {
        let newSymbolPlacementProperty = SymbolPlacement.allCases.randomElement()!
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "symbol-placement").value as! String
        manager.symbolPlacement = newSymbolPlacementProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-placement"])

        manager.symbolPlacement = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.symbolPlacement)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-placement"] as! String, defaultValue)
    }

    func testInitialSymbolSpacing() {
        let initialValue = manager.symbolSpacing
        XCTAssertNil(initialValue)
    }

    func testSetSymbolSpacing() {
        let value = Double.random(in: 1...100000)
        manager.symbolSpacing = value
        XCTAssertEqual(manager.symbolSpacing, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-spacing"] as! Double, value)
    }

    func testSymbolSpacingAnnotationPropertiesAddedWithoutDuplicate() {
        let newSymbolSpacingProperty = Double.random(in: 1...100000)
        let secondSymbolSpacingProperty = Double.random(in: 1...100000)

        manager.symbolSpacing = newSymbolSpacingProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.symbolSpacing = secondSymbolSpacingProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-spacing"] as! Double, secondSymbolSpacingProperty)
    }

    func testNewSymbolSpacingPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newSymbolSpacingProperty = Double.random(in: 1...100000)

        manager.annotations = annotations
        manager.symbolSpacing = newSymbolSpacingProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-spacing"])
    }

    func testSetToNilSymbolSpacing() {
        let newSymbolSpacingProperty = Double.random(in: 1...100000)
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "symbol-spacing").value as! Double
        manager.symbolSpacing = newSymbolSpacingProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-spacing"])

        manager.symbolSpacing = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.symbolSpacing)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-spacing"] as! Double, defaultValue)
    }

    func testInitialSymbolZOrder() {
        let initialValue = manager.symbolZOrder
        XCTAssertNil(initialValue)
    }

    func testSetSymbolZOrder() {
        let value = SymbolZOrder.allCases.randomElement()!
        manager.symbolZOrder = value
        XCTAssertEqual(manager.symbolZOrder, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-z-order"] as! String, value.rawValue)
    }

    func testSymbolZOrderAnnotationPropertiesAddedWithoutDuplicate() {
        let newSymbolZOrderProperty = SymbolZOrder.allCases.randomElement()!
        let secondSymbolZOrderProperty = SymbolZOrder.allCases.randomElement()!

        manager.symbolZOrder = newSymbolZOrderProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.symbolZOrder = secondSymbolZOrderProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-z-order"] as! String, secondSymbolZOrderProperty.rawValue)
    }

    func testNewSymbolZOrderPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newSymbolZOrderProperty = SymbolZOrder.allCases.randomElement()!

        manager.annotations = annotations
        manager.symbolZOrder = newSymbolZOrderProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-z-order"])
    }

    func testSetToNilSymbolZOrder() {
        let newSymbolZOrderProperty = SymbolZOrder.allCases.randomElement()!
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "symbol-z-order").value as! String
        manager.symbolZOrder = newSymbolZOrderProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-z-order"])

        manager.symbolZOrder = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.symbolZOrder)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-z-order"] as! String, defaultValue)
    }

    func testInitialTextAllowOverlap() {
        let initialValue = manager.textAllowOverlap
        XCTAssertNil(initialValue)
    }

    func testSetTextAllowOverlap() {
        let value = Bool.random()
        manager.textAllowOverlap = value
        XCTAssertEqual(manager.textAllowOverlap, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-allow-overlap"] as! Bool, value)
    }

    func testTextAllowOverlapAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextAllowOverlapProperty = Bool.random()
        let secondTextAllowOverlapProperty = Bool.random()

        manager.textAllowOverlap = newTextAllowOverlapProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.textAllowOverlap = secondTextAllowOverlapProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-allow-overlap"] as! Bool, secondTextAllowOverlapProperty)
    }

    func testNewTextAllowOverlapPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextAllowOverlapProperty = Bool.random()

        manager.annotations = annotations
        manager.textAllowOverlap = newTextAllowOverlapProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-allow-overlap"])
    }

    func testSetToNilTextAllowOverlap() {
        let newTextAllowOverlapProperty = Bool.random()
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "text-allow-overlap").value as! Bool
        manager.textAllowOverlap = newTextAllowOverlapProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-allow-overlap"])

        manager.textAllowOverlap = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.textAllowOverlap)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-allow-overlap"] as! Bool, defaultValue)
    }

    func testInitialTextFont() {
        let initialValue = manager.textFont
        XCTAssertNil(initialValue)
    }

    func testSetTextFont() {
        let value = Array.random(withLength: .random(in: 0...10), generator: { String.randomASCII(withLength: .random(in: 0...100)) })
        manager.textFont = value
        XCTAssertEqual(manager.textFont, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual((style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-font"] as! [Any])[1] as! [String], value)
    }

    func testTextFontAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextFontProperty = Array.random(withLength: .random(in: 0...10), generator: { String.randomASCII(withLength: .random(in: 0...100)) })
        let secondTextFontProperty = Array.random(withLength: .random(in: 0...10), generator: { String.randomASCII(withLength: .random(in: 0...100)) })

        manager.textFont = newTextFontProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.textFont = secondTextFontProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual((style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-font"] as! [Any])[1] as! [String], secondTextFontProperty)
    }

    func testNewTextFontPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextFontProperty = Array.random(withLength: .random(in: 0...10), generator: { String.randomASCII(withLength: .random(in: 0...100)) })

        manager.annotations = annotations
        manager.textFont = newTextFontProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-font"])
    }

    func testSetToNilTextFont() {
        let newTextFontProperty = Array.random(withLength: .random(in: 0...10), generator: { String.randomASCII(withLength: .random(in: 0...100)) })
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "text-font").value as! [String]
        manager.textFont = newTextFontProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-font"])

        manager.textFont = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.textFont)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-font"] as! [String], defaultValue)
    }

    func testInitialTextIgnorePlacement() {
        let initialValue = manager.textIgnorePlacement
        XCTAssertNil(initialValue)
    }

    func testSetTextIgnorePlacement() {
        let value = Bool.random()
        manager.textIgnorePlacement = value
        XCTAssertEqual(manager.textIgnorePlacement, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-ignore-placement"] as! Bool, value)
    }

    func testTextIgnorePlacementAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextIgnorePlacementProperty = Bool.random()
        let secondTextIgnorePlacementProperty = Bool.random()

        manager.textIgnorePlacement = newTextIgnorePlacementProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.textIgnorePlacement = secondTextIgnorePlacementProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-ignore-placement"] as! Bool, secondTextIgnorePlacementProperty)
    }

    func testNewTextIgnorePlacementPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextIgnorePlacementProperty = Bool.random()

        manager.annotations = annotations
        manager.textIgnorePlacement = newTextIgnorePlacementProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-ignore-placement"])
    }

    func testSetToNilTextIgnorePlacement() {
        let newTextIgnorePlacementProperty = Bool.random()
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "text-ignore-placement").value as! Bool
        manager.textIgnorePlacement = newTextIgnorePlacementProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-ignore-placement"])

        manager.textIgnorePlacement = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.textIgnorePlacement)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-ignore-placement"] as! Bool, defaultValue)
    }

    func testInitialTextKeepUpright() {
        let initialValue = manager.textKeepUpright
        XCTAssertNil(initialValue)
    }

    func testSetTextKeepUpright() {
        let value = Bool.random()
        manager.textKeepUpright = value
        XCTAssertEqual(manager.textKeepUpright, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-keep-upright"] as! Bool, value)
    }

    func testTextKeepUprightAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextKeepUprightProperty = Bool.random()
        let secondTextKeepUprightProperty = Bool.random()

        manager.textKeepUpright = newTextKeepUprightProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.textKeepUpright = secondTextKeepUprightProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-keep-upright"] as! Bool, secondTextKeepUprightProperty)
    }

    func testNewTextKeepUprightPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextKeepUprightProperty = Bool.random()

        manager.annotations = annotations
        manager.textKeepUpright = newTextKeepUprightProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-keep-upright"])
    }

    func testSetToNilTextKeepUpright() {
        let newTextKeepUprightProperty = Bool.random()
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "text-keep-upright").value as! Bool
        manager.textKeepUpright = newTextKeepUprightProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-keep-upright"])

        manager.textKeepUpright = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.textKeepUpright)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-keep-upright"] as! Bool, defaultValue)
    }

    func testInitialTextMaxAngle() {
        let initialValue = manager.textMaxAngle
        XCTAssertNil(initialValue)
    }

    func testSetTextMaxAngle() {
        let value = Double.random(in: -100000...100000)
        manager.textMaxAngle = value
        XCTAssertEqual(manager.textMaxAngle, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-max-angle"] as! Double, value)
    }

    func testTextMaxAngleAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextMaxAngleProperty = Double.random(in: -100000...100000)
        let secondTextMaxAngleProperty = Double.random(in: -100000...100000)

        manager.textMaxAngle = newTextMaxAngleProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.textMaxAngle = secondTextMaxAngleProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-max-angle"] as! Double, secondTextMaxAngleProperty)
    }

    func testNewTextMaxAnglePropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextMaxAngleProperty = Double.random(in: -100000...100000)

        manager.annotations = annotations
        manager.textMaxAngle = newTextMaxAngleProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-max-angle"])
    }

    func testSetToNilTextMaxAngle() {
        let newTextMaxAngleProperty = Double.random(in: -100000...100000)
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "text-max-angle").value as! Double
        manager.textMaxAngle = newTextMaxAngleProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-max-angle"])

        manager.textMaxAngle = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.textMaxAngle)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-max-angle"] as! Double, defaultValue)
    }

    func testInitialTextOptional() {
        let initialValue = manager.textOptional
        XCTAssertNil(initialValue)
    }

    func testSetTextOptional() {
        let value = Bool.random()
        manager.textOptional = value
        XCTAssertEqual(manager.textOptional, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-optional"] as! Bool, value)
    }

    func testTextOptionalAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextOptionalProperty = Bool.random()
        let secondTextOptionalProperty = Bool.random()

        manager.textOptional = newTextOptionalProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.textOptional = secondTextOptionalProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-optional"] as! Bool, secondTextOptionalProperty)
    }

    func testNewTextOptionalPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextOptionalProperty = Bool.random()

        manager.annotations = annotations
        manager.textOptional = newTextOptionalProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-optional"])
    }

    func testSetToNilTextOptional() {
        let newTextOptionalProperty = Bool.random()
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "text-optional").value as! Bool
        manager.textOptional = newTextOptionalProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-optional"])

        manager.textOptional = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.textOptional)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-optional"] as! Bool, defaultValue)
    }

    func testInitialTextPadding() {
        let initialValue = manager.textPadding
        XCTAssertNil(initialValue)
    }

    func testSetTextPadding() {
        let value = Double.random(in: 0...100000)
        manager.textPadding = value
        XCTAssertEqual(manager.textPadding, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-padding"] as! Double, value)
    }

    func testTextPaddingAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextPaddingProperty = Double.random(in: 0...100000)
        let secondTextPaddingProperty = Double.random(in: 0...100000)

        manager.textPadding = newTextPaddingProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.textPadding = secondTextPaddingProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-padding"] as! Double, secondTextPaddingProperty)
    }

    func testNewTextPaddingPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextPaddingProperty = Double.random(in: 0...100000)

        manager.annotations = annotations
        manager.textPadding = newTextPaddingProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-padding"])
    }

    func testSetToNilTextPadding() {
        let newTextPaddingProperty = Double.random(in: 0...100000)
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "text-padding").value as! Double
        manager.textPadding = newTextPaddingProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-padding"])

        manager.textPadding = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.textPadding)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-padding"] as! Double, defaultValue)
    }

    func testInitialTextPitchAlignment() {
        let initialValue = manager.textPitchAlignment
        XCTAssertNil(initialValue)
    }

    func testSetTextPitchAlignment() {
        let value = TextPitchAlignment.allCases.randomElement()!
        manager.textPitchAlignment = value
        XCTAssertEqual(manager.textPitchAlignment, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-pitch-alignment"] as! String, value.rawValue)
    }

    func testTextPitchAlignmentAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextPitchAlignmentProperty = TextPitchAlignment.allCases.randomElement()!
        let secondTextPitchAlignmentProperty = TextPitchAlignment.allCases.randomElement()!

        manager.textPitchAlignment = newTextPitchAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.textPitchAlignment = secondTextPitchAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-pitch-alignment"] as! String, secondTextPitchAlignmentProperty.rawValue)
    }

    func testNewTextPitchAlignmentPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextPitchAlignmentProperty = TextPitchAlignment.allCases.randomElement()!

        manager.annotations = annotations
        manager.textPitchAlignment = newTextPitchAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-pitch-alignment"])
    }

    func testSetToNilTextPitchAlignment() {
        let newTextPitchAlignmentProperty = TextPitchAlignment.allCases.randomElement()!
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "text-pitch-alignment").value as! String
        manager.textPitchAlignment = newTextPitchAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-pitch-alignment"])

        manager.textPitchAlignment = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.textPitchAlignment)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-pitch-alignment"] as! String, defaultValue)
    }

    func testInitialTextRotationAlignment() {
        let initialValue = manager.textRotationAlignment
        XCTAssertNil(initialValue)
    }

    func testSetTextRotationAlignment() {
        let value = TextRotationAlignment.allCases.randomElement()!
        manager.textRotationAlignment = value
        XCTAssertEqual(manager.textRotationAlignment, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-rotation-alignment"] as! String, value.rawValue)
    }

    func testTextRotationAlignmentAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextRotationAlignmentProperty = TextRotationAlignment.allCases.randomElement()!
        let secondTextRotationAlignmentProperty = TextRotationAlignment.allCases.randomElement()!

        manager.textRotationAlignment = newTextRotationAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.textRotationAlignment = secondTextRotationAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-rotation-alignment"] as! String, secondTextRotationAlignmentProperty.rawValue)
    }

    func testNewTextRotationAlignmentPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextRotationAlignmentProperty = TextRotationAlignment.allCases.randomElement()!

        manager.annotations = annotations
        manager.textRotationAlignment = newTextRotationAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-rotation-alignment"])
    }

    func testSetToNilTextRotationAlignment() {
        let newTextRotationAlignmentProperty = TextRotationAlignment.allCases.randomElement()!
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "text-rotation-alignment").value as! String
        manager.textRotationAlignment = newTextRotationAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-rotation-alignment"])

        manager.textRotationAlignment = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.textRotationAlignment)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-rotation-alignment"] as! String, defaultValue)
    }

    func testInitialTextVariableAnchor() {
        let initialValue = manager.textVariableAnchor
        XCTAssertNil(initialValue)
    }

    func testSetTextVariableAnchor() {
        let value = Array.random(withLength: .random(in: 0...10), generator: { TextAnchor.allCases.randomElement()! })
        manager.textVariableAnchor = value
        XCTAssertEqual(manager.textVariableAnchor, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        let valueAsString = value.map { $0.rawValue }
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-variable-anchor"] as! [String], valueAsString)
    }

    func testTextVariableAnchorAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextVariableAnchorProperty = Array.random(withLength: .random(in: 0...10), generator: { TextAnchor.allCases.randomElement()! })
        let secondTextVariableAnchorProperty = Array.random(withLength: .random(in: 0...10), generator: { TextAnchor.allCases.randomElement()! })

        manager.textVariableAnchor = newTextVariableAnchorProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.textVariableAnchor = secondTextVariableAnchorProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        let valueAsString = secondTextVariableAnchorProperty.map { $0.rawValue }
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-variable-anchor"] as! [String], valueAsString)
    }

    func testNewTextVariableAnchorPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextVariableAnchorProperty = Array.random(withLength: .random(in: 0...10), generator: { TextAnchor.allCases.randomElement()! })

        manager.annotations = annotations
        manager.textVariableAnchor = newTextVariableAnchorProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-variable-anchor"])
    }

    func testSetToNilTextVariableAnchor() {
        let newTextVariableAnchorProperty = Array.random(withLength: .random(in: 0...10), generator: { TextAnchor.allCases.randomElement()! })
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "text-variable-anchor").value as! [TextAnchor]
        manager.textVariableAnchor = newTextVariableAnchorProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-variable-anchor"])

        manager.textVariableAnchor = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.textVariableAnchor)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-variable-anchor"] as! [TextAnchor], defaultValue)
    }

    func testInitialTextWritingMode() {
        let initialValue = manager.textWritingMode
        XCTAssertNil(initialValue)
    }

    func testSetTextWritingMode() {
        let value = Array.random(withLength: .random(in: 0...10), generator: { TextWritingMode.allCases.randomElement()! })
        manager.textWritingMode = value
        XCTAssertEqual(manager.textWritingMode, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        let valueAsString = value.map { $0.rawValue }
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-writing-mode"] as! [String], valueAsString)
    }

    func testTextWritingModeAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextWritingModeProperty = Array.random(withLength: .random(in: 0...10), generator: { TextWritingMode.allCases.randomElement()! })
        let secondTextWritingModeProperty = Array.random(withLength: .random(in: 0...10), generator: { TextWritingMode.allCases.randomElement()! })

        manager.textWritingMode = newTextWritingModeProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.textWritingMode = secondTextWritingModeProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        let valueAsString = secondTextWritingModeProperty.map { $0.rawValue }
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-writing-mode"] as! [String], valueAsString)
    }

    func testNewTextWritingModePropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextWritingModeProperty = Array.random(withLength: .random(in: 0...10), generator: { TextWritingMode.allCases.randomElement()! })

        manager.annotations = annotations
        manager.textWritingMode = newTextWritingModeProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-writing-mode"])
    }

    func testSetToNilTextWritingMode() {
        let newTextWritingModeProperty = Array.random(withLength: .random(in: 0...10), generator: { TextWritingMode.allCases.randomElement()! })
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "text-writing-mode").value as! [TextWritingMode]
        manager.textWritingMode = newTextWritingModeProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-writing-mode"])

        manager.textWritingMode = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.textWritingMode)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-writing-mode"] as! [TextWritingMode], defaultValue)
    }

    func testInitialIconTranslate() {
        let initialValue = manager.iconTranslate
        XCTAssertNil(initialValue)
    }

    func testSetIconTranslate() {
        let value = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        manager.iconTranslate = value
        XCTAssertEqual(manager.iconTranslate, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate"] as! [Double], value)
    }

    func testIconTranslateAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        let secondIconTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]

        manager.iconTranslate = newIconTranslateProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.iconTranslate = secondIconTranslateProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate"] as! [Double], secondIconTranslateProperty)
    }

    func testNewIconTranslatePropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]

        manager.annotations = annotations
        manager.iconTranslate = newIconTranslateProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate"])
    }

    func testSetToNilIconTranslate() {
        let newIconTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "icon-translate").value as! [Double]
        manager.iconTranslate = newIconTranslateProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate"])

        manager.iconTranslate = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.iconTranslate)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate"] as! [Double], defaultValue)
    }

    func testInitialIconTranslateAnchor() {
        let initialValue = manager.iconTranslateAnchor
        XCTAssertNil(initialValue)
    }

    func testSetIconTranslateAnchor() {
        let value = IconTranslateAnchor.allCases.randomElement()!
        manager.iconTranslateAnchor = value
        XCTAssertEqual(manager.iconTranslateAnchor, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate-anchor"] as! String, value.rawValue)
    }

    func testIconTranslateAnchorAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconTranslateAnchorProperty = IconTranslateAnchor.allCases.randomElement()!
        let secondIconTranslateAnchorProperty = IconTranslateAnchor.allCases.randomElement()!

        manager.iconTranslateAnchor = newIconTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.iconTranslateAnchor = secondIconTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate-anchor"] as! String, secondIconTranslateAnchorProperty.rawValue)
    }

    func testNewIconTranslateAnchorPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconTranslateAnchorProperty = IconTranslateAnchor.allCases.randomElement()!

        manager.annotations = annotations
        manager.iconTranslateAnchor = newIconTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate-anchor"])
    }

    func testSetToNilIconTranslateAnchor() {
        let newIconTranslateAnchorProperty = IconTranslateAnchor.allCases.randomElement()!
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "icon-translate-anchor").value as! String
        manager.iconTranslateAnchor = newIconTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate-anchor"])

        manager.iconTranslateAnchor = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.iconTranslateAnchor)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate-anchor"] as! String, defaultValue)
    }

    func testInitialTextTranslate() {
        let initialValue = manager.textTranslate
        XCTAssertNil(initialValue)
    }

    func testSetTextTranslate() {
        let value = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        manager.textTranslate = value
        XCTAssertEqual(manager.textTranslate, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate"] as! [Double], value)
    }

    func testTextTranslateAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        let secondTextTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]

        manager.textTranslate = newTextTranslateProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.textTranslate = secondTextTranslateProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate"] as! [Double], secondTextTranslateProperty)
    }

    func testNewTextTranslatePropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]

        manager.annotations = annotations
        manager.textTranslate = newTextTranslateProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate"])
    }

    func testSetToNilTextTranslate() {
        let newTextTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "text-translate").value as! [Double]
        manager.textTranslate = newTextTranslateProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate"])

        manager.textTranslate = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.textTranslate)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate"] as! [Double], defaultValue)
    }

    func testInitialTextTranslateAnchor() {
        let initialValue = manager.textTranslateAnchor
        XCTAssertNil(initialValue)
    }

    func testSetTextTranslateAnchor() {
        let value = TextTranslateAnchor.allCases.randomElement()!
        manager.textTranslateAnchor = value
        XCTAssertEqual(manager.textTranslateAnchor, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate-anchor"] as! String, value.rawValue)
    }

    func testTextTranslateAnchorAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextTranslateAnchorProperty = TextTranslateAnchor.allCases.randomElement()!
        let secondTextTranslateAnchorProperty = TextTranslateAnchor.allCases.randomElement()!

        manager.textTranslateAnchor = newTextTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.textTranslateAnchor = secondTextTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate-anchor"] as! String, secondTextTranslateAnchorProperty.rawValue)
    }

    func testNewTextTranslateAnchorPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.iconAnchor = IconAnchor.allCases.randomElement()!
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.allCases.randomElement()!
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.allCases.randomElement()!
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.allCases.randomElement()!
            annotation.iconColor = StyleColor.random()
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextTranslateAnchorProperty = TextTranslateAnchor.allCases.randomElement()!

        manager.annotations = annotations
        manager.textTranslateAnchor = newTextTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate-anchor"])
    }

    func testSetToNilTextTranslateAnchor() {
        let newTextTranslateAnchorProperty = TextTranslateAnchor.allCases.randomElement()!
        let defaultValue = Style.layerPropertyDefaultValue(for: .symbol, property: "text-translate-anchor").value as! String
        manager.textTranslateAnchor = newTextTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate-anchor"])

        manager.textTranslateAnchor = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.textTranslateAnchor)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate-anchor"] as! String, defaultValue)
    }

    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        self.delegateAnnotations = annotations
        expectation?.fulfill()
        expectation = nil
    }

    // Add tests specific to PointAnnotationManager
    func testNewImagesAddedToStyle() {
        // given
        let annotations = (0..<10)
            .map { _ in PointAnnotation.Image(image: UIImage(), name: UUID().uuidString) }
            .map(PointAnnotation.init)

        // when
        manager.annotations = annotations
        manager.syncSourceAndLayerIfNeeded()

        // then
        XCTAssertEqual(style.addImageWithInsetsStub.invocations.count, annotations.count)
        XCTAssertEqual(
            Set(style.addImageWithInsetsStub.invocations.map(\.parameters.id)),
            Set(annotations.compactMap(\.image?.name))
        )
        XCTAssertEqual(
            Set(style.addImageWithInsetsStub.invocations.map(\.parameters.image)),
            Set(annotations.compactMap(\.image?.image))
        )
        XCTAssertEqual(style.removeImageStub.invocations.count, 0)
    }

    func testUnusedImagesRemovedFromStyle() {
        // given
        let unusedAnnotations = 3
        let annotations = (0..<10)
            .map { _ in PointAnnotation.Image(image: UIImage(), name: UUID().uuidString) }
            .map(PointAnnotation.init)
        manager.annotations = annotations
        manager.syncSourceAndLayerIfNeeded()

        // when
        manager.annotations = annotations.suffix(annotations.count - unusedAnnotations)
        manager.syncSourceAndLayerIfNeeded()

        // then
        XCTAssertEqual(style.addImageWithInsetsStub.invocations.count, annotations.count + annotations.count - unusedAnnotations)
        XCTAssertEqual(
            Set(style.addImageWithInsetsStub.invocations.map(\.parameters.id)),
            Set(annotations.compactMap(\.image?.name))
        )
        XCTAssertEqual(
            Set(style.addImageWithInsetsStub.invocations.map(\.parameters.image)),
            Set(annotations.compactMap(\.image?.image))
        )
        XCTAssertEqual(style.removeImageStub.invocations.count, unusedAnnotations)
        XCTAssertEqual(
            Set(style.removeImageStub.invocations.map(\.parameters)),
            Set(annotations.prefix(unusedAnnotations).compactMap(\.image?.name))
        )
    }

    func testAllImagesRemovedFromStyleOnUpdate() {
        // given
        let annotations = (0..<10)
            .map { _ in PointAnnotation.Image(image: UIImage(), name: UUID().uuidString) }
            .map(PointAnnotation.init)
        manager.annotations = annotations
        manager.syncSourceAndLayerIfNeeded()

        // when
        manager.annotations = []
        manager.syncSourceAndLayerIfNeeded()

        // then
        XCTAssertEqual(style.addImageWithInsetsStub.invocations.count, annotations.count)
        XCTAssertEqual(
            Set(style.addImageWithInsetsStub.invocations.map(\.parameters.id)),
            Set(annotations.compactMap(\.image?.name))
        )
        XCTAssertEqual(
            Set(style.addImageWithInsetsStub.invocations.map(\.parameters.image)),
            Set(annotations.compactMap(\.image?.image))
        )
        XCTAssertEqual(style.removeImageStub.invocations.count, annotations.count)
        XCTAssertEqual(
            Set(style.removeImageStub.invocations.map(\.parameters)),
            Set(annotations.compactMap(\.image?.name))
        )
    }

    func testAllImagesRemovedFromStyleOnDestroy() {
        // given
        let annotations = (0..<10)
            .map { _ in PointAnnotation.Image(image: UIImage(), name: UUID().uuidString) }
            .map(PointAnnotation.init)
        manager.annotations = annotations
        manager.syncSourceAndLayerIfNeeded()

        // when
        manager.destroy()

        // then
        XCTAssertEqual(style.removeImageStub.invocations.count, annotations.count)
        XCTAssertEqual(
            Set(style.removeImageStub.invocations.map(\.parameters)),
            Set(annotations.compactMap(\.image?.name))
        )

    }

    // Tests for clustering
    func testInitWithDefaultClusterOptions() {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        // given
        let clusterOptions = ClusterOptions()
        var annotations = [PointAnnotation]()
        for _ in 0...500 {
            let annotation = PointAnnotation(coordinate: .random())
            annotations.append(annotation)
        }

        // when
        let pointAnnotationManager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            clusterOptions: clusterOptions,
            offsetPointCalculator: offsetPointCalculator
        )
        pointAnnotationManager.annotations = annotations

        // then
        XCTAssertEqual(clusterOptions.clusterRadius, 50)
        XCTAssertEqual(clusterOptions.circleRadius, .constant(18))
        XCTAssertEqual(clusterOptions.circleColor, .constant(StyleColor(.black)))
        XCTAssertEqual(clusterOptions.textColor, .constant(StyleColor(.white)))
        XCTAssertEqual(clusterOptions.textSize, .constant(12))
        XCTAssertEqual(clusterOptions.textField, .expression(Exp(.get) { "point_count" }))
        XCTAssertEqual(clusterOptions.clusterMaxZoom, 14)
        XCTAssertNil(clusterOptions.clusterProperties)
        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.source.type, SourceType.geoJson)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.id, manager.id)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 3) // symbol layer, one cluster layer, one text layer
        XCTAssertNil(style.addPersistentLayerStub.invocations.last?.parameters.layerPosition)
    }

    func testSourceClusterOptions() {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        // given
        let testClusterRadius = Double.testSourceValue()
        let testClusterMaxZoom = Double.testSourceValue()
        let testClusterProperties = [String: Expression].testSourceValue()
        let clusterOptions = ClusterOptions(clusterRadius: testClusterRadius,
                                            clusterMaxZoom: testClusterMaxZoom,
                                            clusterProperties: testClusterProperties)
        var annotations = [PointAnnotation]()
        for _ in 0...500 {
            let annotation = PointAnnotation(coordinate: .random())
            annotations.append(annotation)
        }

        // when
        let pointAnnotationManager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            clusterOptions: clusterOptions,
            offsetPointCalculator: offsetPointCalculator
        )
        pointAnnotationManager.annotations = annotations
        let geoJSONSource = style.addSourceStub.invocations.last?.parameters.source as! GeoJSONSource

        // then
        XCTAssertTrue(geoJSONSource.cluster!)
        XCTAssertEqual(clusterOptions.clusterRadius, testClusterRadius)
        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(geoJSONSource.clusterRadius, testClusterRadius)
        XCTAssertEqual(geoJSONSource.clusterMaxZoom, testClusterMaxZoom)
        XCTAssertEqual(geoJSONSource.clusterProperties, testClusterProperties)
    }

    func testCircleLayer() {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        // given
        let testCircleRadius = Value<Double>.testConstantValue()
        let testCircleColor = Value<StyleColor>.testConstantValue()
        let clusterOptions = ClusterOptions(circleRadius: testCircleRadius,
                                            circleColor: testCircleColor)
        var annotations = [PointAnnotation]()
        for _ in 0...500 {
            let annotation = PointAnnotation(coordinate: .random())
            annotations.append(annotation)
        }

        // when
        let pointAnnotationManager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            clusterOptions: clusterOptions,
            offsetPointCalculator: offsetPointCalculator
        )
        pointAnnotationManager.annotations = annotations

        // then
        let circleLayerInvocations = style.addPersistentLayerStub.invocations.filter { circleLayer in
            return circleLayer.parameters.layer.id == "mapbox-iOS-cluster-circle-layer-manager-" + id
        }
        let circleLayer = circleLayerInvocations[0].parameters.layer as! CircleLayer

        XCTAssertEqual(clusterOptions.circleRadius, testCircleRadius)
        XCTAssertEqual(circleLayer.circleRadius, testCircleRadius)
        XCTAssertEqual(clusterOptions.circleColor, testCircleColor)
        XCTAssertEqual(circleLayer.circleColor, testCircleColor)
        XCTAssertEqual(circleLayer.filter, Exp(.has) { "point_count" })
        XCTAssertEqual(circleLayer.id, "mapbox-iOS-cluster-circle-layer-manager-" + id)
        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
    }

    func testTextLayer() {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        // given
        let testTextColor = Value<StyleColor>.testConstantValue()
        let testTextSize = Value<Double>.testConstantValue()
        let testTextField = Value<String>.testConstantValue()
        let clusterOptions = ClusterOptions(textColor: testTextColor,
                                            textSize: testTextSize,
                                            textField: testTextField)
        var annotations = [PointAnnotation]()
        for _ in 0...500 {
            let annotation = PointAnnotation(coordinate: .random())
            annotations.append(annotation)
        }

        // when
        let pointAnnotationManager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            clusterOptions: clusterOptions,
            offsetPointCalculator: offsetPointCalculator
        )
        pointAnnotationManager.annotations = annotations

        // then
        let textLayerInvocations = style.addPersistentLayerStub.invocations.filter { symbolLayer in
            return symbolLayer.parameters.layer.id == "mapbox-iOS-cluster-text-layer-manager-" + id
        }
        let textLayer = textLayerInvocations[0].parameters.layer as! SymbolLayer

        XCTAssertEqual(textLayer.textColor, testTextColor)
        XCTAssertEqual(textLayer.textSize, testTextSize)
        XCTAssertEqual(textLayer.textField, testTextField)
        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
    }

    func testSymbolLayers() {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        // given
        let clusterOptions = ClusterOptions()
        var annotations = [PointAnnotation]()
        for _ in 0...500 {
            let annotation = PointAnnotation(coordinate: .random())
            annotations.append(annotation)
        }

        // when
        let pointAnnotationManager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            clusterOptions: clusterOptions,
            offsetPointCalculator: offsetPointCalculator
        )
        pointAnnotationManager.annotations = annotations

        // then
        let symbolLayerInvocations = style.addPersistentLayerStub.invocations.filter { symbolLayer in
            return symbolLayer.parameters.layer.id == id
        }
        let symbolLayer = symbolLayerInvocations[0].parameters.layer as! SymbolLayer

        XCTAssertTrue(symbolLayer.iconAllowOverlap == .constant(true))
        XCTAssertTrue(symbolLayer.textAllowOverlap == .constant(true))
        XCTAssertTrue(symbolLayer.iconIgnorePlacement == .constant(true))
        XCTAssertTrue(symbolLayer.textIgnorePlacement == .constant(true))
        XCTAssertEqual(symbolLayer.source, id)
        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
    }

    func testChangeAnnotations() {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        // given
        let clusterOptions = ClusterOptions()
        var annotations = [PointAnnotation]()
        for _ in 0...500 {
            let annotation = PointAnnotation(coordinate: .random())
            annotations.append(annotation)
        }
        var newAnnotations = [PointAnnotation]()
        for _ in 0...100 {
            let annotation = PointAnnotation(coordinate: .random())
            newAnnotations.append(annotation)
        }

        // when
        let pointAnnotationManager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            clusterOptions: clusterOptions,
            offsetPointCalculator: offsetPointCalculator
        )
        pointAnnotationManager.annotations = annotations
        pointAnnotationManager.syncSourceAndLayerIfNeeded()
        var sourceGeoJSON = style.updateGeoJSONSourceStub.invocations.last?.parameters.geojson
        switch sourceGeoJSON {
        case .featureCollection(let data):
            XCTAssertEqual(data.features.count, 501)
        default:
            XCTFail("GeoJSON did not update correctly")
        }

        // then
        pointAnnotationManager.annotations = newAnnotations
        pointAnnotationManager.syncSourceAndLayerIfNeeded()
        sourceGeoJSON = style.updateGeoJSONSourceStub.invocations.last?.parameters.geojson
        switch sourceGeoJSON {
        case .featureCollection(let data):
            XCTAssertEqual(data.features.count, 101)
        default:
            XCTFail("GeoJSON did not update correctly")
        }
        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
    }

    func testDestroyAnnotationManager() {
        // given
        let clusterOptions = ClusterOptions()

        // when
        let pointAnnotationManager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            clusterOptions: clusterOptions,
            offsetPointCalculator: offsetPointCalculator
        )
        pointAnnotationManager.annotations = annotations
        pointAnnotationManager.destroy()

        let removeLayerInvocations = style.removeLayerStub.invocations

        // then
        XCTAssertEqual(style.removeLayerStub.invocations.count, 3)
        XCTAssertEqual(removeLayerInvocations[0].parameters, "mapbox-iOS-cluster-circle-layer-manager-" + id)
        XCTAssertEqual(removeLayerInvocations[1].parameters, "mapbox-iOS-cluster-text-layer-manager-" + id)
        XCTAssertEqual(removeLayerInvocations[2].parameters, id)
    }

    func testHandleDragBeginNoFeatureId() {
        style.addSourceStub.reset()
        style.addPersistentLayerWithPropertiesStub.reset()

        manager.handleDragBegin(with: [])

        XCTAssertTrue(style.addSourceStub.invocations.isEmpty)
        XCTAssertTrue(style.addLayerStub.invocations.isEmpty)
        XCTAssertTrue(style.updateGeoJSONSourceStub.invocations.isEmpty)
    }

    func testHandleDragBeginInvalidFeatureId() {
        style.addSourceStub.reset()
        style.addPersistentLayerWithPropertiesStub.reset()

        manager.handleDragBegin(with: ["not-a-feature"])

        XCTAssertTrue(style.addSourceStub.invocations.isEmpty)
        XCTAssertTrue(style.addPersistentLayerWithPropertiesStub.invocations.isEmpty)
        XCTAssertTrue(style.updateGeoJSONSourceStub.invocations.isEmpty)
    }

    func testHandleDragBegin() throws {
        manager.annotations = [
            PointAnnotation(id: "point1", coordinate: .random())
        ]

        style.addSourceStub.reset()
        style.addPersistentLayerWithPropertiesStub.reset()

        manager.handleDragBegin(with: ["point1"])

        let addSourceParameters = try XCTUnwrap(style.addSourceStub.invocations.last).parameters
        let addLayerParameters = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.last).parameters
        let updateSourceParameters = try XCTUnwrap(style.updateGeoJSONSourceStub.invocations.last).parameters

        XCTAssertEqual(addLayerParameters.properties["source"] as? String, addSourceParameters.id)
        XCTAssertNotEqual(addLayerParameters.properties["id"] as? String, manager.layerId)

        XCTAssertFalse(manager.annotations.contains(where: { $0.id == "point1" }))
        XCTAssertTrue(updateSourceParameters.id == addSourceParameters.id)
    }

    func testHandleDragChanged() throws {
        mapboxMap.pointStub.defaultReturnValue = CGPoint(x: 0, y: 0)
        mapboxMap.coordinateForPointStub.defaultReturnValue = .random()
        mapboxMap.cameraState.zoom = 1

        manager.annotations = [
            PointAnnotation(id: "point1", coordinate: .init(latitude: 0, longitude: 0))
        ]

        manager.handleDragChanged(with: .random())
        XCTAssertTrue(style.updateGeoJSONSourceStub.invocations.isEmpty)

        manager.handleDragBegin(with: ["point1"])
        let addSourceParameters = try XCTUnwrap(style.addSourceStub.invocations.last).parameters

        manager.handleDragChanged(with: .random())
        let updateSourceParameters = try XCTUnwrap(style.updateGeoJSONSourceStub.invocations.last).parameters
        XCTAssertTrue(updateSourceParameters.id == addSourceParameters.id)
        guard case .feature = updateSourceParameters.geojson.geoJSONObject else {
            XCTFail("GeoJSONObject should be a feature")
            return
        }
    }

    func testHandleDragEnded() throws {
        manager.annotations = [
            PointAnnotation(id: "point1", coordinate: .init(latitude: 0, longitude: 0))
        ]

        manager.handleDragEnded()
        eventually(timeout: 0.2) {
            XCTAssertTrue(self.style.removeLayerStub.invocations.isEmpty)
            XCTAssertTrue(self.style.removeSourceStub.invocations.isEmpty)
        }

        manager.handleDragBegin(with: ["point1"])
        manager.handleDragEnded()

        XCTAssertTrue(manager.annotations.contains(where: { $0.id == "point1" }))
        eventually(timeout: 0.2) {
            let removeSourceParameters = self.style.removeSourceStub.invocations.last!.parameters
            let removeLayerParameters = self.style.removeLayerStub.invocations.last!.parameters

            XCTAssertNotEqual(removeLayerParameters, self.manager.layerId)
            XCTAssertNotEqual(removeSourceParameters, self.manager.sourceId)
        }
    }
}

private extension PointAnnotation {
    init(image: Image) {
        self.init(coordinate: .random())
        self.image = image
    }
}
// End of generated file
