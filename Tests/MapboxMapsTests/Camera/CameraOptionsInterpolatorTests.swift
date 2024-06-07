@testable import MapboxMaps
import XCTest

final class CameraOptionsInterpolatorTests: XCTestCase {
    var coordinateInterpolator: MockCoordinateInterpolator!
    var uiEdgeInsetsInterpolator: MockUIEdgeInsetsInterpolator!
    var doubleInterpolator: MockDoubleInterpolator!
    var directionInterpolator: MockDirectionInterpolator!
    var cameraOptionsInterpolator: CameraOptionsInterpolator!
    var fraction: Double!

    override func setUp() {
        super.setUp()
        coordinateInterpolator = MockCoordinateInterpolator()
        uiEdgeInsetsInterpolator = MockUIEdgeInsetsInterpolator()
        doubleInterpolator = MockDoubleInterpolator()
        directionInterpolator = MockDirectionInterpolator()
        cameraOptionsInterpolator = CameraOptionsInterpolator(
            coordinateInterpolator: coordinateInterpolator,
            uiEdgeInsetsInterpolator: uiEdgeInsetsInterpolator,
            doubleInterpolator: doubleInterpolator,
            directionInterpolator: directionInterpolator)
        fraction = 0.6
    }

    override func tearDown() {
        fraction = nil
        cameraOptionsInterpolator = nil
        directionInterpolator = nil
        doubleInterpolator = nil
        uiEdgeInsetsInterpolator = nil
        coordinateInterpolator = nil
        super.tearDown()
    }

    func testFromNilToNil() {
        let from = CameraOptions()
        let to = CameraOptions()

        let result = cameraOptionsInterpolator.interpolate(
            from: from,
            to: to,
            fraction: fraction)

        XCTAssertTrue(coordinateInterpolator.interpolateStub.invocations.isEmpty)
        XCTAssertTrue(uiEdgeInsetsInterpolator.interpolateStub.invocations.isEmpty)
        XCTAssertTrue(doubleInterpolator.interpolateStub.invocations.isEmpty)
        XCTAssertTrue(directionInterpolator.interpolateStub.invocations.isEmpty)

        XCTAssertNil(result.center)
        XCTAssertNil(result.padding)
        XCTAssertNil(result.zoom)
        XCTAssertNil(result.bearing)
        XCTAssertNil(result.pitch)
        XCTAssertNil(result.anchor)
    }

    func testFromNilToNonNil() {
        let from = CameraOptions()
        let to = CameraOptions.testConstantValue()

        let result = cameraOptionsInterpolator.interpolate(
            from: from,
            to: to,
            fraction: fraction)

        XCTAssertTrue(coordinateInterpolator.interpolateStub.invocations.isEmpty)
        XCTAssertTrue(uiEdgeInsetsInterpolator.interpolateStub.invocations.isEmpty)
        XCTAssertTrue(doubleInterpolator.interpolateStub.invocations.isEmpty)
        XCTAssertTrue(directionInterpolator.interpolateStub.invocations.isEmpty)

        XCTAssertNil(result.center)
        XCTAssertNil(result.padding)
        XCTAssertNil(result.zoom)
        XCTAssertNil(result.bearing)
        XCTAssertNil(result.pitch)
        XCTAssertNil(result.anchor)
    }

    func testFromNonNilToNil() {
        let from = CameraOptions.testConstantValue()
        let to = CameraOptions()

        let result = cameraOptionsInterpolator.interpolate(
            from: from,
            to: to,
            fraction: fraction)

        XCTAssertTrue(coordinateInterpolator.interpolateStub.invocations.isEmpty)
        XCTAssertTrue(uiEdgeInsetsInterpolator.interpolateStub.invocations.isEmpty)
        XCTAssertTrue(doubleInterpolator.interpolateStub.invocations.isEmpty)
        XCTAssertTrue(directionInterpolator.interpolateStub.invocations.isEmpty)

        XCTAssertNil(result.center)
        XCTAssertNil(result.padding)
        XCTAssertNil(result.zoom)
        XCTAssertNil(result.bearing)
        XCTAssertNil(result.pitch)
        XCTAssertNil(result.anchor)
    }

    func testFromNonNilToNonNil() {
        let from = CameraOptions.testConstantValue()
        let to = CameraOptions(
            center: .init(latitude: 29, longitude: 55),
            padding: .init(top: 8, left: 23, bottom: 49, right: 9),
            anchor: .init(x: -28, y: -44),
            zoom: 19,
            bearing: 193,
            pitch: 75)
        coordinateInterpolator.interpolateStub.defaultReturnValue = .init(latitude: 0, longitude: 0)
        uiEdgeInsetsInterpolator.interpolateStub.defaultReturnValue = .init(top: 0, left: 0, bottom: 0, right: 0)
        doubleInterpolator.interpolateStub.returnValueQueue = [-50, 50]
        directionInterpolator.interpolateStub.defaultReturnValue = 65

        let result = cameraOptionsInterpolator.interpolate(
            from: from,
            to: to,
            fraction: fraction)

        XCTAssertEqual(coordinateInterpolator.interpolateStub.invocations.count, 1)
        XCTAssertEqual(uiEdgeInsetsInterpolator.interpolateStub.invocations.count, 1)
        XCTAssertEqual(doubleInterpolator.interpolateStub.invocations.count, 2)
        XCTAssertEqual(directionInterpolator.interpolateStub.invocations.count, 1)

        guard coordinateInterpolator.interpolateStub.invocations.count == 1,
              uiEdgeInsetsInterpolator.interpolateStub.invocations.count == 1,
              doubleInterpolator.interpolateStub.invocations.count == 2,
              directionInterpolator.interpolateStub.invocations.count == 1 else {
                  return
              }

        let coordinateInterpolatorInvocation = coordinateInterpolator.interpolateStub.invocations[0]
        XCTAssertEqual(coordinateInterpolatorInvocation.parameters.from, from.center)
        XCTAssertEqual(coordinateInterpolatorInvocation.parameters.to, to.center)
        XCTAssertEqual(coordinateInterpolatorInvocation.parameters.fraction, fraction)
        XCTAssertEqual(result.center, coordinateInterpolatorInvocation.returnValue)

        let uiEdgeInsetsInterpolatorInvocation = uiEdgeInsetsInterpolator.interpolateStub.invocations[0]
        XCTAssertEqual(uiEdgeInsetsInterpolatorInvocation.parameters.from, from.padding)
        XCTAssertEqual(uiEdgeInsetsInterpolatorInvocation.parameters.to, to.padding)
        XCTAssertEqual(uiEdgeInsetsInterpolatorInvocation.parameters.fraction, fraction)
        XCTAssertEqual(result.padding, uiEdgeInsetsInterpolatorInvocation.returnValue)

        let interpolatorInvocation0 = doubleInterpolator.interpolateStub.invocations[0]
        XCTAssertEqual(interpolatorInvocation0.parameters.from, from.zoom.map(Double.init(_:)))
        XCTAssertEqual(interpolatorInvocation0.parameters.to, to.zoom.map(Double.init(_:)))
        XCTAssertEqual(interpolatorInvocation0.parameters.fraction, fraction)
        XCTAssertEqual(result.zoom, CGFloat(interpolatorInvocation0.returnValue))

        let bearingInterpolatorInvocation = directionInterpolator.interpolateStub.invocations[0]
        XCTAssertEqual(bearingInterpolatorInvocation.parameters.from, from.bearing)
        XCTAssertEqual(bearingInterpolatorInvocation.parameters.to, to.bearing)
        XCTAssertEqual(bearingInterpolatorInvocation.parameters.fraction, fraction)
        XCTAssertEqual(result.bearing, bearingInterpolatorInvocation.returnValue)

        let interpolatorInvocation1 = doubleInterpolator.interpolateStub.invocations[1]
        XCTAssertEqual(interpolatorInvocation1.parameters.from, from.pitch.map(Double.init(_:)))
        XCTAssertEqual(interpolatorInvocation1.parameters.to, to.pitch.map(Double.init(_:)))
        XCTAssertEqual(interpolatorInvocation1.parameters.fraction, fraction)
        XCTAssertEqual(result.pitch, CGFloat(interpolatorInvocation1.returnValue))

        XCTAssertNil(result.anchor)
    }
}
