// This file is generated
import XCTest
@testable import MapboxMaps

final class LocationIndicatorLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

        var layer = LocationIndicatorLayer(id: "test-id")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0

        XCTAssertEqual(layer.id, "test-id")
        XCTAssertEqual(layer.type, LayerType.locationIndicator)
        XCTAssertEqual(layer.minZoom, 10.0)
        XCTAssertEqual(layer.maxZoom, 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
        var layer = LocationIndicatorLayer(id: "test-id")
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
            XCTAssertEqual(decodedLayer.id, "test-id")
            XCTAssertEqual(decodedLayer.type, LayerType.locationIndicator)
            XCTAssertEqual(decodedLayer.minZoom, 10.0)
            XCTAssertEqual(decodedLayer.maxZoom, 20.0)
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
            XCTAssertEqual(layer.bearingImage, Value<ResolvedImage>.testConstantValue())
            XCTAssertEqual(layer.shadowImage, Value<ResolvedImage>.testConstantValue())
            XCTAssertEqual(layer.topImage, Value<ResolvedImage>.testConstantValue())
        } catch {
            XCTFail("Failed to decode LocationIndicatorLayer")
        }
    }

    func testEncodingAndDecodingOfPaintProperties() {
       var layer = LocationIndicatorLayer(id: "test-id")
       layer.accuracyRadius = Value<Double>.testConstantValue()
       layer.accuracyRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.accuracyRadiusBorderColor = Value<StyleColor>.testConstantValue()
       layer.accuracyRadiusBorderColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.accuracyRadiusColor = Value<StyleColor>.testConstantValue()
       layer.accuracyRadiusColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.bearing = Value<Double>.testConstantValue()
       layer.bearingTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.bearingImageSize = Value<Double>.testConstantValue()
       layer.bearingImageSizeTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.emphasisCircleColor = Value<StyleColor>.testConstantValue()
       layer.emphasisCircleColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.emphasisCircleRadius = Value<Double>.testConstantValue()
       layer.emphasisCircleRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.imagePitchDisplacement = Value<Double>.testConstantValue()
       layer.location = Value<[Double]>.testConstantValue()
       layer.locationTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.locationIndicatorOpacity = Value<Double>.testConstantValue()
       layer.locationIndicatorOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
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
           XCTAssertEqual(layer.accuracyRadius, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.accuracyRadiusBorderColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.accuracyRadiusColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.bearing, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.bearingImageSize, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.emphasisCircleColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.emphasisCircleRadius, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.imagePitchDisplacement, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.location, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.locationIndicatorOpacity, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.perspectiveCompensation, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.shadowImageSize, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.topImageSize, Value<Double>.testConstantValue())
       } catch {
           XCTFail("Failed to decode LocationIndicatorLayer")
       }
    }
}

// End of generated file
