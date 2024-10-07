@testable import MapboxMaps
import XCTest

final class DefaultViewportTransitionAnimationSpecProviderTests: XCTestCase {

    var mapboxMap: MockMapboxMap!
    var lowZoomToHighZoomAnimationSpecProvider: MockDefaultViewportTransitionAnimationSpecProvider!
    var highZoomToLowZoomAnimationSpecProvider: MockDefaultViewportTransitionAnimationSpecProvider!
    var provider: DefaultViewportTransitionAnimationSpecProvider!

    override func setUp() {
        super.setUp()
        mapboxMap = MockMapboxMap()
        lowZoomToHighZoomAnimationSpecProvider = MockDefaultViewportTransitionAnimationSpecProvider()
        highZoomToLowZoomAnimationSpecProvider = MockDefaultViewportTransitionAnimationSpecProvider()
        provider = DefaultViewportTransitionAnimationSpecProvider(
            mapboxMap: mapboxMap,
            lowZoomToHighZoomAnimationSpecProvider: lowZoomToHighZoomAnimationSpecProvider,
            highZoomToLowZoomAnimationSpecProvider: highZoomToLowZoomAnimationSpecProvider)

        lowZoomToHighZoomAnimationSpecProvider.makeAnimationSpecsStub.defaultReturnValue = .testFixture(
            withLength: 5,
            generator: {
                DefaultViewportTransitionAnimationSpec(
                    duration: 2,
                    delay: 6,
                    cameraOptionsComponent: MockCameraOptionsComponent())
            })
        highZoomToLowZoomAnimationSpecProvider.makeAnimationSpecsStub.defaultReturnValue = .testFixture(
            withLength: 5,
            generator: {
                DefaultViewportTransitionAnimationSpec(
                    duration: 6,
                    delay: 10,
                    cameraOptionsComponent: MockCameraOptionsComponent())
            })
    }

    override func tearDown() {
        provider = nil
        highZoomToLowZoomAnimationSpecProvider = nil
        lowZoomToHighZoomAnimationSpecProvider = nil
        mapboxMap = nil
        super.tearDown()
    }

    func verifySpecs(_ specs: [DefaultViewportTransitionAnimationSpec],
                     provider: MockDefaultViewportTransitionAnimationSpecProvider) throws {
        let returnedSpecs = try XCTUnwrap(provider.makeAnimationSpecsStub.invocations.first?.returnValue)
        XCTAssertEqual(specs.count, returnedSpecs.count)
        for (spec, returnedSpec) in zip(specs, returnedSpecs) {
            XCTAssertEqual(spec.duration, returnedSpec.duration)
            XCTAssertEqual(spec.delay, returnedSpec.delay)
            XCTAssertIdentical(
                spec.cameraOptionsComponent as? MockCameraOptionsComponent,
                returnedSpec.cameraOptionsComponent as? MockCameraOptionsComponent)
        }
    }

    func testMakeAnimationSpecsWithNilTargetZoom() throws {
        var cameraOptions = CameraOptions.testConstantValue()
        cameraOptions.zoom = nil

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(
            highZoomToLowZoomAnimationSpecProvider.makeAnimationSpecsStub.invocations.map(\.parameters),
            [cameraOptions])
        XCTAssertEqual(
            lowZoomToHighZoomAnimationSpecProvider.makeAnimationSpecsStub.invocations.count,
            0)
        try verifySpecs(specs, provider: highZoomToLowZoomAnimationSpecProvider)
    }

    func testMakeAnimationSpecsWithCurrentZoomGreaterThanTargetZoom() throws {
        var cameraOptions = CameraOptions.testConstantValue()
        cameraOptions.zoom = 12.3

        mapboxMap.cameraState.zoom = cameraOptions.zoom! + 1

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(
            highZoomToLowZoomAnimationSpecProvider.makeAnimationSpecsStub.invocations.map(\.parameters),
            [cameraOptions])
        XCTAssertEqual(
            lowZoomToHighZoomAnimationSpecProvider.makeAnimationSpecsStub.invocations.count,
            0)
        try verifySpecs(specs, provider: highZoomToLowZoomAnimationSpecProvider)
    }

    func testMakeAnimationSpecsWithCurrentZoomEqualToTargetZoom() throws {
        var cameraOptions = CameraOptions.testConstantValue()
        cameraOptions.zoom = 12.4

        mapboxMap.cameraState.zoom = cameraOptions.zoom!

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(
            highZoomToLowZoomAnimationSpecProvider.makeAnimationSpecsStub.invocations.map(\.parameters),
            [cameraOptions])
        XCTAssertEqual(
            lowZoomToHighZoomAnimationSpecProvider.makeAnimationSpecsStub.invocations.count,
            0)
        try verifySpecs(specs, provider: highZoomToLowZoomAnimationSpecProvider)
    }

    func testMakeAnimationSpecsWithCurrentZoomLessThanTargetZoom() throws {
        var cameraOptions = CameraOptions.testConstantValue()
        cameraOptions.zoom = 1.2

        mapboxMap.cameraState.zoom = cameraOptions.zoom! - 1

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(
            highZoomToLowZoomAnimationSpecProvider.makeAnimationSpecsStub.invocations.count,
            0)
        XCTAssertEqual(
            lowZoomToHighZoomAnimationSpecProvider.makeAnimationSpecsStub.invocations.map(\.parameters),
            [cameraOptions])
        try verifySpecs(specs, provider: lowZoomToHighZoomAnimationSpecProvider)
    }
}
