// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class CircleLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

       var layer = CircleLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       XCTAssert(layer.id == "test-id")
       XCTAssert(layer.type == LayerType.circle)
       XCTAssert(layer.filter == nil)
       XCTAssert(layer.source == "some-source")
       XCTAssertNil(layer.sourceLayer)
       XCTAssert(layer.minZoom == 10.0)
       XCTAssert(layer.maxZoom == 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
       var layer = CircleLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode CircleLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode CircleLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(CircleLayer.self, from: validData)
           XCTAssert(decodedLayer.id == "test-id")
       	   XCTAssert(decodedLayer.type == LayerType.circle)
           XCTAssert(decodedLayer.filter == nil)
           XCTAssert(decodedLayer.source == "some-source")
           XCTAssertNil(decodedLayer.sourceLayer)
           XCTAssert(decodedLayer.minZoom == 10.0)
           XCTAssert(decodedLayer.maxZoom == 20.0)
       } catch {
           XCTFail("Failed to decode CircleLayer")
       }
    }

    func testEncodingAndDecodingOfLayoutProperties() {

       var layer = CircleLayer(id: "test-id")	
       layer.layout?.visibility = .constant(.visible)
       layer.layout?.circleSortKey = Value<Double>.testConstantValue()

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode CircleLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode CircleLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(CircleLayer.self, from: validData)
           XCTAssert(decodedLayer.layout?.visibility == .constant(.visible))
       	   XCTAssert(layer.layout?.circleSortKey == Value<Double>.testConstantValue())
 
       } catch {
           XCTFail("Failed to decode CircleLayer")
       }
    }

    func testEncodingAndDecodingOfPaintProperties() {

       var layer = CircleLayer(id: "test-id")	
       layer.paint?.circleBlur = Value<Double>.testConstantValue()
       layer.paint?.circleBlurTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.circleColor = Value<ColorRepresentable>.testConstantValue()
       layer.paint?.circleColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.circleOpacity = Value<Double>.testConstantValue()
       layer.paint?.circleOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.circlePitchAlignment = Value<CirclePitchAlignment>.testConstantValue()
       layer.paint?.circlePitchScale = Value<CirclePitchScale>.testConstantValue()
       layer.paint?.circleRadius = Value<Double>.testConstantValue()
       layer.paint?.circleRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.circleStrokeColor = Value<ColorRepresentable>.testConstantValue()
       layer.paint?.circleStrokeColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.circleStrokeOpacity = Value<Double>.testConstantValue()
       layer.paint?.circleStrokeOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.circleStrokeWidth = Value<Double>.testConstantValue()
       layer.paint?.circleStrokeWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.circleTranslate = Value<[Double]>.testConstantValue()
       layer.paint?.circleTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.circleTranslateAnchor = Value<CircleTranslateAnchor>.testConstantValue()

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode CircleLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode CircleLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(CircleLayer.self, from: validData)
           XCTAssert(decodedLayer.layout?.visibility == .constant(.visible))
       	   XCTAssert(layer.paint?.circleBlur == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.circleColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.paint?.circleOpacity == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.circlePitchAlignment == Value<CirclePitchAlignment>.testConstantValue())
       	   XCTAssert(layer.paint?.circlePitchScale == Value<CirclePitchScale>.testConstantValue())
       	   XCTAssert(layer.paint?.circleRadius == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.circleStrokeColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.paint?.circleStrokeOpacity == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.circleStrokeWidth == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.circleTranslate == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.paint?.circleTranslateAnchor == Value<CircleTranslateAnchor>.testConstantValue())
 
       } catch {
           XCTFail("Failed to decode CircleLayer")
       }
    }
}

// End of generated file