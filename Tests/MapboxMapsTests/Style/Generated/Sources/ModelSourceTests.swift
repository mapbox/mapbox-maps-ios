// This file is generated.
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class ModelSourceTests: XCTestCase {

    func testEncodingAndDecoding() {
        var source = ModelSource(id: "test-source")
        source.url = String.testSourceValue()
        source.maxzoom = Double.testSourceValue()
        source.minzoom = Double.testSourceValue()
        source.tiles = [String].testSourceValue()
        source.models = [Model].testSourceValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(source)
        } catch {
            XCTFail("Failed to encode ModelSource.")
        }

        guard let validData = data else {
            XCTFail("Failed to encode ModelSource.")
            return
        }

        do {
            let decodedSource = try JSONDecoder().decode(ModelSource.self, from: validData)
            XCTAssert(decodedSource.type == SourceType.model)
            XCTAssert(decodedSource.url == String.testSourceValue())
            XCTAssert(decodedSource.maxzoom == Double.testSourceValue())
            XCTAssert(decodedSource.minzoom == Double.testSourceValue())
            XCTAssert(decodedSource.tiles == [String].testSourceValue())
            XCTAssert(decodedSource.models == [Model].testSourceValue())
        } catch {
            XCTFail("Failed to decode ModelSource.")
        }
    }

    func testSetPropertyValueWithFunction() {
        let source = ModelSource(id: "test-source")
            .url(String.testSourceValue())
            .maxzoom(Double.testSourceValue())
            .minzoom(Double.testSourceValue())
            .tiles([String].testSourceValue())
            .models([Model].testSourceValue())

        XCTAssertEqual(source.url, String.testSourceValue())
        XCTAssertEqual(source.maxzoom, Double.testSourceValue())
        XCTAssertEqual(source.minzoom, Double.testSourceValue())
        XCTAssertEqual(source.tiles, [String].testSourceValue())
        XCTAssertEqual(source.models, [Model].testSourceValue())
    }
}

// End of generated file
