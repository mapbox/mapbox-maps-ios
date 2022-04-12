@testable import MapboxMaps
import XCTest

final class LowZoomToHighZoomAnimationSpecProviderTests: XCTestCase {

    var mapboxMap: MockMapboxMap!
    var provider: LowZoomToHighZoomAnimationSpecProvider!

    override func setUp() {
        super.setUp()
        mapboxMap = MockMapboxMap()
        provider = LowZoomToHighZoomAnimationSpecProvider(mapboxMap: mapboxMap)
    }

    override func tearDown() {
        provider = nil
        mapboxMap = nil
        super.tearDown()
    }

    func testMakeAnimationSpecsCenterLongDistance() {
        let cameraOptions = CameraOptions(center: .random())
        // center duration is calculated based on 500 screen points per second
        // or 3 seconds, whichever is smaller. This configuration simultes a
        // 2000 point distance, so it should be clamped to 3 seconds.
        mapboxMap.pointStub.returnValueQueue = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 2000, y: 0)]

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(
            mapboxMap.pointStub.invocations.map(\.parameters),
            [mapboxMap.cameraState.center, cameraOptions.center!])
        XCTAssertEqual(specs.count, 1)
        XCTAssertEqual(specs.first?.duration, 3)
        XCTAssertEqual(specs.first?.delay, 0)
        XCTAssertEqual(specs.first?.cameraOptionsComponent.cameraOptions, cameraOptions)
    }

    func testMakeAnimationSpecsCenterShortDistance() {
        let cameraOptions = CameraOptions(center: .random())
        // center duration is calculated based on 500 screen points per second
        // or 3 seconds, whichever is smaller. This configuration simultes a
        // 500 point distance, so it should take 1 second.
        mapboxMap.pointStub.returnValueQueue = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 500, y: 0)]

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(
            mapboxMap.pointStub.invocations.map(\.parameters),
            [mapboxMap.cameraState.center, cameraOptions.center!])
        XCTAssertEqual(specs.count, 1)
        XCTAssertEqual(specs.first?.duration, 1)
        XCTAssertEqual(specs.first?.delay, 0)
        XCTAssertEqual(specs.first?.cameraOptionsComponent.cameraOptions, cameraOptions)
    }

    func testMakeAnimationSpecsZoomLargeDifference() {
        let cameraOptions = CameraOptions(zoom: .random(in: 10...22))
        // zoom duration is calculated based on 2.2 zoom levels per second or 3
        // seconds, whichever is smaller. This configuration simulates a 10
        // level difference, so it should be clamped to 3 seconds.
        mapboxMap.cameraState.zoom = cameraOptions.zoom! - 10

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(specs.count, 1)
        XCTAssertEqual(specs.first?.duration, 3)
        XCTAssertEqual(specs.first?.delay, 0)
        XCTAssertEqual(specs.first?.cameraOptionsComponent.cameraOptions, cameraOptions)
    }

    func testMakeAnimationSpecsZoomSmallDifference() throws {
        let cameraOptions = CameraOptions(zoom: .random(in: 2.2...22))
        // zoom duration is calculated based on 2.2 zoom levels per second or 3
        // seconds, whichever is smaller. This configuration simulates a 2.2
        // level difference, so it should take 1 second.
        mapboxMap.cameraState.zoom = cameraOptions.zoom! - 2.2

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(specs.count, 1)
        let spec = try XCTUnwrap(specs.first)
        XCTAssertEqual(spec.duration, 1, accuracy: 1e-6)
        XCTAssertEqual(spec.delay, 0)
        XCTAssertEqual(spec.cameraOptionsComponent.cameraOptions, cameraOptions)
    }

    func testMakeAnimationSpecsZoomWithDelay() {
        let cameraOptions = CameraOptions(center: .random(), zoom: .random(in: 10...22))
        // zoom delay is calculated as half of the center duration. In this
        // case, the center duration will be 3 seconds, so the zoom delay should
        // be 1.5 seconds.
        mapboxMap.pointStub.returnValueQueue = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 2000, y: 0)]

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(specs.count, 2)
        XCTAssertEqual(specs.last?.delay, 1.5)
    }

    func testMakeAnimationSpecsBearingWithoutZoom() {
        let cameraOptions = CameraOptions(bearing: .random(in: 0...360))
        // If there's no zoom animation, bearing is not delayed

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(specs.count, 1)
        XCTAssertEqual(specs.first?.duration, 1.8)
        XCTAssertEqual(specs.first?.delay, 0)
        XCTAssertEqual(specs.first?.cameraOptionsComponent.cameraOptions, cameraOptions)
    }

    func testMakeAnimationSpecsBearingWithShortZoomAnimation() {
        mapboxMap.cameraState.zoom = 0
        let cameraOptions = CameraOptions(zoom: 2.2, bearing: .random(in: 0...360))
        // If there is a zoom animation, bearing is configured to end at the
        // same time as it unless the zoom animation ends in less time than the
        // total bearing animation. In this scenario, the zoom animation is too
        // short (1 second), so the bearing animation is not delayed.

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(specs.count, 2)
        XCTAssertEqual(specs.last?.duration, 1.8)
        XCTAssertEqual(specs.last?.delay, 0)
    }

    func testMakeAnimationSpecsBearingWithLongZoomAnimation() throws {
        mapboxMap.cameraState.zoom = 0
        let cameraOptions = CameraOptions(zoom: 6.6, bearing: .random(in: 0...360))
        // If there is a zoom animation, bearing is configured to end at the
        // same time as it unless the zoom animation ends in less time than the
        // total bearing animation. In this scenario, the zoom animation is
        // longer (3 s) than the bearing animation, so the bearing animation is
        // delayed by 3 - 1.8 = 1.2 s.

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(specs.count, 2)
        let spec = try XCTUnwrap(specs.last)
        XCTAssertEqual(spec.duration, 1.8)
        XCTAssertEqual(spec.delay, 1.2, accuracy: 1e-6)
    }

    func testMakeAnimationSpecsBearingWithShortButDelayedZoomAnimation() throws {
        // zoom delay is calculated as half of the center duration. In this
        // case, the center duration will be 3 seconds, so the zoom delay should
        // be 1.5 seconds.
        mapboxMap.pointStub.returnValueQueue = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 2000, y: 0)]
        mapboxMap.cameraState.zoom = 0
        let cameraOptions = CameraOptions(
            center: .random(),
            zoom: 2.2,
            bearing: .random(in: 0...360))
        // If there is a zoom animation, bearing is configured to end at the
        // same time as it unless the zoom animation ends in less time than the
        // total bearing animation. In this scenario, the zoom animation is
        // shorter (1 s) than the bearing animation, but due to its 1.5 second
        // delay, it ends at 2.5 s from when the animations begin, so the
        // bearing animation is delayed by 2.5 - 1.8 = 0.7 s.

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(specs.count, 3)
        let spec = try XCTUnwrap(specs.last)
        XCTAssertEqual(spec.duration, 1.8)
        XCTAssertEqual(spec.delay, 0.7, accuracy: 1e-6)
    }

    func testMakeAnimationSpecsPitchWithoutZoom() {
        let cameraOptions = CameraOptions(pitch: .random(in: 0...85))

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(specs.count, 1)
        XCTAssertEqual(specs.first?.duration, 1.2)
        XCTAssertEqual(specs.first?.delay, 0)
        XCTAssertEqual(specs.first?.cameraOptionsComponent.cameraOptions, cameraOptions)
    }

    func testMakeAnimationSpecsPitchWithShortZoomAnimation() {
        mapboxMap.cameraState.zoom = 0
        let cameraOptions = CameraOptions(zoom: 2.2, pitch: .random(in: 0...85))
        // If there is a zoom animation, pitch is configured to end 0.1 s after
        // it unless the zoom animation ends in less time than the total pitch
        // animation minus 0.1 s. In this scenario, the zoom animation is too
        // short (1 second), so the pitch animation is not delayed.

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(specs.count, 2)
        XCTAssertEqual(specs.last?.duration, 1.2)
        XCTAssertEqual(specs.last?.delay, 0)
    }

    func testMakeAnimationSpecsPitchWithLongZoomAnimation() throws {
        mapboxMap.cameraState.zoom = 0
        let cameraOptions = CameraOptions(zoom: 6.6, pitch: .random(in: 0...85))
        // If there is a zoom animation, pitch is configured to end 0.1 s after
        // it unless the zoom animation ends in less time than the total pitch
        // animation minus 0.1 s. In this scenario, the zoom animation is
        // longer (3 s) than the pitch animation, so the pitch animation is
        // delayed by 3 - 1.2 + 0.1 = 1.9 s.

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(specs.count, 2)
        let spec = try XCTUnwrap(specs.last)
        XCTAssertEqual(spec.duration, 1.2)
        XCTAssertEqual(spec.delay, 1.9, accuracy: 1e-6)
    }

    func testMakeAnimationSpecsPitchWithShortButDelayedZoomAnimation() throws {
        // zoom delay is calculated as half of the center duration. In this
        // case, the center duration will be 3 seconds, so the zoom delay should
        // be 1.5 seconds.
        mapboxMap.pointStub.returnValueQueue = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 2000, y: 0)]
        mapboxMap.cameraState.zoom = 0
        let cameraOptions = CameraOptions(
            center: .random(),
            zoom: 2.2,
            pitch: .random(in: 0...85))
        // If there is a zoom animation, pitch is configured to end 0.1 s after
        // it unless the zoom animation ends in less time than the total pitch
        // animation minus 0.1 s. In this scenario, the zoom animation is
        // shorter (1 s) than the pitch animation, but due to its 1.5 second
        // delay, it ends at 2.5 s from when the animations begin, so the
        // pitch animation is delayed by 2.5 - 1.2 + 0.1 = 1.4 s.

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(specs.count, 3)
        let spec = try XCTUnwrap(specs.last)
        XCTAssertEqual(spec.duration, 1.2)
        XCTAssertEqual(spec.delay, 1.4, accuracy: 1e-6)
    }

    func testMakeAnimationSpecsPaddingWithoutZoom() {
        let cameraOptions = CameraOptions(padding: .random())

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(specs.count, 1)
        XCTAssertEqual(specs.first?.duration, 1.2)
        XCTAssertEqual(specs.first?.delay, 0)
        XCTAssertEqual(specs.first?.cameraOptionsComponent.cameraOptions, cameraOptions)
    }

    func testMakeAnimationSpecsPaddingWithShortZoomAnimation() {
        mapboxMap.cameraState.zoom = 0
        let cameraOptions = CameraOptions(padding: .random(), zoom: 2.2)
        // If there is a zoom animation, padding is configured to end 0.1 s
        // after it unless the zoom animation ends in less time than the total
        // padding animation minus 0.1 s. In this scenario, the zoom animation
        // is too short (1 second), so the padding animation is not delayed.

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(specs.count, 2)
        XCTAssertEqual(specs.last?.duration, 1.2)
        XCTAssertEqual(specs.last?.delay, 0)
    }

    func testMakeAnimationSpecsPaddingWithLongZoomAnimation() throws {
        mapboxMap.cameraState.zoom = 0
        let cameraOptions = CameraOptions(padding: .random(), zoom: 6.6)
        // If there is a zoom animation, padding is configured to end 0.1 s
        // after it unless the zoom animation ends in less time than the total
        // padding animation minus 0.1 s. In this scenario, the zoom animation
        // is longer (3 s) than the padding animation, so the padding animation
        // is delayed by 3 - 1.2 + 0.1 = 1.9 s.

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(specs.count, 2)
        let spec = try XCTUnwrap(specs.last)
        XCTAssertEqual(spec.duration, 1.2)
        XCTAssertEqual(spec.delay, 1.9, accuracy: 1e-6)
    }

    func testMakeAnimationSpecsPaddingWithShortButDelayedZoomAnimation() throws {
        // zoom delay is calculated as half of the center duration. In this
        // case, the center duration will be 3 seconds, so the zoom delay should
        // be 1.5 seconds.
        mapboxMap.pointStub.returnValueQueue = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 2000, y: 0)]
        mapboxMap.cameraState.zoom = 0
        let cameraOptions = CameraOptions(
            center: .random(),
            padding: .random(),
            zoom: 2.2)
        // If there is a zoom animation, padding is configured to end 0.1 s
        // after it unless the zoom animation ends in less time than the total
        // padding animation minus 0.1 s. In this scenario, the zoom animation
        // is shorter (1 s) than the padding animation, but due to its 1.5
        // second delay, it ends at 2.5 s from when the animations begin, so the
        // padding animation is delayed by 2.5 - 1.2 + 0.1 = 1.4 s.

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertEqual(specs.count, 3)
        let spec = try XCTUnwrap(specs.last)
        XCTAssertEqual(spec.duration, 1.2)
        XCTAssertEqual(spec.delay, 1.4, accuracy: 1e-6)
    }
}
