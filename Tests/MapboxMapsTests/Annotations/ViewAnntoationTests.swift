@testable import MapboxMaps
import XCTest

final class ViewAnnotationTests: XCTestCase {
    var mapboxMap: MockMapboxMap!
    @TestSignal var displayLink: Signal<Void>
    var removeCount = 0
    var deps: ViewAnnotation.Deps!

    let availableSize = CGSize(width: 1000, height: 1000)

    override func setUp() {
        mapboxMap = MockMapboxMap()
        removeCount = 0
        deps = ViewAnnotation.Deps(
            superview: UIView(),
            mapboxMap: mapboxMap,
            displayLink: displayLink,
            onRemove: { [weak self] in
                self?.removeCount += 1
            })

        deps.superview.bounds = CGRect(origin: .init(x: 0, y: 0), size: availableSize)
    }

    override func tearDown() {
        mapboxMap = nil
        deps = nil
    }

    func testAddUpdateRemoveAddLifecycle() throws {
        let actualSize = CGSize(width: 100, height: 100)

        let view = DummyAnnotationView()
        view.actualSize = actualSize

        let point = Point(.init(latitude: 1, longitude: 2))
        let va = ViewAnnotation(annotatedFeature: .geometry(point), view: view)
        va.allowOverlap = true
        va.visible = true
        va.selected = true
        va.allowZElevate = true
        let variableAnchors = [ViewAnnotationAnchorConfig(anchor: .bottom, offsetX: 10, offsetY: 20)]
        va.variableAnchors = variableAnchors
        va.allowOverlapWithPuck = true
        va.ignoreCameraPadding = true

        XCTAssertEqual(va.allowOverlap, true)
        XCTAssertEqual(va.visible, true)
        XCTAssertEqual(va.selected, true)
        XCTAssertEqual(va.allowZElevate, true)

        // Add annotation
        va.bind(deps)

        XCTAssertEqual(deps.superview.subviews.first, view)
        XCTAssertEqual(deps.superview.bounds.size, view.providedAvailableSize)

        XCTAssertEqual(mapboxMap.addViewAnnotationStub.invocations.count, 1)
        let addParameters = try XCTUnwrap(mapboxMap.addViewAnnotationStub.invocations.last).parameters
        XCTAssertEqual(addParameters.id, va.id)
        XCTAssertEqual(addParameters.options.annotatedFeature, .geometry(point))
        XCTAssertEqual(addParameters.options.width, actualSize.width)
        XCTAssertEqual(addParameters.options.height, actualSize.height)
        XCTAssertEqual(addParameters.options.allowOverlap, true)
        XCTAssertEqual(addParameters.options.allowOverlapWithPuck, true)
        XCTAssertEqual(addParameters.options.allowZElevate, true)
        XCTAssertEqual(addParameters.options.ignoreCameraPadding, true)
        XCTAssertEqual(addParameters.options.selected, true)
        XCTAssertEqual(addParameters.options.visible, true)
        XCTAssertEqual(addParameters.options.variableAnchors, variableAnchors)

        XCTAssertEqual(mapboxMap.updateViewAnnotationStub.invocations.count, 0)

        // Update
        va.annotatedFeature = .layerFeature(layerId: "foo", featureId: "bar")
        va.allowOverlap = true // no update
        va.visible = false
        va.selected = false
        va.allowZElevate = false
        XCTAssertEqual(va.allowOverlap, true)
        XCTAssertEqual(va.visible, false)
        XCTAssertEqual(va.selected, false)
        XCTAssertEqual(va.allowZElevate, false)

        // no update without display link
        XCTAssertEqual(mapboxMap.updateViewAnnotationStub.invocations.count, 0)

        $displayLink.send()
        XCTAssertEqual(mapboxMap.updateViewAnnotationStub.invocations.count, 1)
        let updParameters = try XCTUnwrap(mapboxMap.updateViewAnnotationStub.invocations.last).parameters
        XCTAssertEqual(updParameters.id, va.id)
        var expectedOptions = ViewAnnotationOptions(
            annotatedFeature: .layerFeature(layerId: "foo", featureId: "bar"),
            visible: false,
            selected: false)
        expectedOptions.allowZElevate = false
        XCTAssertEqual(updParameters.options, expectedOptions)

        // Remove
        XCTAssertEqual(self.removeCount, 0)
        XCTAssertEqual(mapboxMap.removeViewAnnotationStub.invocations.count, 0)

        va.remove()
        XCTAssertEqual(self.removeCount, 1)
        XCTAssertEqual(deps.superview.subviews.count, 0)
        XCTAssertEqual(mapboxMap.removeViewAnnotationStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.removeViewAnnotationStub.invocations.first?.parameters, va.id)

        // Add again
        va.bind(deps)
        XCTAssertEqual(mapboxMap.addViewAnnotationStub.invocations.count, 2)
        let addParameters2 = try XCTUnwrap(mapboxMap.addViewAnnotationStub.invocations.last).parameters
        XCTAssertEqual(addParameters2.id, va.id)
        XCTAssertEqual(addParameters2.options.annotatedFeature, .layerFeature(layerId: "foo", featureId: "bar"))
        XCTAssertEqual(addParameters2.options.width, actualSize.width)
        XCTAssertEqual(addParameters2.options.height, actualSize.height)
        XCTAssertEqual(addParameters2.options.allowOverlap, true)
        XCTAssertEqual(addParameters2.options.allowZElevate, false)
        XCTAssertEqual(addParameters2.options.selected, false)
        XCTAssertEqual(addParameters2.options.visible, false)
        XCTAssertEqual(addParameters2.options.variableAnchors, variableAnchors)
    }

    func testUpdateSize() throws {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)

        let va = ViewAnnotation(coordinate: .init(latitude: 3, longitude: 4), view: view)

        va.bind(deps)

        // annotation is sized in superview bounds.
        XCTAssertEqual(deps.superview.bounds.size, view.providedAvailableSize)
        view.providedAvailableSize = nil

        view.actualSize = CGSize(width: 200, height: 300)
        va.setNeedsUpdateSize()
        va.setNeedsUpdateSize()

        // no update without display link
        XCTAssertEqual(mapboxMap.updateViewAnnotationStub.invocations.count, 0)

        $displayLink.send()
        XCTAssertEqual(mapboxMap.updateViewAnnotationStub.invocations.count, 1)
        let updParameters = try XCTUnwrap(mapboxMap.updateViewAnnotationStub.invocations.last).parameters
        XCTAssertEqual(updParameters.id, va.id)
        let expectedOptions = ViewAnnotationOptions(
            width: 200,
            height: 300)
        XCTAssertEqual(updParameters.options, expectedOptions)
    }

    func testPlacement() {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)

        let va = ViewAnnotation(coordinate: .init(latitude: 1, longitude: 2), view: view)

        // Add annotation
        va.bind(deps)

        XCTAssertEqual(view.isHidden, true)

        var anchors = [ViewAnnotationAnchorConfig]()
        var frames = [CGRect]()
        var anchorCoordinates = [CLLocationCoordinate2D]()
        var visibilities = [Bool]()

        va.onFrameChanged = { frames.append($0) }
        va.onAnchorChanged = { anchors.append($0) }
        va.onVisibilityChanged = { visibilities.append($0) }
        va.onAnchorCoordinateChanged = { anchorCoordinates.append($0) }

        // Place 1
        let descriotor1 = ViewAnnotationPositionDescriptor(
            identifier: va.id,
            frame: CGRect(x: 1, y: 2, width: 3, height: 4),
            anchorCoordinate: .init(latitude: 5, longitude: 6),
            anchorConfig: .init(anchor: .bottom, offsetX: 7, offsetY: 8))
        va.place(with: descriotor1)

        XCTAssertEqual(view.frame, descriotor1.frame)
        XCTAssertEqual(va.anchorConfig, descriotor1.anchorConfig)
        XCTAssertEqual(va.anchorCoordinate, descriotor1.anchorCoordinate)
        XCTAssertEqual(view.isHidden, false)

        XCTAssertEqual(frames, [descriotor1.frame])
        XCTAssertEqual(anchors, [descriotor1.anchorConfig])
        XCTAssertEqual(anchorCoordinates, [descriotor1.anchorCoordinate])
        XCTAssertEqual(visibilities, [true])

        // Place 1, again, no updates
        va.place(with: descriotor1)
        XCTAssertEqual(frames, [descriotor1.frame])
        XCTAssertEqual(anchors, [descriotor1.anchorConfig])
        XCTAssertEqual(anchorCoordinates, [descriotor1.anchorCoordinate])
        XCTAssertEqual(visibilities, [true])

        // Place 2
        let descriotor2 = ViewAnnotationPositionDescriptor(
            identifier: va.id,
            frame: CGRect(x: 10, y: 20, width: 30, height: 40),
            anchorCoordinate: .init(latitude: 50, longitude: 60),
            anchorConfig: .init(anchor: .top, offsetX: 70, offsetY: 80))
        va.place(with: descriotor2)

        XCTAssertEqual(view.frame, descriotor2.frame)
        XCTAssertEqual(va.anchorConfig, descriotor2.anchorConfig)
        XCTAssertEqual(va.anchorCoordinate, descriotor2.anchorCoordinate)

        XCTAssertEqual(frames, [descriotor1.frame, descriotor2.frame])
        XCTAssertEqual(anchors, [descriotor1.anchorConfig, descriotor2.anchorConfig])
        XCTAssertEqual(anchorCoordinates, [descriotor1.anchorCoordinate, descriotor2.anchorCoordinate])
        XCTAssertEqual(visibilities, [true])
    }
}

class DummyAnnotationView: UIView {
    var actualSize: CGSize = .zero
    var providedAvailableSize: CGSize?

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        providedAvailableSize = size
        return actualSize
    }
}
