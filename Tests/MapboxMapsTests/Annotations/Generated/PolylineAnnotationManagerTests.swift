// This file is generated
import XCTest
@testable import MapboxMaps

final class PolylineAnnotationManagerTests: XCTestCase, AnnotationInteractionDelegate {
    var manager: PolylineAnnotationManager!
    var style: MockStyle!
    var displayLinkCoordinator: MockDisplayLinkCoordinator!
    var id = UUID().uuidString
    var annotations = [PolylineAnnotation]()
    var expectation: XCTestExpectation?
    var delegateAnnotations: [Annotation]?
    var offsetLineStringCalculator: OffsetLineStringCalculator!

    var mapboxMap = MockMapboxMap()

    override func setUp() {
        super.setUp()

        style = MockStyle()
        displayLinkCoordinator = MockDisplayLinkCoordinator()
        offsetLineStringCalculator = OffsetLineStringCalculator(mapboxMap: mapboxMap)
        manager = PolylineAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetLineStringCalculator: offsetLineStringCalculator
        )

        for _ in 0...10 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            let annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
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

        _ = PolylineAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetLineStringCalculator: offsetLineStringCalculator
        )

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.source.type, SourceType.geoJson)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.id, manager.id)
    }

    func testAddLayer() {
        style.addSourceStub.reset()
        let initializedManager = PolylineAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetLineStringCalculator: offsetLineStringCalculator
        )

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.type, LayerType.line)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.id, initializedManager.id)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.source, initializedManager.sourceId)
        XCTAssertNil(style.addPersistentLayerStub.invocations.last?.parameters.layerPosition)
    }

    func testAddManagerWithDuplicateId() {
        var annotations2 = [PolylineAnnotation]()
        for _ in 0...50 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            let annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotations2.append(annotation)
        }

        manager.annotations = annotations
        let manager2 = PolylineAnnotationManager(
            id: manager.id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetLineStringCalculator: offsetLineStringCalculator
        )
        manager2.annotations = annotations2

        XCTAssertEqual(manager.annotations.count, 11)
        XCTAssertEqual(manager2.annotations.count, 51)
    }

    func testLayerPositionPassedCorrectly() {
        let manager3 = PolylineAnnotationManager(
            id: id,
            style: style,
            layerPosition: LayerPosition.at(4),
            displayLinkCoordinator: displayLinkCoordinator,
            offsetLineStringCalculator: offsetLineStringCalculator
        )
        manager3.annotations = annotations

        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layerPosition, LayerPosition.at(4))
    }

    func testDestroyManager() {
        manager.destroy()

        XCTAssertEqual(style.removeLayerStub.invocations.map(\.parameters), [id + "_drag-layer", id])
        XCTAssertEqual(style.removeSourceStub.invocations.map(\.parameters), [id + "_drag-source", id])
    }

    func testDestroyManagerTwice() {
        manager.destroy()
        XCTAssertEqual(style.removeLayerStub.invocations.map(\.parameters), [id + "_drag-layer", id])
        XCTAssertEqual(style.removeSourceStub.invocations.map(\.parameters), [id + "_drag-source", id])
        style.removeLayerStub.reset()
        style.removeSourceStub.reset()

        manager.destroy()
        XCTAssertTrue(style.removeLayerStub.invocations.isEmpty)
        XCTAssertTrue(style.removeSourceStub.invocations.isEmpty)
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

    func testFeatureCollectionPassedtoGeoJSON() {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            let annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }
        let expectedFeatureCollection = FeatureCollection(features: annotations.map(\.feature))

        manager.annotations = annotations
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.last?.parameters.id, manager.id)
        if case .featureCollection(let collection) = style.updateGeoJSONSourceStub.invocations[0].parameters.geojson {
            XCTAssertTrue(collection.features.allSatisfy(expectedFeatureCollection.features.contains(_:)))
        } else {
            XCTFail("GeoJSON object should be a feature collection")
        }
    }

    func testHandleQueriedFeatureIdsPassesNotificationToDelegate() throws {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            let annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
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
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            let annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }
        let queriedFeatureIds = ["NotAnAnnotationID"]
        manager.delegate = self

        expectation?.isInverted = true
        manager.annotations = annotations
        manager.handleQueriedFeatureIds(queriedFeatureIds)

        XCTAssertNil(delegateAnnotations)
    }

    func testInitialLineCap() {
        let initialValue = manager.lineCap
        XCTAssertNil(initialValue)
    }

    func testSetLineCap() {
        let value = LineCap.allCases.randomElement()!
        manager.lineCap = value
        XCTAssertEqual(manager.lineCap, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-cap"] as! String, value.rawValue)
    }

    func testLineCapAnnotationPropertiesAddedWithoutDuplicate() {
        let newLineCapProperty = LineCap.allCases.randomElement()!
        let secondLineCapProperty = LineCap.allCases.randomElement()!

        manager.lineCap = newLineCapProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.lineCap = secondLineCapProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-cap"] as! String, secondLineCapProperty.rawValue)
    }

    func testNewLineCapPropertyMergedWithAnnotationProperties() {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotation.lineJoin = LineJoin.allCases.randomElement()!
            annotation.lineSortKey = Double.random(in: -100000...100000)
            annotation.lineBlur = Double.random(in: 0...100000)
            annotation.lineColor = StyleColor.random()
            annotation.lineGapWidth = Double.random(in: 0...100000)
            annotation.lineOffset = Double.random(in: -100000...100000)
            annotation.lineOpacity = Double.random(in: 0...1)
            annotation.linePattern = String.randomASCII(withLength: .random(in: 0...100))
            annotation.lineWidth = Double.random(in: 0...100000)
            annotations.append(annotation)
        }
        let newLineCapProperty = LineCap.allCases.randomElement()!

        manager.annotations = annotations
        manager.lineCap = newLineCapProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-cap"])
    }

    func testSetToNilLineCap() {
        let newLineCapProperty = LineCap.allCases.randomElement()!
        let defaultValue = Style.layerPropertyDefaultValue(for: .line, property: "line-cap").value as! String
        manager.lineCap = newLineCapProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-cap"])

        manager.lineCap = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.lineCap)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-cap"] as! String, defaultValue)
    }

    func testInitialLineMiterLimit() {
        let initialValue = manager.lineMiterLimit
        XCTAssertNil(initialValue)
    }

    func testSetLineMiterLimit() {
        let value = Double.random(in: -100000...100000)
        manager.lineMiterLimit = value
        XCTAssertEqual(manager.lineMiterLimit, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-miter-limit"] as! Double, value)
    }

    func testLineMiterLimitAnnotationPropertiesAddedWithoutDuplicate() {
        let newLineMiterLimitProperty = Double.random(in: -100000...100000)
        let secondLineMiterLimitProperty = Double.random(in: -100000...100000)

        manager.lineMiterLimit = newLineMiterLimitProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.lineMiterLimit = secondLineMiterLimitProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-miter-limit"] as! Double, secondLineMiterLimitProperty)
    }

    func testNewLineMiterLimitPropertyMergedWithAnnotationProperties() {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotation.lineJoin = LineJoin.allCases.randomElement()!
            annotation.lineSortKey = Double.random(in: -100000...100000)
            annotation.lineBlur = Double.random(in: 0...100000)
            annotation.lineColor = StyleColor.random()
            annotation.lineGapWidth = Double.random(in: 0...100000)
            annotation.lineOffset = Double.random(in: -100000...100000)
            annotation.lineOpacity = Double.random(in: 0...1)
            annotation.linePattern = String.randomASCII(withLength: .random(in: 0...100))
            annotation.lineWidth = Double.random(in: 0...100000)
            annotations.append(annotation)
        }
        let newLineMiterLimitProperty = Double.random(in: -100000...100000)

        manager.annotations = annotations
        manager.lineMiterLimit = newLineMiterLimitProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-miter-limit"])
    }

    func testSetToNilLineMiterLimit() {
        let newLineMiterLimitProperty = Double.random(in: -100000...100000)
        let defaultValue = Style.layerPropertyDefaultValue(for: .line, property: "line-miter-limit").value as! Double
        manager.lineMiterLimit = newLineMiterLimitProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-miter-limit"])

        manager.lineMiterLimit = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.lineMiterLimit)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-miter-limit"] as! Double, defaultValue)
    }

    func testInitialLineRoundLimit() {
        let initialValue = manager.lineRoundLimit
        XCTAssertNil(initialValue)
    }

    func testSetLineRoundLimit() {
        let value = Double.random(in: -100000...100000)
        manager.lineRoundLimit = value
        XCTAssertEqual(manager.lineRoundLimit, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-round-limit"] as! Double, value)
    }

    func testLineRoundLimitAnnotationPropertiesAddedWithoutDuplicate() {
        let newLineRoundLimitProperty = Double.random(in: -100000...100000)
        let secondLineRoundLimitProperty = Double.random(in: -100000...100000)

        manager.lineRoundLimit = newLineRoundLimitProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.lineRoundLimit = secondLineRoundLimitProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-round-limit"] as! Double, secondLineRoundLimitProperty)
    }

    func testNewLineRoundLimitPropertyMergedWithAnnotationProperties() {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotation.lineJoin = LineJoin.allCases.randomElement()!
            annotation.lineSortKey = Double.random(in: -100000...100000)
            annotation.lineBlur = Double.random(in: 0...100000)
            annotation.lineColor = StyleColor.random()
            annotation.lineGapWidth = Double.random(in: 0...100000)
            annotation.lineOffset = Double.random(in: -100000...100000)
            annotation.lineOpacity = Double.random(in: 0...1)
            annotation.linePattern = String.randomASCII(withLength: .random(in: 0...100))
            annotation.lineWidth = Double.random(in: 0...100000)
            annotations.append(annotation)
        }
        let newLineRoundLimitProperty = Double.random(in: -100000...100000)

        manager.annotations = annotations
        manager.lineRoundLimit = newLineRoundLimitProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-round-limit"])
    }

    func testSetToNilLineRoundLimit() {
        let newLineRoundLimitProperty = Double.random(in: -100000...100000)
        let defaultValue = Style.layerPropertyDefaultValue(for: .line, property: "line-round-limit").value as! Double
        manager.lineRoundLimit = newLineRoundLimitProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-round-limit"])

        manager.lineRoundLimit = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.lineRoundLimit)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-round-limit"] as! Double, defaultValue)
    }

    func testInitialLineDasharray() {
        let initialValue = manager.lineDasharray
        XCTAssertNil(initialValue)
    }

    func testSetLineDasharray() {
        let value = Array.random(withLength: .random(in: 0...10), generator: { Double.random(in: -100000...100000) })
        manager.lineDasharray = value
        XCTAssertEqual(manager.lineDasharray, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-dasharray"] as! [Double], value)
    }

    func testLineDasharrayAnnotationPropertiesAddedWithoutDuplicate() {
        let newLineDasharrayProperty = Array.random(withLength: .random(in: 0...10), generator: { Double.random(in: -100000...100000) })
        let secondLineDasharrayProperty = Array.random(withLength: .random(in: 0...10), generator: { Double.random(in: -100000...100000) })

        manager.lineDasharray = newLineDasharrayProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.lineDasharray = secondLineDasharrayProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-dasharray"] as! [Double], secondLineDasharrayProperty)
    }

    func testNewLineDasharrayPropertyMergedWithAnnotationProperties() {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotation.lineJoin = LineJoin.allCases.randomElement()!
            annotation.lineSortKey = Double.random(in: -100000...100000)
            annotation.lineBlur = Double.random(in: 0...100000)
            annotation.lineColor = StyleColor.random()
            annotation.lineGapWidth = Double.random(in: 0...100000)
            annotation.lineOffset = Double.random(in: -100000...100000)
            annotation.lineOpacity = Double.random(in: 0...1)
            annotation.linePattern = String.randomASCII(withLength: .random(in: 0...100))
            annotation.lineWidth = Double.random(in: 0...100000)
            annotations.append(annotation)
        }
        let newLineDasharrayProperty = Array.random(withLength: .random(in: 0...10), generator: { Double.random(in: -100000...100000) })

        manager.annotations = annotations
        manager.lineDasharray = newLineDasharrayProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-dasharray"])
    }

    func testSetToNilLineDasharray() {
        let newLineDasharrayProperty = Array.random(withLength: .random(in: 0...10), generator: { Double.random(in: -100000...100000) })
        let defaultValue = Style.layerPropertyDefaultValue(for: .line, property: "line-dasharray").value as! [Double]
        manager.lineDasharray = newLineDasharrayProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-dasharray"])

        manager.lineDasharray = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.lineDasharray)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-dasharray"] as! [Double], defaultValue)
    }

    func testInitialLineTranslate() {
        let initialValue = manager.lineTranslate
        XCTAssertNil(initialValue)
    }

    func testSetLineTranslate() {
        let value = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        manager.lineTranslate = value
        XCTAssertEqual(manager.lineTranslate, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate"] as! [Double], value)
    }

    func testLineTranslateAnnotationPropertiesAddedWithoutDuplicate() {
        let newLineTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        let secondLineTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]

        manager.lineTranslate = newLineTranslateProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.lineTranslate = secondLineTranslateProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate"] as! [Double], secondLineTranslateProperty)
    }

    func testNewLineTranslatePropertyMergedWithAnnotationProperties() {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotation.lineJoin = LineJoin.allCases.randomElement()!
            annotation.lineSortKey = Double.random(in: -100000...100000)
            annotation.lineBlur = Double.random(in: 0...100000)
            annotation.lineColor = StyleColor.random()
            annotation.lineGapWidth = Double.random(in: 0...100000)
            annotation.lineOffset = Double.random(in: -100000...100000)
            annotation.lineOpacity = Double.random(in: 0...1)
            annotation.linePattern = String.randomASCII(withLength: .random(in: 0...100))
            annotation.lineWidth = Double.random(in: 0...100000)
            annotations.append(annotation)
        }
        let newLineTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]

        manager.annotations = annotations
        manager.lineTranslate = newLineTranslateProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate"])
    }

    func testSetToNilLineTranslate() {
        let newLineTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        let defaultValue = Style.layerPropertyDefaultValue(for: .line, property: "line-translate").value as! [Double]
        manager.lineTranslate = newLineTranslateProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate"])

        manager.lineTranslate = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.lineTranslate)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate"] as! [Double], defaultValue)
    }

    func testInitialLineTranslateAnchor() {
        let initialValue = manager.lineTranslateAnchor
        XCTAssertNil(initialValue)
    }

    func testSetLineTranslateAnchor() {
        let value = LineTranslateAnchor.allCases.randomElement()!
        manager.lineTranslateAnchor = value
        XCTAssertEqual(manager.lineTranslateAnchor, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate-anchor"] as! String, value.rawValue)
    }

    func testLineTranslateAnchorAnnotationPropertiesAddedWithoutDuplicate() {
        let newLineTranslateAnchorProperty = LineTranslateAnchor.allCases.randomElement()!
        let secondLineTranslateAnchorProperty = LineTranslateAnchor.allCases.randomElement()!

        manager.lineTranslateAnchor = newLineTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.lineTranslateAnchor = secondLineTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate-anchor"] as! String, secondLineTranslateAnchorProperty.rawValue)
    }

    func testNewLineTranslateAnchorPropertyMergedWithAnnotationProperties() {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotation.lineJoin = LineJoin.allCases.randomElement()!
            annotation.lineSortKey = Double.random(in: -100000...100000)
            annotation.lineBlur = Double.random(in: 0...100000)
            annotation.lineColor = StyleColor.random()
            annotation.lineGapWidth = Double.random(in: 0...100000)
            annotation.lineOffset = Double.random(in: -100000...100000)
            annotation.lineOpacity = Double.random(in: 0...1)
            annotation.linePattern = String.randomASCII(withLength: .random(in: 0...100))
            annotation.lineWidth = Double.random(in: 0...100000)
            annotations.append(annotation)
        }
        let newLineTranslateAnchorProperty = LineTranslateAnchor.allCases.randomElement()!

        manager.annotations = annotations
        manager.lineTranslateAnchor = newLineTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate-anchor"])
    }

    func testSetToNilLineTranslateAnchor() {
        let newLineTranslateAnchorProperty = LineTranslateAnchor.allCases.randomElement()!
        let defaultValue = Style.layerPropertyDefaultValue(for: .line, property: "line-translate-anchor").value as! String
        manager.lineTranslateAnchor = newLineTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate-anchor"])

        manager.lineTranslateAnchor = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.lineTranslateAnchor)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate-anchor"] as! String, defaultValue)
    }

    func testInitialLineTrimOffset() {
        let initialValue = manager.lineTrimOffset
        XCTAssertNil(initialValue)
    }

    func testSetLineTrimOffset() {
        let value = [Double.random(in: 0...1), Double.random(in: 0...1)].sorted()
        manager.lineTrimOffset = value
        XCTAssertEqual(manager.lineTrimOffset, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-trim-offset"] as! [Double], value)
    }

    func testLineTrimOffsetAnnotationPropertiesAddedWithoutDuplicate() {
        let newLineTrimOffsetProperty = [Double.random(in: 0...1), Double.random(in: 0...1)].sorted()
        let secondLineTrimOffsetProperty = [Double.random(in: 0...1), Double.random(in: 0...1)].sorted()

        manager.lineTrimOffset = newLineTrimOffsetProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.lineTrimOffset = secondLineTrimOffsetProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-trim-offset"] as! [Double], secondLineTrimOffsetProperty)
    }

    func testNewLineTrimOffsetPropertyMergedWithAnnotationProperties() {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotation.lineJoin = LineJoin.allCases.randomElement()!
            annotation.lineSortKey = Double.random(in: -100000...100000)
            annotation.lineBlur = Double.random(in: 0...100000)
            annotation.lineColor = StyleColor.random()
            annotation.lineGapWidth = Double.random(in: 0...100000)
            annotation.lineOffset = Double.random(in: -100000...100000)
            annotation.lineOpacity = Double.random(in: 0...1)
            annotation.linePattern = String.randomASCII(withLength: .random(in: 0...100))
            annotation.lineWidth = Double.random(in: 0...100000)
            annotations.append(annotation)
        }
        let newLineTrimOffsetProperty = [Double.random(in: 0...1), Double.random(in: 0...1)].sorted()

        manager.annotations = annotations
        manager.lineTrimOffset = newLineTrimOffsetProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-trim-offset"])
    }

    func testSetToNilLineTrimOffset() {
        let newLineTrimOffsetProperty = [Double.random(in: 0...1), Double.random(in: 0...1)].sorted()
        let defaultValue = Style.layerPropertyDefaultValue(for: .line, property: "line-trim-offset").value as! [Double]
        manager.lineTrimOffset = newLineTrimOffsetProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-trim-offset"])

        manager.lineTrimOffset = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.lineTrimOffset)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-trim-offset"] as! [Double], defaultValue)
    }

    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        self.delegateAnnotations = annotations
        expectation?.fulfill()
        expectation = nil
    }


    func testGetAnnotations() {
        let annotations = Array.random(withLength: 10) {
            PolylineAnnotation(lineCoordinates: [ CLLocationCoordinate2D(latitude: 0, longitude: 0), CLLocationCoordinate2D(latitude: 10, longitude: 10)], isSelected: false, isDraggable: true)
        }
        manager.annotations = annotations

        // Dragged annotation will be added to internal list of dragged annotations.
        let annotationToDrag = annotations.randomElement()!
        manager.handleDragBegin(with: [annotationToDrag.id])
        XCTAssertTrue(manager.annotations.contains(where: { $0.id == annotationToDrag.id }))
    }

    func testHandleDragBeginIsDraggableFalse() throws {
        manager.annotations = [
            PolylineAnnotation(id: "line1", lineCoordinates: [ CLLocationCoordinate2D(latitude: 0, longitude: 0), CLLocationCoordinate2D(latitude: 10, longitude: 10)], isSelected: false, isDraggable: false)
        ]

        style.addSourceStub.reset()
        style.addPersistentLayerWithPropertiesStub.reset()

        manager.handleDragBegin(with: ["line1"])

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 0)
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
            PolylineAnnotation(id: "line1", lineCoordinates: [ CLLocationCoordinate2D(latitude: 0, longitude: 0), CLLocationCoordinate2D(latitude: 10, longitude: 10)], isSelected: false, isDraggable: true)
        ]

        style.addSourceStub.reset()
        style.addPersistentLayerWithPropertiesStub.reset()

        manager.handleDragBegin(with: ["line1"])

        let addSourceParameters = try XCTUnwrap(style.addSourceStub.invocations.last).parameters
        let addLayerParameters = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.last).parameters
        let updateSourceParameters = try XCTUnwrap(style.updateGeoJSONSourceStub.invocations.last).parameters

        XCTAssertEqual(addLayerParameters.properties["source"] as? String, addSourceParameters.id)
        XCTAssertNotEqual(addLayerParameters.properties["id"] as? String, manager.layerId)

        XCTAssertTrue(updateSourceParameters.id == addSourceParameters.id)
    }

    func testHandleDragChanged() throws {
        mapboxMap.pointStub.defaultReturnValue = CGPoint(x: 0, y: 0)
        mapboxMap.coordinateForPointStub.defaultReturnValue = .random()
        mapboxMap.cameraState.zoom = 1

        let annotation = PolylineAnnotation(id: "line1", lineCoordinates: [ CLLocationCoordinate2D(latitude: 0, longitude: 0), CLLocationCoordinate2D(latitude: 10, longitude: 10)], isSelected: false, isDraggable: true)
        manager.annotations = [annotation]

        manager.handleDragChanged(with: .random())
        XCTAssertTrue(style.updateGeoJSONSourceStub.invocations.isEmpty)

        manager.handleDragBegin(with: ["line1"])
        let addSourceParameters = try XCTUnwrap(style.addSourceStub.invocations.last).parameters

        manager.handleDragChanged(with: .random())
        let updateSourceParameters = try XCTUnwrap(style.updateGeoJSONSourceStub.invocations.last).parameters
        XCTAssertTrue(updateSourceParameters.id == addSourceParameters.id)
        if case .featureCollection(let collection) = updateSourceParameters.geojson {
            XCTAssertTrue(collection.features.contains(where: { $0.identifier?.rawValue as? String == annotation.id }))
        } else {
            XCTFail("GeoJSONObject should be a feature collection")
        }
    }
}

// End of generated file
