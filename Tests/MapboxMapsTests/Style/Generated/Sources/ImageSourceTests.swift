// This file is generated.
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class ImageSourceTests: XCTestCase {

    func testEncodingAndDecoding() {
        var source = ImageSource(id: "test-source")
        source.url = String.testSourceValue()
        source.coordinates = [[Double]].testSourceValue()
        source.prefetchZoomDelta = Double.testSourceValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(source)
        } catch {
            XCTFail("Failed to encode ImageSource.")
        }

        guard let validData = data else {
            XCTFail("Failed to encode ImageSource.")
            return
        }

        do {
            let decodedSource = try JSONDecoder().decode(ImageSource.self, from: validData)
            XCTAssert(decodedSource.type == SourceType.image)
            XCTAssert(decodedSource.url == String.testSourceValue())
            XCTAssert(decodedSource.coordinates == [[Double]].testSourceValue())
            XCTAssert(decodedSource.prefetchZoomDelta == Double.testSourceValue())
        } catch {
            XCTFail("Failed to decode ImageSource.")
        }
    }

    func testSetPropertyValueWithFunction() {
        let source = ImageSource(id: "test-source")
            .url(String.testSourceValue())
            .coordinates([[Double]].testSourceValue())
            .prefetchZoomDelta(Double.testSourceValue())

        XCTAssertEqual(source.url, String.testSourceValue())
        XCTAssertEqual(source.coordinates, [[Double]].testSourceValue())
        XCTAssertEqual(source.prefetchZoomDelta, Double.testSourceValue())
    }
}

// End of generated file
