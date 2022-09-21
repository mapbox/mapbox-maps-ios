import XCTest
@testable import MapboxMaps

internal class PuckTypeTests: XCTestCase {

    var image: UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: "house")
        } else {
            return nil
        }
    }

    var model1: Model {
        return Model(uri: URL(string: "some-url"), position: [1.0, 2.0])
    }

    var model2: Model {
        return Model(uri: URL(string: "some-other-url"), position: [1.0, 2.0])
    }

    func testPuck2DEqual() throws {

        let config1 = Puck2DConfiguration(topImage: image, scale: .constant(10))
        let puck1 = PuckType.puck2D(config1)

        let config2 = Puck2DConfiguration(topImage: image, scale: .constant(10))
        let puck2 = PuckType.puck2D(config2)

        XCTAssertEqual(puck1, puck2)
    }

    func testPuck2DNotEqual() throws {

        let config1 = Puck2DConfiguration(topImage: image, scale: .constant(12))
        let puck1 = PuckType.puck2D(config1)

        let config2 = Puck2DConfiguration(topImage: image, scale: .constant(10))
        let puck2 = PuckType.puck2D(config2)

        XCTAssertNotEqual(puck1, puck2)
    }

    func testPuck3DEqual() throws {

        let config1 = Puck3DConfiguration(model: model1, modelScale: .constant([0.1, 0.2]), modelRotation: .constant([0.3, 0.4]))
        let puck1 = PuckType.puck3D(config1)

        let config2 = Puck3DConfiguration(model: model1, modelScale: .constant([0.1, 0.2]), modelRotation: .constant([0.3, 0.4]))
        let puck2 = PuckType.puck3D(config2)

        XCTAssertEqual(puck1, puck2)
    }

    func testPuck3DNotEqual() throws {

        let config1 = Puck3DConfiguration(model: model1, modelScale: .constant([0.1, 0.2]), modelRotation: .constant([0.3, 0.4]))
        let puck1 = PuckType.puck3D(config1)

        let config2 = Puck3DConfiguration(model: model2, modelScale: .constant([0.1, 0.3]), modelRotation: .constant([0.4, 0.5]))
        let puck2 = PuckType.puck3D(config2)

        XCTAssertNotEqual(puck1, puck2)
    }

    func testPuck2DConfigurationInitializerWithDefaultValues() {
        let config = Puck2DConfiguration()

        XCTAssertNil(config.topImage)
        XCTAssertNil(config.bearingImage)
        XCTAssertNil(config.shadowImage)
        XCTAssertNil(config.scale)
        XCTAssertFalse(config.showsAccuracyRing)
        XCTAssertEqual(config.accuracyRingColor, UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3))
        XCTAssertEqual(config.accuracyRingBorderColor, UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3))
        XCTAssertEqual(config.opacity, 1)
    }

    func testPuck2DConfigurationInitializerWithNonDefaultValues() {
        let topImage: UIImage? = .random(UIImage())
        let bearingImage: UIImage? = .random(UIImage())
        let shadowImage: UIImage? = .random(UIImage())
        let scale: Value<Double>? = .random(.constant(.random(in: 0...10)))
        let showsAccuracyRing: Bool = .random()
        let opacity: CGFloat = .random(in: 0.0...1.0)

        let config = Puck2DConfiguration(
            topImage: topImage,
            bearingImage: bearingImage,
            shadowImage: shadowImage,
            scale: scale,
            showsAccuracyRing: showsAccuracyRing,
            opacity: opacity)

        XCTAssertTrue(config.topImage === topImage)
        XCTAssertTrue(config.bearingImage === bearingImage)
        XCTAssertTrue(config.shadowImage === shadowImage)
        XCTAssertEqual(config.scale, scale)
        XCTAssertEqual(config.showsAccuracyRing, showsAccuracyRing)
        XCTAssertEqual(config.accuracyRingColor, UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3))
        XCTAssertEqual(config.accuracyRingBorderColor, UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3))
        XCTAssertEqual(config.opacity, opacity)
    }

    func testPuck2DConfigurationExtendedInitializerWithDefaultValues() {
        // need to specify on of the extended params for swift to pick
        // this overload
        let config = Puck2DConfiguration(
            accuracyRingColor: .black)

        XCTAssertNil(config.topImage)
        XCTAssertNil(config.bearingImage)
        XCTAssertNil(config.shadowImage)
        XCTAssertNil(config.scale)
        XCTAssertFalse(config.showsAccuracyRing)
        XCTAssertEqual(config.accuracyRingColor, .black)
        XCTAssertEqual(config.accuracyRingBorderColor, UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3))
        XCTAssertEqual(config.opacity, 1)

        let config2 = Puck2DConfiguration(
            accuracyRingBorderColor: .black)

        XCTAssertNil(config2.topImage)
        XCTAssertNil(config2.bearingImage)
        XCTAssertNil(config2.shadowImage)
        XCTAssertNil(config2.scale)
        XCTAssertFalse(config2.showsAccuracyRing)
        XCTAssertEqual(config2.accuracyRingColor, UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3))
        XCTAssertEqual(config2.accuracyRingBorderColor, .black)
        XCTAssertEqual(config.opacity, 1)
    }

    func testPuck2DConfigurationExtendedInitializerWithNonDefaultValues() {
        let topImage: UIImage? = .random(UIImage())
        let bearingImage: UIImage? = .random(UIImage())
        let shadowImage: UIImage? = .random(UIImage())
        let scale: Value<Double>? = .random(.constant(.random(in: 0...10)))
        let showsAccuracyRing: Bool = .random()
        let accuracyRingColor: UIColor = .random()
        let accuracyRingBorderColor: UIColor = .random()
        let opacity: CGFloat = .random(in: 0.0...1.0)

        let config = Puck2DConfiguration(
            topImage: topImage,
            bearingImage: bearingImage,
            shadowImage: shadowImage,
            scale: scale,
            showsAccuracyRing: showsAccuracyRing,
            accuracyRingColor: accuracyRingColor,
            accuracyRingBorderColor: accuracyRingBorderColor,
            opacity: opacity)

        XCTAssertTrue(config.topImage === topImage)
        XCTAssertTrue(config.bearingImage === bearingImage)
        XCTAssertTrue(config.shadowImage === shadowImage)
        XCTAssertEqual(config.scale, scale)
        XCTAssertEqual(config.showsAccuracyRing, showsAccuracyRing)
        XCTAssertEqual(config.accuracyRingColor, accuracyRingColor)
        XCTAssertEqual(config.accuracyRingBorderColor, accuracyRingBorderColor)
        XCTAssertEqual(config.opacity, opacity)
    }

    func testPuck2DPulsingConfigurationInitializerWithDefaultValues() {
        let pulsing = Puck2DConfiguration.Pulsing()

        XCTAssertEqual(pulsing.color, UIColor(red: 0.29, green: 0.565, blue: 0.886, alpha: 1))
        XCTAssertEqual(pulsing.radius, .constant(30))
        XCTAssertTrue(pulsing.isEnabled)
    }

    func testPuck2DPulsingConfigurationInitializerWithNonDefaultValues() {
        let color: UIColor = .random()
        let radius: Puck2DConfiguration.Pulsing.Radius = .accuracy

        var pulsing = Puck2DConfiguration.Pulsing(color: color, radius: radius)
        pulsing.isEnabled = false

        XCTAssertEqual(pulsing.color, color)
        XCTAssertEqual(pulsing.radius, radius)
        XCTAssertFalse(pulsing.isEnabled)
    }

    func testPuck2DMakeDefault() {
        let puck2D = Puck2DConfiguration.makeDefault()
        XCTAssertEqual(puck2D.topImage, UIImage(named: "location-dot-inner", in: .mapboxMaps, compatibleWith: nil)!)
        XCTAssertNil(puck2D.bearingImage)
        XCTAssertEqual(puck2D.shadowImage, UIImage(named: "location-dot-outer", in: .mapboxMaps, compatibleWith: nil)!)
    }

    func testPuck2DMakeDefaultWithBearing() {
        let puck2D = Puck2DConfiguration.makeDefault(showBearing: true)
        XCTAssertEqual(puck2D.topImage, UIImage(named: "location-dot-inner", in: .mapboxMaps, compatibleWith: nil)!)
        XCTAssertNotNil(puck2D.bearingImage)
        XCTAssertEqual(puck2D.shadowImage, UIImage(named: "location-dot-outer", in: .mapboxMaps, compatibleWith: nil)!)
    }
}
