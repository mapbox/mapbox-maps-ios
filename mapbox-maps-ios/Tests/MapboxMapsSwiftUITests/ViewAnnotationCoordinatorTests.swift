@_spi(Experimental) @testable import MapboxMapsSwiftUI
@_spi(Package) import MapboxMaps
import CoreLocation
import XCTest

@available(iOS 13.0, *)
final class ViewAnnotationCoordinatorTests: XCTestCase {
    var me: ViewAnnotationCoordinator!
    var map: MockMapboxMap!
    var upadteLayoutStub: Stub<AnnotationLayouts, Void>!

    override func setUpWithError() throws {
        me = ViewAnnotationCoordinator()
        map = MockMapboxMap()
        upadteLayoutStub = Stub<AnnotationLayouts, Void>()
        me.setup(with: .init(map: map, onLayoutUpdate: upadteLayoutStub.call(with:)))
    }

    override func tearDownWithError() throws {
        upadteLayoutStub = nil
        map = nil
        me = nil
    }

    func testUpdateAnnotations() throws {
        let options = (0...4).map { _ in ViewAnnotationOptions.random }

        var annotations = [AnyHashable: ViewAnnotationOptions]()

        annotations[0] = options[0]
        me.annotations = annotations

        XCTAssertEqual(map.addViewAnnotationStub.invocations.count, 1)
        let opt0Invocation = try XCTUnwrap(map.addViewAnnotationStub.invocations.last)
        XCTAssertEqual(opt0Invocation.parameters.options, options[0], "added option 0")
        let option0InternalId = opt0Invocation.parameters.id

        annotations[1] = options[1]
        annotations[2] = options[2]
        me.annotations = annotations

        XCTAssertEqual(map.addViewAnnotationStub.invocations.count, 3, "added 2 annotations")
        XCTAssertEqual(map.updateViewAnnotationStub.invocations.count, 0, "no updates")
        XCTAssertEqual(map.removeViewAnnotationStub.invocations.count, 0, "no removals")

        me.annotations = annotations

        XCTAssertEqual(map.addViewAnnotationStub.invocations.count, 3, "no additions")
        XCTAssertEqual(map.updateViewAnnotationStub.invocations.count, 0, "no updates")
        XCTAssertEqual(map.removeViewAnnotationStub.invocations.count, 0, "no removals")

        annotations[3] = options[3]
        me.annotations = annotations

        XCTAssertEqual(map.addViewAnnotationStub.invocations.count, 4)
        let opt3Invocation = try XCTUnwrap(map.addViewAnnotationStub.invocations.last)
        XCTAssertEqual(opt3Invocation.parameters.options, options[3], "added option 3")
        let option3InternalId = opt3Invocation.parameters.id

        annotations.removeValue(forKey: 3)
        annotations.removeValue(forKey: 0)
        annotations[1] = options[4]
        me.annotations = annotations

        XCTAssertEqual(map.addViewAnnotationStub.invocations.count, 4, "nothing added")
        XCTAssertEqual(map.updateViewAnnotationStub.invocations.last?.parameters.options, options[4], "added option 4")
        let removedIds = map.removeViewAnnotationStub.invocations.map(\.parameters)
        XCTAssertEqual(Set(removedIds), Set([option0InternalId, option3InternalId]), "options 0 and 3 removed")
    }

    func testPositionsUpdate() throws {
        map.simulateAnnotationPositionsUpdate([.random(with: "foo")])
        XCTAssertEqual(upadteLayoutStub.invocations.count, 0, "annotation is not tracked by us, ignore")

        let options = ViewAnnotationOptions.random
        let inputId = "some-id"
        me.annotations = [inputId: options]
        let internalId = try XCTUnwrap(map.addViewAnnotationStub.invocations.first).parameters.id
        let descriptor = ViewAnnotationPositionDescriptor.random(with: internalId)
        map.simulateAnnotationPositionsUpdate([descriptor])

        XCTAssertEqual(upadteLayoutStub.invocations.count, 1)
        let parameters = try XCTUnwrap(upadteLayoutStub.invocations.first?.parameters)
        let frame = try XCTUnwrap(parameters[inputId])
        XCTAssertEqual(frame, descriptor.frame)
    }

}

extension ViewAnnotationOptions {
    static var random: ViewAnnotationOptions {
        ViewAnnotationOptions(
                        geometry: Point(CLLocationCoordinate2D.random()),
                        allowOverlap: Bool.random(),
                        offsetX: .random(in: 0...100),
                        offsetY: .random(in: 0...100))
    }
}

extension ViewAnnotationPositionDescriptor {
    static func random(with id: String) -> ViewAnnotationPositionDescriptor {
        ViewAnnotationPositionDescriptor(
            identifier: id,
            width: .random(in: 0...100),
            height: .random(in: 0...100), leftTopCoordinate: .random())
    }
}
