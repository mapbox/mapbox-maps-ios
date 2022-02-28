@testable import MapboxMaps
import XCTest

final class CameraOptionsInterpolatorTests: XCTestCase {
    var coordinateInterpolator: MockCoordinateInterpolator!
    var uiEdgeInsetsInterpolator: MockUIEdgeInsetsInterpolator!
    var interpolator: MockInterpolator!
    var directionInterpolator: MockDirectionInterpolator!
    var cameraOptionsInterpolator: CameraOptionsInterpolator!
    var fraction: Double!

    override func setUp() {
        super.setUp()
        coordinateInterpolator = MockCoordinateInterpolator()
        uiEdgeInsetsInterpolator = MockUIEdgeInsetsInterpolator()
        interpolator = MockInterpolator()
        directionInterpolator = MockDirectionInterpolator()
        cameraOptionsInterpolator = CameraOptionsInterpolator(
            coordinateInterpolator: coordinateInterpolator,
            uiEdgeInsetsInterpolator: uiEdgeInsetsInterpolator,
            interpolator: interpolator,
            directionInterpolator: directionInterpolator)
        fraction = .random(in: 0...1)
    }

    override func tearDown() {
        fraction = nil
        cameraOptionsInterpolator = nil
        directionInterpolator = nil
        interpolator = nil
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
        XCTAssertTrue(interpolator.interpolateStub.invocations.isEmpty)
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
        let to = CameraOptions(
            center: .random(),
            padding: .random(),
            anchor: .random(),
            zoom: .random(in: 0...20),
            bearing: .random(in: 0..<360),
            pitch: .random(in: 0...80))

        let result = cameraOptionsInterpolator.interpolate(
            from: from,
            to: to,
            fraction: fraction)

        XCTAssertTrue(coordinateInterpolator.interpolateStub.invocations.isEmpty)
        XCTAssertTrue(uiEdgeInsetsInterpolator.interpolateStub.invocations.isEmpty)
        XCTAssertTrue(interpolator.interpolateStub.invocations.isEmpty)
        XCTAssertTrue(directionInterpolator.interpolateStub.invocations.isEmpty)

        XCTAssertNil(result.center)
        XCTAssertNil(result.padding)
        XCTAssertNil(result.zoom)
        XCTAssertNil(result.bearing)
        XCTAssertNil(result.pitch)
        XCTAssertNil(result.anchor)
    }

    func testFromNonNilToNil() {
        let from = CameraOptions(
            center: .random(),
            padding: .random(),
            anchor: .random(),
            zoom: .random(in: 0...20),
            bearing: .random(in: 0..<360),
            pitch: .random(in: 0...80))
        let to = CameraOptions()

        let result = cameraOptionsInterpolator.interpolate(
            from: from,
            to: to,
            fraction: fraction)

        XCTAssertTrue(coordinateInterpolator.interpolateStub.invocations.isEmpty)
        XCTAssertTrue(uiEdgeInsetsInterpolator.interpolateStub.invocations.isEmpty)
        XCTAssertTrue(interpolator.interpolateStub.invocations.isEmpty)
        XCTAssertTrue(directionInterpolator.interpolateStub.invocations.isEmpty)

        XCTAssertNil(result.center)
        XCTAssertNil(result.padding)
        XCTAssertNil(result.zoom)
        XCTAssertNil(result.bearing)
        XCTAssertNil(result.pitch)
        XCTAssertNil(result.anchor)
    }

    func testFromNonNilToNonNil() {
        let from = CameraOptions(
            center: .random(),
            padding: .random(),
            anchor: .random(),
            zoom: .random(in: 0...20),
            bearing: .random(in: 0..<360),
            pitch: .random(in: 0...80))
        let to = CameraOptions(
            center: .random(),
            padding: .random(),
            anchor: .random(),
            zoom: .random(in: 0...20),
            bearing: .random(in: 0..<360),
            pitch: .random(in: 0...80))
        coordinateInterpolator.interpolateStub.defaultReturnValue = .random()
        uiEdgeInsetsInterpolator.interpolateStub.defaultReturnValue = .random()
        interpolator.interpolateStub.returnValueQueue = .random(
            withLength: 2,
            generator: { .random(in: -100...100) })
        directionInterpolator.interpolateStub.defaultReturnValue = .random(in: 0..<360)

        let result = cameraOptionsInterpolator.interpolate(
            from: from,
            to: to,
            fraction: fraction)

        XCTAssertEqual(coordinateInterpolator.interpolateStub.invocations.count, 1)
        XCTAssertEqual(uiEdgeInsetsInterpolator.interpolateStub.invocations.count, 1)
        XCTAssertEqual(interpolator.interpolateStub.invocations.count, 2)
        XCTAssertEqual(directionInterpolator.interpolateStub.invocations.count, 1)

        guard coordinateInterpolator.interpolateStub.invocations.count == 1,
              uiEdgeInsetsInterpolator.interpolateStub.invocations.count == 1,
              interpolator.interpolateStub.invocations.count == 2,
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

        let interpolatorInvocation0 = interpolator.interpolateStub.invocations[0]
        XCTAssertEqual(interpolatorInvocation0.parameters.from, from.zoom.map(Double.init(_:)))
        XCTAssertEqual(interpolatorInvocation0.parameters.to, to.zoom.map(Double.init(_:)))
        XCTAssertEqual(interpolatorInvocation0.parameters.fraction, fraction)
        XCTAssertEqual(result.zoom, CGFloat(interpolatorInvocation0.returnValue))

        let bearingInterpolatorInvocation = directionInterpolator.interpolateStub.invocations[0]
        XCTAssertEqual(bearingInterpolatorInvocation.parameters.from, from.bearing)
        XCTAssertEqual(bearingInterpolatorInvocation.parameters.to, to.bearing)
        XCTAssertEqual(bearingInterpolatorInvocation.parameters.fraction, fraction)
        XCTAssertEqual(result.bearing, bearingInterpolatorInvocation.returnValue)

        let interpolatorInvocation1 = interpolator.interpolateStub.invocations[1]
        XCTAssertEqual(interpolatorInvocation1.parameters.from, from.pitch.map(Double.init(_:)))
        XCTAssertEqual(interpolatorInvocation1.parameters.to, to.pitch.map(Double.init(_:)))
        XCTAssertEqual(interpolatorInvocation1.parameters.fraction, fraction)
        XCTAssertEqual(result.pitch, CGFloat(interpolatorInvocation1.returnValue))

        XCTAssertNil(result.anchor)
    }
}
