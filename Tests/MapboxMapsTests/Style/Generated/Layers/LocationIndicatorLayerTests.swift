// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class LocationIndicatorLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

       var layer = LocationIndicatorLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       XCTAssert(layer.id == "test-id")
       XCTAssert(layer.type == LayerType.locationIndicator)
       XCTAssert(layer.filter == nil)
       XCTAssert(layer.source == "some-source")
       XCTAssertNil(layer.sourceLayer)
       XCTAssert(layer.minZoom == 10.0)
       XCTAssert(layer.maxZoom == 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
       var layer = LocationIndicatorLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode LocationIndicatorLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode LocationIndicatorLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(LocationIndicatorLayer.self, from: validData)
           XCTAssert(decodedLayer.id == "test-id")
       	   XCTAssert(decodedLayer.type == LayerType.locationIndicator)
           XCTAssert(decodedLayer.filter == nil)
           XCTAssert(decodedLayer.source == "some-source")
           XCTAssertNil(decodedLayer.sourceLayer)
           XCTAssert(decodedLayer.minZoom == 10.0)
           XCTAssert(decodedLayer.maxZoom == 20.0)
       } catch {
           XCTFail("Failed to decode LocationIndicatorLayer")
       }
    }

    func testEncodingAndDecodingOfLayoutProperties() {

       var layer = LocationIndicatorLayer(id: "test-id")	
       layer.layout?.visibility = .constant(.visible)
       layer.layout?.bearingImage = Value<ResolvedImage>.testConstantValue()
       layer.layout?.shadowImage = Value<ResolvedImage>.testConstantValue()
       layer.layout?.topImage = Value<ResolvedImage>.testConstantValue()

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode LocationIndicatorLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode LocationIndicatorLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(LocationIndicatorLayer.self, from: validData)
           XCTAssert(decodedLayer.layout?.visibility == .constant(.visible))
       	   XCTAssert(layer.layout?.bearingImage == Value<ResolvedImage>.testConstantValue())
       	   XCTAssert(layer.layout?.shadowImage == Value<ResolvedImage>.testConstantValue())
       	   XCTAssert(layer.layout?.topImage == Value<ResolvedImage>.testConstantValue())
 
       } catch {
           XCTFail("Failed to decode LocationIndicatorLayer")
       }
    }

    func testEncodingAndDecodingOfPaintProperties() {

       var layer = LocationIndicatorLayer(id: "test-id")	
       layer.paint?.accuracyRadius = Value<Double>.testConstantValue()
       layer.paint?.accuracyRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.accuracyRadiusBorderColor = Value<ColorRepresentable>.testConstantValue()
       layer.paint?.accuracyRadiusBorderColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.accuracyRadiusColor = Value<ColorRepresentable>.testConstantValue()
       layer.paint?.accuracyRadiusColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.bearing = Value<Double>.testConstantValue()
       layer.paint?.bearingImageSize = Value<Double>.testConstantValue()
       layer.paint?.bearingImageSizeTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.emphasisCircleColor = Value<ColorRepresentable>.testConstantValue()
       layer.paint?.emphasisCircleColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.emphasisCircleRadius = Value<Double>.testConstantValue()
       layer.paint?.emphasisCircleRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.imagePitchDisplacement = Value<Double>.testConstantValue()
       layer.paint?.location = Value<[Double]>.testConstantValue()
       layer.paint?.locationTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.perspectiveCompensation = Value<Double>.testConstantValue()
       layer.paint?.shadowImageSize = Value<Double>.testConstantValue()
       layer.paint?.shadowImageSizeTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.topImageSize = Value<Double>.testConstantValue()
       layer.paint?.topImageSizeTransition = StyleTransition(duration: 10.0, delay: 10.0)

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode LocationIndicatorLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode LocationIndicatorLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(LocationIndicatorLayer.self, from: validData)
           XCTAssert(decodedLayer.layout?.visibility == .constant(.visible))
       	   XCTAssert(layer.paint?.accuracyRadius == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.accuracyRadiusBorderColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.paint?.accuracyRadiusColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.paint?.bearing == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.bearingImageSize == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.emphasisCircleColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.paint?.emphasisCircleRadius == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.imagePitchDisplacement == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.location == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.paint?.perspectiveCompensation == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.shadowImageSize == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.topImageSize == Value<Double>.testConstantValue())
 
       } catch {
           XCTFail("Failed to decode LocationIndicatorLayer")
       }
    }
}

// End of generated file