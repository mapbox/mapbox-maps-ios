import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class FormattedElementTests: XCTestCase {

    func testDictionaryInit(){
        let dict: [String: FormatOptions] = [
            "First": FormatOptions(fontScale: 10.0, textFont: nil, textColor: nil),
            "Second": FormatOptions(fontScale: 11.0, textFont: nil, textColor: nil)
        ]

        let formatted = Formatted(with: dict)
    }

    func testStringInit() {

    }

}
