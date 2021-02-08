import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsLocation
import MapboxMapsFoundation
import MapboxMapsStyle
#endif

internal class LocationPuckTests: XCTestCase {

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

    func testLocationPuck2DAreEqual() throws {

        let vm1 = LocationIndicatorLayerViewModel(topImage: image, scale: .constant(10))
        let puck1 = LocationPuck.puck2D(vm1)

        let vm2 = LocationIndicatorLayerViewModel(topImage: image, scale: .constant(10))
        let puck2 = LocationPuck.puck2D(vm2)

        XCTAssertEqual(puck1, puck2)

    }

    func testLocationPuck2DAreNotEqual() throws {

        let vm1 = LocationIndicatorLayerViewModel(topImage: image, scale: .constant(12))
        let puck1 = LocationPuck.puck2D(vm1)

        let vm2 = LocationIndicatorLayerViewModel(topImage: image, scale: .constant(10))
        let puck2 = LocationPuck.puck2D(vm2)

        XCTAssertNotEqual(puck1, puck2)

    }

    func testLocationPuck3DAreEqual() throws {

        let vm1 = PuckModelLayerViewModel(model: model1, modelScale: .constant([0.1, 0.2]), modelRotation: .constant([0.3, 0.4]))
        let puck1 = LocationPuck.puck3D(vm1)

        let vm2 = PuckModelLayerViewModel(model: model1, modelScale: .constant([0.1, 0.2]), modelRotation: .constant([0.3, 0.4]))
        let puck2 = LocationPuck.puck3D(vm2)

        XCTAssertEqual(puck1, puck2)
    }

    func testLocationPuck3DAreNotEqual() throws {

        let vm1 = PuckModelLayerViewModel(model: model1, modelScale: .constant([0.1, 0.2]), modelRotation: .constant([0.3, 0.4]))
        let puck1 = LocationPuck.puck3D(vm1)

        let vm2 = PuckModelLayerViewModel(model: model2, modelScale: .constant([0.1, 0.3]), modelRotation: .constant([0.4, 0.5]))
        let puck2 = LocationPuck.puck3D(vm2)

        XCTAssertNotEqual(puck1, puck2)
    }
}
