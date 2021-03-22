import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsFoundation
#endif

// swiftlint:disable explicit_top_level_acl explicit_acl
class MapboxAnimationGroupTests: XCTestCase, CAAnimationDelegate {

    var mapView: BaseMapView!
    var cameraManager: CameraManager!
    var newCamera: CameraOptions!
    override func setUp() {
        let resourceOptions = ResourceOptions(accessToken: "pk.feedcafedeadbeefbadebede")
        mapView = BaseMapView(with: CGRect(x: 0, y: 0, width: 100, height: 100),
                              resourceOptions: resourceOptions,
                              glyphsRasterizationOptions: GlyphsRasterizationOptions.default,
                              styleURL: nil)
        cameraManager = CameraManager(for: mapView, with: MapCameraOptions())

        newCamera = CameraOptions(center: CLLocationCoordinate2D(latitude: 50, longitude: 50),
                                  padding: .zero,
                                  anchor: .zero,
                                  zoom: 8,
                                  bearing: .zero,
                                  pitch: 0)

        super.setUp()
    }

    func testAnimationsStarted() {
        let animationGroup = MapboxAnimationGroup()
        animationGroup.delegate = self
        animationGroup.animationDidStart(animationGroup)

        let delegateWasSet = animationGroup.delegateWasSet
        XCTAssertTrue(delegateWasSet)
    }

    func testAnimationsEnded() {
        weak var cameraLayer: CALayer?
        weak var weakAnimation: MapboxAnimationGroup?
        autoreleasepool {
            let animationExpectation = self.expectation(description: "Animation should be nil")
            _ = cameraManager.flyTo(to: newCamera) {_ in
                animationExpectation.fulfill()
            }

            cameraLayer = self.mapView.cameraView.layer
            let key = cameraLayer?.animationKeys()?.first ?? String(self.newCamera.hashValue)
            weakAnimation = cameraLayer?.animation(forKey: key) as? MapboxAnimationGroup

            XCTAssertNotNil(weakAnimation)
            wait(for: [animationExpectation], timeout: .zero + 5)
        }

        XCTAssertNil(cameraLayer?.animationKeys())
        XCTAssertNil(weakAnimation)
    }
}

extension MapboxAnimationGroup {
    private struct Tracker {
        static var didSetDelegate: Bool = false
    }

    var delegateWasSet: Bool {
        get {
            return Tracker.didSetDelegate
        }
        set {
            Tracker.didSetDelegate = newValue
        }
    }

    public func animationDidStart(_ anim: CAAnimation) {
        if anim.delegate != nil {
            delegateWasSet = true
        }
    }
}
