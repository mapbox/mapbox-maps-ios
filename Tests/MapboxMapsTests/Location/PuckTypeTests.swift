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
}
