// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class LocationIndicatorLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

        var layer = LocationIndicatorLayer(id: "test-id")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

        XCTAssertEqual(layer.id, "test-id")
        XCTAssertEqual(layer.type, LayerType.locationIndicator)
        XCTAssertEqual(layer.minZoom, 10.0)
        XCTAssertEqual(layer.maxZoom, 20.0)
        XCTAssertEqual(layer.slot, Slot.testConstantValue())
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
        var layer = LocationIndicatorLayer(id: "test-id")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

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
            XCTAssertEqual(layer.slot, Slot.testConstantValue())
        } catch {
            XCTFail("Failed to decode LocationIndicatorLayer")
        }
    }

    func testEncodingAndDecodingOfLayoutProperties() {
        var layer = LocationIndicatorLayer(id: "test-id")
        layer.visibility = .constant(.visible)

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
       layer.accuracyRadiusBorderColorUseTheme = .none
       layer.accuracyRadiusColor = Value<StyleColor>.testConstantValue()
       layer.accuracyRadiusColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.accuracyRadiusColorUseTheme = .none
       layer.bearing = Value<Double>.testConstantValue()
       layer.bearingTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.bearingImage = Value<ResolvedImage>.testConstantValue()
       layer.bearingImageSize = Value<Double>.testConstantValue()
       layer.bearingImageSizeTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.emphasisCircleColor = Value<StyleColor>.testConstantValue()
       layer.emphasisCircleColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.emphasisCircleColorUseTheme = .none
       layer.emphasisCircleGlowRange = Value<[Double]>.testConstantValue()
       layer.emphasisCircleGlowRangeTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.emphasisCircleRadius = Value<Double>.testConstantValue()
       layer.emphasisCircleRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.imagePitchDisplacement = Value<Double>.testConstantValue()
       layer.location = Value<[Double]>.testConstantValue()
       layer.locationTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.locationIndicatorOpacity = Value<Double>.testConstantValue()
       layer.locationIndicatorOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.perspectiveCompensation = Value<Double>.testConstantValue()
       layer.shadowImage = Value<ResolvedImage>.testConstantValue()
       layer.shadowImageSize = Value<Double>.testConstantValue()
       layer.shadowImageSizeTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.topImage = Value<ResolvedImage>.testConstantValue()
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
           XCTAssertEqual(layer.bearingImage, Value<ResolvedImage>.testConstantValue())
           XCTAssertEqual(layer.bearingImageSize, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.emphasisCircleColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.emphasisCircleGlowRange, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.emphasisCircleRadius, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.imagePitchDisplacement, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.location, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.locationIndicatorOpacity, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.perspectiveCompensation, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.shadowImage, Value<ResolvedImage>.testConstantValue())
           XCTAssertEqual(layer.shadowImageSize, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.topImage, Value<ResolvedImage>.testConstantValue())
           XCTAssertEqual(layer.topImageSize, Value<Double>.testConstantValue())
       } catch {
           XCTFail("Failed to decode LocationIndicatorLayer")
       }
    }

    func testSetPropertyValueWithFunction() {
        let layer = LocationIndicatorLayer(id: "test-id")
            .slot(Slot.testConstantValue())
            .minZoom(Double.testConstantValue())
            .maxZoom(Double.testConstantValue())
            .accuracyRadius(Double.testConstantValue())
            .accuracyRadiusBorderColor(StyleColor.testConstantValue())
            .accuracyRadiusColor(StyleColor.testConstantValue())
            .bearing(Double.testConstantValue())
            .bearingImage(String.testConstantValue())
            .bearingImageSize(Double.testConstantValue())
            .emphasisCircleColor(StyleColor.testConstantValue())
            .emphasisCircleGlowRange(solidStart: 0, transparentEnd: 1)
            .emphasisCircleRadius(Double.testConstantValue())
            .imagePitchDisplacement(Double.testConstantValue())
            .location(CLLocationCoordinate2D(latitude: 10, longitude: 20))
            .locationIndicatorOpacity(Double.testConstantValue())
            .perspectiveCompensation(Double.testConstantValue())
            .shadowImage(String.testConstantValue())
            .shadowImageSize(Double.testConstantValue())
            .topImage(String.testConstantValue())
            .topImageSize(Double.testConstantValue())

        XCTAssertEqual(layer.slot, Slot.testConstantValue())
        XCTAssertEqual(layer.minZoom, Double.testConstantValue())
        XCTAssertEqual(layer.maxZoom, Double.testConstantValue())
        XCTAssertEqual(layer.accuracyRadius, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.accuracyRadiusBorderColor, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(layer.accuracyRadiusColor, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(layer.bearing, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.bearingImage, Value<ResolvedImage>.constant(.name(String.testConstantValue())))
        XCTAssertEqual(layer.bearingImageSize, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.emphasisCircleColor, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(layer.emphasisCircleGlowRange, Value.constant([0, 1]))
        XCTAssertEqual(layer.emphasisCircleRadius, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.imagePitchDisplacement, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.location, Value.constant([10, 20, 0]))
        XCTAssertEqual(layer.locationIndicatorOpacity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.perspectiveCompensation, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.shadowImage, Value<ResolvedImage>.constant(.name(String.testConstantValue())))
        XCTAssertEqual(layer.shadowImageSize, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.topImage, Value<ResolvedImage>.constant(.name(String.testConstantValue())))
        XCTAssertEqual(layer.topImageSize, Value.constant(Double.testConstantValue()))
    }
}

// End of generated file
