import XCTest
@testable import MapboxMaps

final class AnnotationImagesManagerTests: XCTestCase {

    var sut: AnnotationImagesManager!
    var mockStyle: MockStyle!

    override func setUp() {
        super.setUp()

        mockStyle = MockStyle()
        sut = AnnotationImagesManager(style: mockStyle)
    }

    override func tearDown() {
        mockStyle = nil
        sut = nil

        super.tearDown()
    }

    func testAnnotationImagesAddedToStyleIfNotExist() throws {
        // given
        let imageID = UUID().uuidString
        let sdf = true
        let contentInsets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)

        // when
        sut.addImage(UIImage(), id: imageID, sdf: sdf, contentInsets: contentInsets)
        // then
        let parameters = try XCTUnwrap(mockStyle.addImageWithInsetsStub.invocations.last?.parameters)
        XCTAssertEqual(parameters.id, imageID)
        XCTAssertEqual(parameters.sdf, sdf)
        XCTAssertEqual(parameters.contentInsets, contentInsets)

        // when
        mockStyle.imageExistsStub.defaultReturnValue = true
        mockStyle.addImageWithInsetsStub.reset()
        sut.addImage(UIImage(), id: imageID, sdf: sdf, contentInsets: contentInsets)
        // then
        XCTAssertTrue(mockStyle.addImageWithInsetsStub.invocations.isEmpty)
    }

    func testAnnotationImagesRemovedFromStyleIfOwned() throws {
        // given
        for _ in 0...10 {
            sut.addImage(UIImage(), id: UUID().uuidString, sdf: true, contentInsets: .zero)
        }
        let imageId = "image-id"
        sut.addImage(UIImage(), id: imageId, sdf: false, contentInsets: .zero)

        mockStyle.imageExistsStub.defaultReturnValue = true

        // when
        sut.removeImage("unowned-image-id")
        // then
        XCTAssertTrue(mockStyle.removeImageStub.invocations.isEmpty)

        // when
        sut.removeImage(imageId)
        // then
        XCTAssertEqual(try XCTUnwrap(mockStyle.removeImageStub.invocations.last?.parameters), imageId)
    }

    func testAnnotationImagesRemovedFromStyleIfNoConsumers() throws {
        // given
        let consumer = MockAnnotationImagesConsumer()
        sut.register(imagesConsumer: consumer)

        for _ in 0...10 {
            sut.addImage(UIImage(), id: UUID().uuidString, sdf: false, contentInsets: .zero)
        }
        let imageId = "image-id"
        sut.addImage(UIImage(), id: imageId, sdf: false, contentInsets: .zero)

        mockStyle.imageExistsStub.defaultReturnValue = true

        // when
        consumer.isUsingStyleImageStub.defaultReturnValue = true
        sut.removeImage(imageId)
        // then
        XCTAssertTrue(mockStyle.removeImageStub.invocations.isEmpty)

        // when
        consumer.isUsingStyleImageStub.defaultReturnValue = false
        sut.removeImage(imageId)
        // then
        XCTAssertEqual(try XCTUnwrap(mockStyle.removeImageStub.invocations.last?.parameters), imageId)

        // when
        sut.unregister(imagesConsumer: consumer)
        sut.removeImage(imageId)
        // then
        XCTAssertEqual(try XCTUnwrap(mockStyle.removeImageStub.invocations.last?.parameters), imageId)
    }
}

private class MockAnnotationImagesConsumer: AnnotationImagesConsumer {
    let isUsingStyleImageStub = Stub<String, Bool>(defaultReturnValue: false)
    func isUsingStyleImage(_ imageName: String) -> Bool {
        isUsingStyleImageStub.call(with: imageName)
    }
}
