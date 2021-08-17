// This file is generated
import XCTest
@testable import MapboxMaps

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
       layer.visibility = .constant(.visible)
       layer.bearingImage = Value<ResolvedImage>.testConstantValue()
       layer.shadowImage = Value<ResolvedImage>.testConstantValue()
       layer.topImage = Value<ResolvedImage>.testConstantValue()

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
           XCTAssert(decodedLayer.visibility == .constant(.visible))
       	   XCTAssert(layer.bearingImage == Value<ResolvedImage>.testConstantValue())
       	   XCTAssert(layer.shadowImage == Value<ResolvedImage>.testConstantValue())
       	   XCTAssert(layer.topImage == Value<ResolvedImage>.testConstantValue())
       } catch {
           XCTFail("Failed to decode LocationIndicatorLayer")
       }
    }

    func testEncodingAndDecodingOfPaintProperties() {

       var layer = LocationIndicatorLayer(id: "test-id")
       layer.accuracyRadius = Value<Double>.testConstantValue()
       layer.accuracyRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.accuracyRadiusBorderColor = Value<ColorRepresentable>.testConstantValue()
       layer.accuracyRadiusBorderColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.accuracyRadiusColor = Value<ColorRepresentable>.testConstantValue()
       layer.accuracyRadiusColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.bearing = Value<Double>.testConstantValue()
       layer.bearingImageSize = Value<Double>.testConstantValue()
       layer.bearingImageSizeTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.emphasisCircleColor = Value<ColorRepresentable>.testConstantValue()
       layer.emphasisCircleColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.emphasisCircleRadius = Value<Double>.testConstantValue()
       layer.emphasisCircleRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.imagePitchDisplacement = Value<Double>.testConstantValue()
       layer.location = Value<[Double]>.testConstantValue()
       layer.locationTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.perspectiveCompensation = Value<Double>.testConstantValue()
       layer.shadowImageSize = Value<Double>.testConstantValue()
       layer.shadowImageSizeTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.topImageSize = Value<Double>.testConstantValue()
       layer.topImageSizeTransition = StyleTransition(duration: 10.0, delay: 10.0)

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
           XCTAssert(decodedLayer.visibility == .constant(.visible))
       	   XCTAssert(layer.accuracyRadius == Value<Double>.testConstantValue())
       	   XCTAssert(layer.accuracyRadiusBorderColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.accuracyRadiusColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.bearing == Value<Double>.testConstantValue())
       	   XCTAssert(layer.bearingImageSize == Value<Double>.testConstantValue())
       	   XCTAssert(layer.emphasisCircleColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.emphasisCircleRadius == Value<Double>.testConstantValue())
       	   XCTAssert(layer.imagePitchDisplacement == Value<Double>.testConstantValue())
       	   XCTAssert(layer.location == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.perspectiveCompensation == Value<Double>.testConstantValue())
       	   XCTAssert(layer.shadowImageSize == Value<Double>.testConstantValue())
       	   XCTAssert(layer.topImageSize == Value<Double>.testConstantValue())
       } catch {
           XCTFail("Failed to decode LocationIndicatorLayer")
       }
    }
}

// End of generated file
