import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsLocation
import MapboxMapsFoundation
import MapboxMapsStyle
#endif

internal class LocationPuckTests: XCTestCase {

    func testLocationPuck2DAreEqual() throws {

        let puck1 = LocationPuck.puck2D { (vm) in
            vm.scale = .constant(10.0)
            if #available(iOS 13.0, *) {
                vm.topImage = UIImage(systemName: "house")
            }
        }

        let puck2 = LocationPuck.puck2D { (vm) in
            vm.scale = .constant(10.0)
            if #available(iOS 13.0, *) {
                vm.topImage = UIImage(systemName: "house")
            }
        }

        XCTAssertEqual(puck1, puck2)

    }

    func testLocationPuck2DAreNotEqual() throws {

        let puck1 = LocationPuck.puck2D { (vm) in
            vm.scale = .constant(10.0)
            if #available(iOS 13.0, *) {
                vm.topImage = UIImage(systemName: "house")
            }
        }

        let puck2 = LocationPuck.puck2D { (vm) in
            vm.scale = .constant(10.0)
        }

        XCTAssertNotEqual(puck1, puck2)

    }

    func testLocationPuck3DAreEqual() throws {

        let puck1 = LocationPuck.puck3D { (vm) in
            vm.modelScale = .constant([0.1, 0.2])
            vm.modelRotation = .constant([0.3, 0.4])
            vm.model = Model(uri: URL(string: "some-url"), position: [1.0, 2.0])
        }

        let puck2 = LocationPuck.puck3D { (vm) in
            vm.modelScale = .constant([0.1, 0.2])
            vm.modelRotation = .constant([0.3, 0.4])
            vm.model = Model(uri: URL(string: "some-url"), position: [1.0, 2.0])
        }

        XCTAssertEqual(puck1, puck2)
    }

    func testLocationPuck3DAreNotEqual() throws {

        let puck1 = LocationPuck.puck3D { (vm) in
            vm.modelScale = .constant([0.1, 0.2])
            vm.modelRotation = .constant([0.3, 0.4])
        }

        let puck2 = LocationPuck.puck3D { (vm) in
            vm.modelScale = .constant([0.1, 0.2])
            vm.modelRotation = .constant([0.2, 0.4])
            vm.model = Model(uri: URL(string: "some-url"), position: [1.0, 2.0])
        }

        XCTAssertNotEqual(puck1, puck2)
    }
}
