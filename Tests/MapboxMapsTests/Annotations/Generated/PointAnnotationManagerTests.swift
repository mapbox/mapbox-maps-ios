import Foundation
@testable import MapboxMaps
import XCTest

final class PointAnnotationManagerTests: XCTestCase {
    var manager: PointAnnotationManager!
    var style: MockStyle!
    var displayLinkCoordinator: DisplayLinkCoordinator!

    override func setUp() {
        super.setUp()

        style = MockStyle()
        displayLinkCoordinator = MockDisplayLinkCoordinator()
        manager = PointAnnotationManager(id: UUID().uuidString,
                                         style: style,
                                         layerPosition: nil,
                                         displayLinkCoordinator: displayLinkCoordinator)
    }

    override func tearDown() {
        style = nil
        displayLinkCoordinator = nil
        manager = nil

        super.tearDown()
    }

    func testNewImagesAddedToStyle() {
        // given
        let annotations = (0..<10)
            .map { _ in PointAnnotation.Image(image: UIImage(), name: UUID().uuidString) }
            .map(PointAnnotation.init)

        // when
        manager.annotations = annotations
        manager.syncSourceAndLayerIfNeeded()

        // then
        XCTAssertEqual(style.addImageWithInsetsStub.invocations.count, annotations.count)
        XCTAssertEqual(
            Set(style.addImageWithInsetsStub.invocations.map(\.parameters.id)),
            Set(annotations.compactMap(\.image?.name))
        )
        XCTAssertEqual(
            Set(style.addImageWithInsetsStub.invocations.map(\.parameters.image)),
            Set(annotations.compactMap(\.image?.image))
        )
        XCTAssertEqual(style.removeImageStub.invocations.count, 0)
    }

    func testUnusedImagesRemovedFromStyle() {
        // given
        let unusedAnnotations = 3
        let annotations = (0..<10)
            .map { _ in PointAnnotation.Image(image: UIImage(), name: UUID().uuidString) }
            .map(PointAnnotation.init)
        manager.annotations = annotations
        manager.syncSourceAndLayerIfNeeded()

        // when
        manager.annotations = annotations.suffix(annotations.count - unusedAnnotations)
        manager.syncSourceAndLayerIfNeeded()

        // then
        XCTAssertEqual(style.addImageWithInsetsStub.invocations.count, annotations.count + annotations.count - unusedAnnotations)
        XCTAssertEqual(
            Set(style.addImageWithInsetsStub.invocations.map(\.parameters.id)),
            Set(annotations.compactMap(\.image?.name))
        )
        XCTAssertEqual(
            Set(style.addImageWithInsetsStub.invocations.map(\.parameters.image)),
            Set(annotations.compactMap(\.image?.image))
        )
        XCTAssertEqual(style.removeImageStub.invocations.count, unusedAnnotations)
        XCTAssertEqual(
            Set(style.removeImageStub.invocations.map(\.parameters)),
            Set(annotations.prefix(unusedAnnotations).compactMap(\.image?.name))
        )
    }

    func testAllImagesRemovedFromStyleOnUpdate() {
        // given
        let annotations = (0..<10)
            .map { _ in PointAnnotation.Image(image: UIImage(), name: UUID().uuidString) }
            .map(PointAnnotation.init)
        manager.annotations = annotations
        manager.syncSourceAndLayerIfNeeded()

        // when
        manager.annotations = []
        manager.syncSourceAndLayerIfNeeded()

        // then
        XCTAssertEqual(style.addImageWithInsetsStub.invocations.count, annotations.count)
        XCTAssertEqual(
            Set(style.addImageWithInsetsStub.invocations.map(\.parameters.id)),
            Set(annotations.compactMap(\.image?.name))
        )
        XCTAssertEqual(
            Set(style.addImageWithInsetsStub.invocations.map(\.parameters.image)),
            Set(annotations.compactMap(\.image?.image))
        )
        XCTAssertEqual(style.removeImageStub.invocations.count, annotations.count)
        XCTAssertEqual(
            Set(style.removeImageStub.invocations.map(\.parameters)),
            Set(annotations.compactMap(\.image?.name))
        )
    }

    func testAllImagesRemovedFromStyleOnDestroy() {
        // given
        let annotations = (0..<10)
            .map { _ in PointAnnotation.Image(image: UIImage(), name: UUID().uuidString) }
            .map(PointAnnotation.init)
        manager.annotations = annotations
        manager.syncSourceAndLayerIfNeeded()

        // when
        manager.destroy()

        // then
        XCTAssertEqual(style.removeImageStub.invocations.count, annotations.count)
        XCTAssertEqual(
            Set(style.removeImageStub.invocations.map(\.parameters)),
            Set(annotations.compactMap(\.image?.name))
        )

    }
}

private extension PointAnnotation {
    init(image: Image) {
        self.init(coordinate: .random())
        self.image = image
    }
}
