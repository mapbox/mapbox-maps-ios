// This file is generated.

import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
import Turf
#endif

class ImageSourceTests: XCTestCase {
    
    func testEncodingAndDecoding() {
        var source = ImageSource()
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
}
// End of generated file