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
        let imageID = UUID().uuidString, sdf = Bool.random(), contentInsets = UIEdgeInsets.random()

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
        let imageIDs = Array.random(withLength: 10) { UUID().uuidString }
        for imageID in imageIDs {
            sut.addImage(UIImage(), id: imageID, sdf: .random(), contentInsets: .random())
        }
        mockStyle.imageExistsStub.defaultReturnValue = true

        // when
        sut.removeImage("unowned-image-id")
        // then
        XCTAssertTrue(mockStyle.removeImageStub.invocations.isEmpty)

        // when
        let imageToRemove = try XCTUnwrap(imageIDs.randomElement())
        sut.removeImage(imageToRemove)
        // then
        XCTAssertEqual(try XCTUnwrap(mockStyle.removeImageStub.invocations.last?.parameters), imageToRemove)
    }

    func testAnnotationImagesRemovedFromStyleIfNoConsumers() throws {
        // given
        let consumer = MockAnnotationImagesConsumer()
        sut.register(imagesConsumer: consumer)

        let imageIDs = Array.random(withLength: 10) { UUID().uuidString }
        for imageID in imageIDs {
            sut.addImage(UIImage(), id: imageID, sdf: .random(), contentInsets: .random())
        }
        mockStyle.imageExistsStub.defaultReturnValue = true

        // when
        let imageToRemove = try XCTUnwrap(imageIDs.randomElement())
        consumer.isUsingStyleImageStub.defaultReturnValue = true
        sut.removeImage(imageToRemove)
        // then
        XCTAssertTrue(mockStyle.removeImageStub.invocations.isEmpty)

        // when
        consumer.isUsingStyleImageStub.defaultReturnValue = false
        sut.removeImage(imageToRemove)
        // then
        XCTAssertEqual(try XCTUnwrap(mockStyle.removeImageStub.invocations.last?.parameters), imageToRemove)

        // when
        sut.unregister(imagesConsumer: consumer)
        sut.removeImage(imageToRemove)
        // then
        XCTAssertEqual(try XCTUnwrap(mockStyle.removeImageStub.invocations.last?.parameters), imageToRemove)
    }
}

private class MockAnnotationImagesConsumer: AnnotationImagesConsumer {
    let isUsingStyleImageStub = Stub<String, Bool>(defaultReturnValue: false)
    func isUsingStyleImage(_ imageName: String) -> Bool {
        isUsingStyleImageStub.call(with: imageName)
    }
}
