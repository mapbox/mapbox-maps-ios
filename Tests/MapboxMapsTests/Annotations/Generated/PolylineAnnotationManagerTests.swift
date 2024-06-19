// This file is generated
import XCTest
@testable import MapboxMaps

final class PolylineAnnotationManagerTests: XCTestCase, AnnotationInteractionDelegate {
    var manager: PolylineAnnotationManager!
    var style: MockStyle!
    var id = UUID().uuidString
    var annotations = [PolylineAnnotation]()
    var expectation: XCTestExpectation?
    var delegateAnnotations: [Annotation]?
    var offsetCalculator: OffsetLineStringCalculator!
    var mapboxMap: MockMapboxMap!
    @TestSignal var displayLink: Signal<Void>

    override func setUp() {
        super.setUp()

        style = MockStyle()
        mapboxMap = MockMapboxMap()
        offsetCalculator = OffsetLineStringCalculator(mapboxMap: mapboxMap)
        manager = PolylineAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
            offsetCalculator: offsetCalculator
        )

        for _ in 0...10 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            let annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }
    }

    override func tearDown() {
        style = nil
        expectation = nil
        delegateAnnotations = nil
        mapboxMap = nil
        offsetCalculator = nil
        manager = nil

        super.tearDown()
    }

    func testSourceSetup() {
        style.addSourceStub.reset()

        _ = PolylineAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
            offsetCalculator: offsetCalculator
        )

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.source.type, SourceType.geoJson)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.source.id, manager.id)
    }

    func testAddLayer() throws {
        style.addSourceStub.reset()
        let initializedManager = PolylineAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
            offsetCalculator: offsetCalculator
        )

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.type, LayerType.line)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.id, initializedManager.id)
        let addedLayer = try XCTUnwrap(style.addPersistentLayerStub.invocations.last?.parameters.layer as? LineLayer)
        XCTAssertEqual(addedLayer.source, initializedManager.sourceId)
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
            displayLink: displayLink,
            offsetCalculator: offsetCalculator
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
            displayLink: displayLink,
            offsetCalculator: offsetCalculator
        )
        manager3.annotations = annotations

        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layerPosition, LayerPosition.at(4))
    }

    func testDestroy() {
        manager.destroy()

        XCTAssertEqual(style.removeLayerStub.invocations.map(\.parameters), [id])
        XCTAssertEqual(style.removeSourceStub.invocations.map(\.parameters), [id])

        style.removeLayerStub.reset()
        style.removeSourceStub.reset()

        manager.destroy()
        XCTAssertTrue(style.removeLayerStub.invocations.isEmpty)
        XCTAssertTrue(style.removeSourceStub.invocations.isEmpty)
    }

    func testDestroyManagerWithDraggedAnnotations() {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.isDraggable = true
        manager.annotations = [annotation]
        // adds drag source/layer
        _ = manager.handleDragBegin(with: annotation.id, context: .zero)

        manager.destroy()

        XCTAssertEqual(style.removeLayerStub.invocations.map(\.parameters), [id, id + "_drag"])
        XCTAssertEqual(style.removeSourceStub.invocations.map(\.parameters), [id, id + "_drag"])

        style.removeLayerStub.reset()
        style.removeSourceStub.reset()

        manager.destroy()
        XCTAssertTrue(style.removeLayerStub.invocations.isEmpty)
        XCTAssertTrue(style.removeSourceStub.invocations.isEmpty)
    }

    func testSyncSourceAndLayer() {
        manager.annotations = annotations
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
    }

    func testDoNotSyncSourceAndLayerWhenNotNeeded() {
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 0)
    }

    func testFeatureCollectionPassedtoGeoJSON() throws {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            let annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }
        let expectedFeatures = annotations.map(\.feature)

        manager.annotations = annotations
        $displayLink.send()

        var invocation = try XCTUnwrap(style.addGeoJSONSourceFeaturesStub.invocations.last)
        XCTAssertEqual(invocation.parameters.features, expectedFeatures)
        XCTAssertEqual(invocation.parameters.sourceId, manager.id)

        do {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            let annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotations.append(annotation)

            manager.annotations = annotations
            $displayLink.send()

            invocation = try XCTUnwrap(style.addGeoJSONSourceFeaturesStub.invocations.last)
            XCTAssertEqual(invocation.parameters.features, [annotation].map(\.feature))
            XCTAssertEqual(invocation.parameters.sourceId, manager.id)
        }
    }

    @available(*, deprecated)
    func testHandleTap() throws {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            let annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }
        var taps = [MapContentGestureContext]()
        annotations[0].tapHandler = { context in
            taps.append(context)
            return true
        }
        annotations[1].tapHandler = { _ in
            return false // skips handling
        }
        manager.delegate = self

        manager.annotations = annotations

        // first annotation, handles tap
        let context = MapContentGestureContext(point: .init(x: 1, y: 2), coordinate: .init(latitude: 3, longitude: 4))
        var handled = manager.handleTap(layerId: "layerId", feature: annotations[0].feature, context: context)

        var result = try XCTUnwrap(delegateAnnotations)
        XCTAssertEqual(result[0].id, annotations[0].id)
        XCTAssertEqual(handled, true)

        XCTAssertEqual(taps.count, 1)
        XCTAssertEqual(taps.first?.point, context.point)
        XCTAssertEqual(taps.first?.coordinate, context.coordinate)

        // second annotation, skips handling tap
        delegateAnnotations = nil
        handled = manager.handleTap(layerId: "layerId", feature: annotations[1].feature, context: context)

        result = try XCTUnwrap(delegateAnnotations)
        XCTAssertEqual(result[0].id, annotations[1].id)
        XCTAssertEqual(handled, false)

        // invalid id
        delegateAnnotations = nil
        let invalidFeature = Feature(geometry: nil)
        handled = manager.handleTap(layerId: "layerId", feature: invalidFeature, context: context)

        XCTAssertNil(delegateAnnotations)
        XCTAssertEqual(handled, false)
        XCTAssertEqual(taps.count, 1)
    }

    func testInitialLineCap() {
        let initialValue = manager.lineCap
        XCTAssertNil(initialValue)
    }

    func testSetLineCap() {
        let value = LineCap.testConstantValue()
        manager.lineCap = value
        XCTAssertEqual(manager.lineCap, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-cap"] as! String, value.rawValue)
    }

    func testLineCapAnnotationPropertiesAddedWithoutDuplicate() {
        let newLineCapProperty = LineCap.testConstantValue()
        let secondLineCapProperty = LineCap.testConstantValue()

        manager.lineCap = newLineCapProperty
        $displayLink.send()
        manager.lineCap = secondLineCapProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-cap"] as! String, secondLineCapProperty.rawValue)
    }

    func testNewLineCapPropertyMergedWithAnnotationProperties() {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotation.lineJoin = LineJoin.testConstantValue()
            annotation.lineSortKey = 0.0
            annotation.lineZOffset = 0.0
            annotation.lineBlur = 50000.0
            annotation.lineBorderColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineBorderWidth = 50000.0
            annotation.lineColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineGapWidth = 50000.0
            annotation.lineOffset = 0.0
            annotation.lineOpacity = 0.5
            annotation.linePattern = UUID().uuidString
            annotation.lineWidth = 50000.0
            annotations.append(annotation)
        }
        let newLineCapProperty = LineCap.testConstantValue()

        manager.annotations = annotations
        manager.lineCap = newLineCapProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-cap"])
    }

    func testSetToNilLineCap() {
        let newLineCapProperty = LineCap.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-cap").value as! String
        manager.lineCap = newLineCapProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-cap"])

        manager.lineCap = nil
        $displayLink.send()
        XCTAssertNil(manager.lineCap)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-cap"] as! String, defaultValue)
    }

    func testInitialLineMiterLimit() {
        let initialValue = manager.lineMiterLimit
        XCTAssertNil(initialValue)
    }

    func testSetLineMiterLimit() {
        let value = 0.0
        manager.lineMiterLimit = value
        XCTAssertEqual(manager.lineMiterLimit, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-miter-limit"] as! Double, value)
    }

    func testLineMiterLimitAnnotationPropertiesAddedWithoutDuplicate() {
        let newLineMiterLimitProperty = 0.0
        let secondLineMiterLimitProperty = 0.0

        manager.lineMiterLimit = newLineMiterLimitProperty
        $displayLink.send()
        manager.lineMiterLimit = secondLineMiterLimitProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-miter-limit"] as! Double, secondLineMiterLimitProperty)
    }

    func testNewLineMiterLimitPropertyMergedWithAnnotationProperties() {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotation.lineJoin = LineJoin.testConstantValue()
            annotation.lineSortKey = 0.0
            annotation.lineZOffset = 0.0
            annotation.lineBlur = 50000.0
            annotation.lineBorderColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineBorderWidth = 50000.0
            annotation.lineColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineGapWidth = 50000.0
            annotation.lineOffset = 0.0
            annotation.lineOpacity = 0.5
            annotation.linePattern = UUID().uuidString
            annotation.lineWidth = 50000.0
            annotations.append(annotation)
        }
        let newLineMiterLimitProperty = 0.0

        manager.annotations = annotations
        manager.lineMiterLimit = newLineMiterLimitProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-miter-limit"])
    }

    func testSetToNilLineMiterLimit() {
        let newLineMiterLimitProperty = 0.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-miter-limit").value as! Double
        manager.lineMiterLimit = newLineMiterLimitProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-miter-limit"])

        manager.lineMiterLimit = nil
        $displayLink.send()
        XCTAssertNil(manager.lineMiterLimit)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-miter-limit"] as! Double, defaultValue)
    }

    func testInitialLineRoundLimit() {
        let initialValue = manager.lineRoundLimit
        XCTAssertNil(initialValue)
    }

    func testSetLineRoundLimit() {
        let value = 0.0
        manager.lineRoundLimit = value
        XCTAssertEqual(manager.lineRoundLimit, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-round-limit"] as! Double, value)
    }

    func testLineRoundLimitAnnotationPropertiesAddedWithoutDuplicate() {
        let newLineRoundLimitProperty = 0.0
        let secondLineRoundLimitProperty = 0.0

        manager.lineRoundLimit = newLineRoundLimitProperty
        $displayLink.send()
        manager.lineRoundLimit = secondLineRoundLimitProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-round-limit"] as! Double, secondLineRoundLimitProperty)
    }

    func testNewLineRoundLimitPropertyMergedWithAnnotationProperties() {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotation.lineJoin = LineJoin.testConstantValue()
            annotation.lineSortKey = 0.0
            annotation.lineZOffset = 0.0
            annotation.lineBlur = 50000.0
            annotation.lineBorderColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineBorderWidth = 50000.0
            annotation.lineColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineGapWidth = 50000.0
            annotation.lineOffset = 0.0
            annotation.lineOpacity = 0.5
            annotation.linePattern = UUID().uuidString
            annotation.lineWidth = 50000.0
            annotations.append(annotation)
        }
        let newLineRoundLimitProperty = 0.0

        manager.annotations = annotations
        manager.lineRoundLimit = newLineRoundLimitProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-round-limit"])
    }

    func testSetToNilLineRoundLimit() {
        let newLineRoundLimitProperty = 0.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-round-limit").value as! Double
        manager.lineRoundLimit = newLineRoundLimitProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-round-limit"])

        manager.lineRoundLimit = nil
        $displayLink.send()
        XCTAssertNil(manager.lineRoundLimit)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-round-limit"] as! Double, defaultValue)
    }

    func testInitialLineDasharray() {
        let initialValue = manager.lineDasharray
        XCTAssertNil(initialValue)
    }

    func testSetLineDasharray() {
        let value = Array.random(withLength: .random(in: 0...10), generator: { 0.0 })
        manager.lineDasharray = value
        XCTAssertEqual(manager.lineDasharray, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-dasharray"] as! [Double], value)
    }

    func testLineDasharrayAnnotationPropertiesAddedWithoutDuplicate() {
        let newLineDasharrayProperty = Array.random(withLength: .random(in: 0...10), generator: { 0.0 })
        let secondLineDasharrayProperty = Array.random(withLength: .random(in: 0...10), generator: { 0.0 })

        manager.lineDasharray = newLineDasharrayProperty
        $displayLink.send()
        manager.lineDasharray = secondLineDasharrayProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-dasharray"] as! [Double], secondLineDasharrayProperty)
    }

    func testNewLineDasharrayPropertyMergedWithAnnotationProperties() {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotation.lineJoin = LineJoin.testConstantValue()
            annotation.lineSortKey = 0.0
            annotation.lineZOffset = 0.0
            annotation.lineBlur = 50000.0
            annotation.lineBorderColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineBorderWidth = 50000.0
            annotation.lineColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineGapWidth = 50000.0
            annotation.lineOffset = 0.0
            annotation.lineOpacity = 0.5
            annotation.linePattern = UUID().uuidString
            annotation.lineWidth = 50000.0
            annotations.append(annotation)
        }
        let newLineDasharrayProperty = Array.random(withLength: .random(in: 0...10), generator: { 0.0 })

        manager.annotations = annotations
        manager.lineDasharray = newLineDasharrayProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-dasharray"])
    }

    func testSetToNilLineDasharray() {
        let newLineDasharrayProperty = Array.random(withLength: .random(in: 0...10), generator: { 0.0 })
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-dasharray").value as! [Double]
        manager.lineDasharray = newLineDasharrayProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-dasharray"])

        manager.lineDasharray = nil
        $displayLink.send()
        XCTAssertNil(manager.lineDasharray)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-dasharray"] as! [Double], defaultValue)
    }

    func testInitialLineDepthOcclusionFactor() {
        let initialValue = manager.lineDepthOcclusionFactor
        XCTAssertNil(initialValue)
    }

    func testSetLineDepthOcclusionFactor() {
        let value = 0.5
        manager.lineDepthOcclusionFactor = value
        XCTAssertEqual(manager.lineDepthOcclusionFactor, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-depth-occlusion-factor"] as! Double, value)
    }

    func testLineDepthOcclusionFactorAnnotationPropertiesAddedWithoutDuplicate() {
        let newLineDepthOcclusionFactorProperty = 0.5
        let secondLineDepthOcclusionFactorProperty = 0.5

        manager.lineDepthOcclusionFactor = newLineDepthOcclusionFactorProperty
        $displayLink.send()
        manager.lineDepthOcclusionFactor = secondLineDepthOcclusionFactorProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-depth-occlusion-factor"] as! Double, secondLineDepthOcclusionFactorProperty)
    }

    func testNewLineDepthOcclusionFactorPropertyMergedWithAnnotationProperties() {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotation.lineJoin = LineJoin.testConstantValue()
            annotation.lineSortKey = 0.0
            annotation.lineZOffset = 0.0
            annotation.lineBlur = 50000.0
            annotation.lineBorderColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineBorderWidth = 50000.0
            annotation.lineColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineGapWidth = 50000.0
            annotation.lineOffset = 0.0
            annotation.lineOpacity = 0.5
            annotation.linePattern = UUID().uuidString
            annotation.lineWidth = 50000.0
            annotations.append(annotation)
        }
        let newLineDepthOcclusionFactorProperty = 0.5

        manager.annotations = annotations
        manager.lineDepthOcclusionFactor = newLineDepthOcclusionFactorProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-depth-occlusion-factor"])
    }

    func testSetToNilLineDepthOcclusionFactor() {
        let newLineDepthOcclusionFactorProperty = 0.5
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-depth-occlusion-factor").value as! Double
        manager.lineDepthOcclusionFactor = newLineDepthOcclusionFactorProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-depth-occlusion-factor"])

        manager.lineDepthOcclusionFactor = nil
        $displayLink.send()
        XCTAssertNil(manager.lineDepthOcclusionFactor)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-depth-occlusion-factor"] as! Double, defaultValue)
    }

    func testInitialLineEmissiveStrength() {
        let initialValue = manager.lineEmissiveStrength
        XCTAssertNil(initialValue)
    }

    func testSetLineEmissiveStrength() {
        let value = 50000.0
        manager.lineEmissiveStrength = value
        XCTAssertEqual(manager.lineEmissiveStrength, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-emissive-strength"] as! Double, value)
    }

    func testLineEmissiveStrengthAnnotationPropertiesAddedWithoutDuplicate() {
        let newLineEmissiveStrengthProperty = 50000.0
        let secondLineEmissiveStrengthProperty = 50000.0

        manager.lineEmissiveStrength = newLineEmissiveStrengthProperty
        $displayLink.send()
        manager.lineEmissiveStrength = secondLineEmissiveStrengthProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-emissive-strength"] as! Double, secondLineEmissiveStrengthProperty)
    }

    func testNewLineEmissiveStrengthPropertyMergedWithAnnotationProperties() {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotation.lineJoin = LineJoin.testConstantValue()
            annotation.lineSortKey = 0.0
            annotation.lineZOffset = 0.0
            annotation.lineBlur = 50000.0
            annotation.lineBorderColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineBorderWidth = 50000.0
            annotation.lineColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineGapWidth = 50000.0
            annotation.lineOffset = 0.0
            annotation.lineOpacity = 0.5
            annotation.linePattern = UUID().uuidString
            annotation.lineWidth = 50000.0
            annotations.append(annotation)
        }
        let newLineEmissiveStrengthProperty = 50000.0

        manager.annotations = annotations
        manager.lineEmissiveStrength = newLineEmissiveStrengthProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-emissive-strength"])
    }

    func testSetToNilLineEmissiveStrength() {
        let newLineEmissiveStrengthProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-emissive-strength").value as! Double
        manager.lineEmissiveStrength = newLineEmissiveStrengthProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-emissive-strength"])

        manager.lineEmissiveStrength = nil
        $displayLink.send()
        XCTAssertNil(manager.lineEmissiveStrength)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-emissive-strength"] as! Double, defaultValue)
    }

    func testInitialLineOcclusionOpacity() {
        let initialValue = manager.lineOcclusionOpacity
        XCTAssertNil(initialValue)
    }

    func testSetLineOcclusionOpacity() {
        let value = 0.5
        manager.lineOcclusionOpacity = value
        XCTAssertEqual(manager.lineOcclusionOpacity, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-occlusion-opacity"] as! Double, value)
    }

    func testLineOcclusionOpacityAnnotationPropertiesAddedWithoutDuplicate() {
        let newLineOcclusionOpacityProperty = 0.5
        let secondLineOcclusionOpacityProperty = 0.5

        manager.lineOcclusionOpacity = newLineOcclusionOpacityProperty
        $displayLink.send()
        manager.lineOcclusionOpacity = secondLineOcclusionOpacityProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-occlusion-opacity"] as! Double, secondLineOcclusionOpacityProperty)
    }

    func testNewLineOcclusionOpacityPropertyMergedWithAnnotationProperties() {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotation.lineJoin = LineJoin.testConstantValue()
            annotation.lineSortKey = 0.0
            annotation.lineZOffset = 0.0
            annotation.lineBlur = 50000.0
            annotation.lineBorderColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineBorderWidth = 50000.0
            annotation.lineColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineGapWidth = 50000.0
            annotation.lineOffset = 0.0
            annotation.lineOpacity = 0.5
            annotation.linePattern = UUID().uuidString
            annotation.lineWidth = 50000.0
            annotations.append(annotation)
        }
        let newLineOcclusionOpacityProperty = 0.5

        manager.annotations = annotations
        manager.lineOcclusionOpacity = newLineOcclusionOpacityProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-occlusion-opacity"])
    }

    func testSetToNilLineOcclusionOpacity() {
        let newLineOcclusionOpacityProperty = 0.5
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-occlusion-opacity").value as! Double
        manager.lineOcclusionOpacity = newLineOcclusionOpacityProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-occlusion-opacity"])

        manager.lineOcclusionOpacity = nil
        $displayLink.send()
        XCTAssertNil(manager.lineOcclusionOpacity)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-occlusion-opacity"] as! Double, defaultValue)
    }

    func testInitialLineTranslate() {
        let initialValue = manager.lineTranslate
        XCTAssertNil(initialValue)
    }

    func testSetLineTranslate() {
        let value = [0.0, 0.0]
        manager.lineTranslate = value
        XCTAssertEqual(manager.lineTranslate, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate"] as! [Double], value)
    }

    func testLineTranslateAnnotationPropertiesAddedWithoutDuplicate() {
        let newLineTranslateProperty = [0.0, 0.0]
        let secondLineTranslateProperty = [0.0, 0.0]

        manager.lineTranslate = newLineTranslateProperty
        $displayLink.send()
        manager.lineTranslate = secondLineTranslateProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate"] as! [Double], secondLineTranslateProperty)
    }

    func testNewLineTranslatePropertyMergedWithAnnotationProperties() {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotation.lineJoin = LineJoin.testConstantValue()
            annotation.lineSortKey = 0.0
            annotation.lineZOffset = 0.0
            annotation.lineBlur = 50000.0
            annotation.lineBorderColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineBorderWidth = 50000.0
            annotation.lineColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineGapWidth = 50000.0
            annotation.lineOffset = 0.0
            annotation.lineOpacity = 0.5
            annotation.linePattern = UUID().uuidString
            annotation.lineWidth = 50000.0
            annotations.append(annotation)
        }
        let newLineTranslateProperty = [0.0, 0.0]

        manager.annotations = annotations
        manager.lineTranslate = newLineTranslateProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate"])
    }

    func testSetToNilLineTranslate() {
        let newLineTranslateProperty = [0.0, 0.0]
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-translate").value as! [Double]
        manager.lineTranslate = newLineTranslateProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate"])

        manager.lineTranslate = nil
        $displayLink.send()
        XCTAssertNil(manager.lineTranslate)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate"] as! [Double], defaultValue)
    }

    func testInitialLineTranslateAnchor() {
        let initialValue = manager.lineTranslateAnchor
        XCTAssertNil(initialValue)
    }

    func testSetLineTranslateAnchor() {
        let value = LineTranslateAnchor.testConstantValue()
        manager.lineTranslateAnchor = value
        XCTAssertEqual(manager.lineTranslateAnchor, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate-anchor"] as! String, value.rawValue)
    }

    func testLineTranslateAnchorAnnotationPropertiesAddedWithoutDuplicate() {
        let newLineTranslateAnchorProperty = LineTranslateAnchor.testConstantValue()
        let secondLineTranslateAnchorProperty = LineTranslateAnchor.testConstantValue()

        manager.lineTranslateAnchor = newLineTranslateAnchorProperty
        $displayLink.send()
        manager.lineTranslateAnchor = secondLineTranslateAnchorProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate-anchor"] as! String, secondLineTranslateAnchorProperty.rawValue)
    }

    func testNewLineTranslateAnchorPropertyMergedWithAnnotationProperties() {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotation.lineJoin = LineJoin.testConstantValue()
            annotation.lineSortKey = 0.0
            annotation.lineZOffset = 0.0
            annotation.lineBlur = 50000.0
            annotation.lineBorderColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineBorderWidth = 50000.0
            annotation.lineColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineGapWidth = 50000.0
            annotation.lineOffset = 0.0
            annotation.lineOpacity = 0.5
            annotation.linePattern = UUID().uuidString
            annotation.lineWidth = 50000.0
            annotations.append(annotation)
        }
        let newLineTranslateAnchorProperty = LineTranslateAnchor.testConstantValue()

        manager.annotations = annotations
        manager.lineTranslateAnchor = newLineTranslateAnchorProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate-anchor"])
    }

    func testSetToNilLineTranslateAnchor() {
        let newLineTranslateAnchorProperty = LineTranslateAnchor.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-translate-anchor").value as! String
        manager.lineTranslateAnchor = newLineTranslateAnchorProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate-anchor"])

        manager.lineTranslateAnchor = nil
        $displayLink.send()
        XCTAssertNil(manager.lineTranslateAnchor)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate-anchor"] as! String, defaultValue)
    }

    func testInitialLineTrimOffset() {
        let initialValue = manager.lineTrimOffset
        XCTAssertNil(initialValue)
    }

    func testSetLineTrimOffset() {
        let value = [0.5, 0.5].sorted()
        manager.lineTrimOffset = value
        XCTAssertEqual(manager.lineTrimOffset, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-trim-offset"] as! [Double], value)
    }

    func testLineTrimOffsetAnnotationPropertiesAddedWithoutDuplicate() {
        let newLineTrimOffsetProperty = [0.5, 0.5].sorted()
        let secondLineTrimOffsetProperty = [0.5, 0.5].sorted()

        manager.lineTrimOffset = newLineTrimOffsetProperty
        $displayLink.send()
        manager.lineTrimOffset = secondLineTrimOffsetProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-trim-offset"] as! [Double], secondLineTrimOffsetProperty)
    }

    func testNewLineTrimOffsetPropertyMergedWithAnnotationProperties() {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotation.lineJoin = LineJoin.testConstantValue()
            annotation.lineSortKey = 0.0
            annotation.lineZOffset = 0.0
            annotation.lineBlur = 50000.0
            annotation.lineBorderColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineBorderWidth = 50000.0
            annotation.lineColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineGapWidth = 50000.0
            annotation.lineOffset = 0.0
            annotation.lineOpacity = 0.5
            annotation.linePattern = UUID().uuidString
            annotation.lineWidth = 50000.0
            annotations.append(annotation)
        }
        let newLineTrimOffsetProperty = [0.5, 0.5].sorted()

        manager.annotations = annotations
        manager.lineTrimOffset = newLineTrimOffsetProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-trim-offset"])
    }

    func testSetToNilLineTrimOffset() {
        let newLineTrimOffsetProperty = [0.5, 0.5].sorted()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-trim-offset").value as! [Double]
        manager.lineTrimOffset = newLineTrimOffsetProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-trim-offset"])

        manager.lineTrimOffset = nil
        $displayLink.send()
        XCTAssertNil(manager.lineTrimOffset)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-trim-offset"] as! [Double], defaultValue)
    }

    func testInitialSlot() {
        let initialValue = manager.slot
        XCTAssertNil(initialValue)
    }

    func testSetSlot() {
        let value = UUID().uuidString
        manager.slot = value
        XCTAssertEqual(manager.slot, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["slot"] as! String, value)
    }

    func testSlotAnnotationPropertiesAddedWithoutDuplicate() {
        let newSlotProperty = UUID().uuidString
        let secondSlotProperty = UUID().uuidString

        manager.slot = newSlotProperty
        $displayLink.send()
        manager.slot = secondSlotProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["slot"] as! String, secondSlotProperty)
    }

    func testNewSlotPropertyMergedWithAnnotationProperties() {
        var annotations = [PolylineAnnotation]()
        for _ in 0...5 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotation.lineJoin = LineJoin.testConstantValue()
            annotation.lineSortKey = 0.0
            annotation.lineZOffset = 0.0
            annotation.lineBlur = 50000.0
            annotation.lineBorderColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineBorderWidth = 50000.0
            annotation.lineColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.lineGapWidth = 50000.0
            annotation.lineOffset = 0.0
            annotation.lineOpacity = 0.5
            annotation.linePattern = UUID().uuidString
            annotation.lineWidth = 50000.0
            annotations.append(annotation)
        }
        let newSlotProperty = UUID().uuidString

        manager.annotations = annotations
        manager.slot = newSlotProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["slot"])
    }

    func testSetToNilSlot() {
        let newSlotProperty = UUID().uuidString
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "slot").value as! String
        manager.slot = newSlotProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["slot"])

        manager.slot = nil
        $displayLink.send()
        XCTAssertNil(manager.slot)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["slot"] as! String, defaultValue)
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
        _ = manager.handleDragBegin(with: annotationToDrag.id, context: .zero)
        XCTAssertTrue(manager.annotations.contains(where: { $0.id == annotationToDrag.id }))
    }

    func testHandleDragBeginIsDraggableFalse() throws {
        manager.annotations = [
            PolylineAnnotation(id: "polyline1", lineCoordinates: [ CLLocationCoordinate2D(latitude: 0, longitude: 0), CLLocationCoordinate2D(latitude: 10, longitude: 10)], isSelected: false, isDraggable: false)
        ]

        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()

        _ = manager.handleDragBegin(with: "polyline1", context: .zero)

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
    }
    func testHandleDragBeginInvalidFeatureId() {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()

        _ = manager.handleDragBegin(with: "not-a-feature", context: .zero)

        XCTAssertTrue(style.addSourceStub.invocations.isEmpty)
        XCTAssertTrue(style.addPersistentLayerStub.invocations.isEmpty)
    }

    func testDrag() throws {
        let annotation = PolylineAnnotation(id: "polyline1", lineCoordinates: [ CLLocationCoordinate2D(latitude: 0, longitude: 0), CLLocationCoordinate2D(latitude: 10, longitude: 10)], isSelected: false, isDraggable: true)
        manager.annotations = [annotation]

        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        _ = manager.handleDragBegin(with: "polyline1", context: .zero)

        let addSourceParameters = try XCTUnwrap(style.addSourceStub.invocations.last).parameters
        let addLayerParameters = try XCTUnwrap(style.addPersistentLayerStub.invocations.last).parameters

        let addedLayer = try XCTUnwrap(addLayerParameters.layer as? LineLayer)
        XCTAssertEqual(addedLayer.source, addSourceParameters.source.id)
        XCTAssertEqual(addLayerParameters.layerPosition, .above(manager.id))
        XCTAssertEqual(addedLayer.id, manager.id + "_drag")

        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 0)
        $displayLink.send()
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.last?.parameters.id, "\(manager.id)_drag")

        _ = manager.handleDragBegin(with: "polyline1", context: .zero)

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 1)

        mapboxMap.pointStub.defaultReturnValue = CGPoint(x: 0, y: 0)
        mapboxMap.coordinateForPointStub.defaultReturnValue = .init(latitude: 0, longitude: 0)
        mapboxMap.cameraState.zoom = 1

        manager.handleDragChange(with: .zero, context: .zero)

        $displayLink.send()

        let updateSourceParameters = try XCTUnwrap(style.updateGeoJSONSourceStub.invocations.last).parameters
        XCTAssertTrue(updateSourceParameters.id == addSourceParameters.source.id)
        if case .featureCollection(let collection) = updateSourceParameters.geojson {
            XCTAssertTrue(collection.features.contains(where: { $0.identifier?.rawValue as? String == annotation.id }))
        } else {
            XCTFail("GeoJSONObject should be a feature collection")
        }
    }

    func testDragHandlers() throws {
        struct GestureData {
            var annotation: PolylineAnnotation
            var context: MapContentGestureContext
        }

        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.isDraggable = true

        let beginDragStub = Stub<GestureData, Bool>(defaultReturnValue: false)
        let changeDragStub = Stub<GestureData, Void>()
        let endDragStub = Stub<GestureData, Void>()
        annotation.dragBeginHandler = { annotation, context in
            beginDragStub.call(with: GestureData(annotation: annotation, context: context))
        }
        annotation.dragChangeHandler = { annotation, context in
            changeDragStub.call(with: GestureData(annotation: annotation, context: context))
        }
        annotation.dragEndHandler = { annotation, context in
            endDragStub.call(with: GestureData(annotation: annotation, context: context))
        }
        manager.annotations = [annotation]

        mapboxMap.pointStub.defaultReturnValue = CGPoint(x: 0, y: 0)
        mapboxMap.coordinateForPointStub.defaultReturnValue = .init(latitude: 23.5432356, longitude: -12.5326744)
        mapboxMap.cameraState.zoom = 1

        var context = MapContentGestureContext(point: CGPoint(x: 0, y: 1), coordinate: .init(latitude: 2, longitude: 3))

        // test it twice to cover the case when annotation was already on drag layer.
        for _ in 0...1 {
            beginDragStub.reset()
            changeDragStub.reset()
            endDragStub.reset()

            // skipped gesture
            beginDragStub.defaultReturnValue = false
            var res = manager.handleDragBegin(with: annotation.id, context: context)
            XCTAssertEqual(beginDragStub.invocations.count, 1)
            XCTAssertEqual(res, false)
            var data = try XCTUnwrap(beginDragStub.invocations.last).parameters
            XCTAssertEqual(data.annotation.id, annotation.id)
            XCTAssertEqual(data.context.point, context.point)
            XCTAssertEqual(data.context.coordinate, context.coordinate)

            manager.handleDragChange(with: CGPoint(x: 10, y: 20), context: context)
            manager.handleDragEnd(context: context)
            XCTAssertEqual(changeDragStub.invocations.count, 0)
            XCTAssertEqual(endDragStub.invocations.count, 0)

            // handled gesture
            context.point.x += 1
            context.coordinate.latitude += 1
            beginDragStub.defaultReturnValue = true
            res = manager.handleDragBegin(with: annotation.id, context: context)
            XCTAssertEqual(beginDragStub.invocations.count, 2)
            XCTAssertEqual(res, true)
            data = try XCTUnwrap(beginDragStub.invocations.last).parameters
            XCTAssertEqual(data.annotation.id, annotation.id)
            XCTAssertEqual(data.context.point, context.point)
            XCTAssertEqual(data.context.coordinate, context.coordinate)

            context.point.x += 1
            context.coordinate.latitude += 1
            manager.handleDragChange(with: CGPoint(x: 10, y: 20), context: context)
            XCTAssertEqual(changeDragStub.invocations.count, 1)
            data = try XCTUnwrap(changeDragStub.invocations.last).parameters
            XCTAssertEqual(data.annotation.id, annotation.id)
            XCTAssertEqual(data.context.point, context.point)
            XCTAssertEqual(data.context.coordinate, context.coordinate)

            context.point.x += 1
            context.coordinate.latitude += 1
            manager.handleDragEnd(context: context)
            XCTAssertEqual(endDragStub.invocations.count, 1)
            data = try XCTUnwrap(endDragStub.invocations.last).parameters
            XCTAssertEqual(data.annotation.id, annotation.id)
            XCTAssertEqual(data.context.point, context.point)
            XCTAssertEqual(data.context.coordinate, context.coordinate)
        }
    }

    func testDoesNotUpdateDragSourceWhenNoDragged() {
        let annotation = PolylineAnnotation(id: "polyline1", lineCoordinates: [ CLLocationCoordinate2D(latitude: 0, longitude: 0), CLLocationCoordinate2D(latitude: 10, longitude: 10)], isSelected: false, isDraggable: true)
        manager.annotations = [annotation]
        $displayLink.send()
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 0)
    }

    func testRemovingDuplicatedAnnotations() {
      let lineCoordinates1 = [ CLLocationCoordinate2DMake(1, 1), CLLocationCoordinate2DMake(11, 11) ]
            let annotation1 = PolylineAnnotation(id: "A", lineString: .init(lineCoordinates1), isSelected: false, isDraggable: false)
      let lineCoordinates2 = [ CLLocationCoordinate2DMake(2, 2), CLLocationCoordinate2DMake(12, 12) ]
            let annotation2 = PolylineAnnotation(id: "B", lineString: .init(lineCoordinates2), isSelected: false, isDraggable: false)
      let lineCoordinates3 = [ CLLocationCoordinate2DMake(3, 3), CLLocationCoordinate2DMake(13, 13) ]
            let annotation3 = PolylineAnnotation(id: "A", lineString: .init(lineCoordinates3), isSelected: false, isDraggable: false)
      manager.annotations = [annotation1, annotation2, annotation3]

      XCTAssertEqual(manager.annotations, [
          annotation1,
          annotation2
      ])
    }

    func testSetNewAnnotations() {
      let lineCoordinates1 = [ CLLocationCoordinate2DMake(1, 1), CLLocationCoordinate2DMake(11, 11) ]
            let annotation1 = PolylineAnnotation(id: "A", lineString: .init(lineCoordinates1), isSelected: false, isDraggable: false)
      let lineCoordinates2 = [ CLLocationCoordinate2DMake(2, 2), CLLocationCoordinate2DMake(12, 12) ]
            let annotation2 = PolylineAnnotation(id: "B", lineString: .init(lineCoordinates2), isSelected: false, isDraggable: false)
      let lineCoordinates3 = [ CLLocationCoordinate2DMake(3, 3), CLLocationCoordinate2DMake(13, 13) ]
            let annotation3 = PolylineAnnotation(id: "C", lineString: .init(lineCoordinates3), isSelected: false, isDraggable: false)

        manager.set(newAnnotations: [
            (1, annotation1),
            (2, annotation2)
        ])

        XCTAssertEqual(manager.annotations.map(\.id), ["A", "B"])

        manager.set(newAnnotations: [
            (1, annotation3),
            (2, annotation2)
        ])

        XCTAssertEqual(manager.annotations.map(\.id), ["A", "B"])

        manager.set(newAnnotations: [
            (3, annotation3),
            (2, annotation2)
        ])

        XCTAssertEqual(manager.annotations.map(\.id), ["C", "B"])
    }
}

// End of generated file
