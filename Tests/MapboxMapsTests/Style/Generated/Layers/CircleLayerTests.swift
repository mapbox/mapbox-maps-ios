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
       layer.visibility = .constant(.visible)
       layer.circleSortKey = Value<Double>.testConstantValue()

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
           XCTAssert(decodedLayer.visibility == .constant(.visible))
       	   XCTAssert(layer.circleSortKey == Value<Double>.testConstantValue())
 
       } catch {
           XCTFail("Failed to decode CircleLayer")
       }
    }

    func testEncodingAndDecodingOfPaintProperties() {

       var layer = CircleLayer(id: "test-id")	
       layer.circleBlur = Value<Double>.testConstantValue()
       layer.circleBlurTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.circleColor = Value<ColorRepresentable>.testConstantValue()
       layer.circleColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.circleOpacity = Value<Double>.testConstantValue()
       layer.circleOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.circlePitchAlignment = Value<CirclePitchAlignment>.testConstantValue()
       layer.circlePitchScale = Value<CirclePitchScale>.testConstantValue()
       layer.circleRadius = Value<Double>.testConstantValue()
       layer.circleRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.circleStrokeColor = Value<ColorRepresentable>.testConstantValue()
       layer.circleStrokeColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.circleStrokeOpacity = Value<Double>.testConstantValue()
       layer.circleStrokeOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.circleStrokeWidth = Value<Double>.testConstantValue()
       layer.circleStrokeWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.circleTranslate = Value<[Double]>.testConstantValue()
       layer.circleTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.circleTranslateAnchor = Value<CircleTranslateAnchor>.testConstantValue()

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
           XCTAssert(decodedLayer.visibility == .constant(.visible))
       	   XCTAssert(layer.circleBlur == Value<Double>.testConstantValue())
       	   XCTAssert(layer.circleColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.circleOpacity == Value<Double>.testConstantValue())
       	   XCTAssert(layer.circlePitchAlignment == Value<CirclePitchAlignment>.testConstantValue())
       	   XCTAssert(layer.circlePitchScale == Value<CirclePitchScale>.testConstantValue())
       	   XCTAssert(layer.circleRadius == Value<Double>.testConstantValue())
       	   XCTAssert(layer.circleStrokeColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.circleStrokeOpacity == Value<Double>.testConstantValue())
       	   XCTAssert(layer.circleStrokeWidth == Value<Double>.testConstantValue())
       	   XCTAssert(layer.circleTranslate == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.circleTranslateAnchor == Value<CircleTranslateAnchor>.testConstantValue())
 
       } catch {
           XCTFail("Failed to decode CircleLayer")
       }
    }
}

// End of generated file