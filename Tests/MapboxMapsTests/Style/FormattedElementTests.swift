import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class FormattedElementTests: XCTestCase {

    func testDictionaryInit() {
        let dict: [String: FormatOptions] = [
            "First": FormatOptions(fontScale: 10.0, textFont: nil, textColor: nil),
            "Second": FormatOptions(fontScale: 11.0, textFont: nil, textColor: nil)
        ]

        let formatted = Formatted(with: dict)

        switch formatted {
        case .format(let elements):
            XCTAssertEqual(elements.count, 5)
        default:
            XCTFail("Incorrect formatted type")
        }
    }


    func testStringInit() {
        let formatted = Formatted(with: "some test string")

        switch formatted {
        case .string(let substring):
            XCTAssertEqual(substring, "some test string")
        default:
            XCTFail("Incorrect formatted type")
        }
    }

    func testJsonDecoderAsString() throws {
        let jsonString =
            """
            [
                "step",
                ["get", "sizerank"],
                [
                    "coalesce",
                    ["get", "name_en"],
                    ["get", "name"]
                ],
                15,
                ["get", "ref"]
            ]
            """

        var data: Data?

        do {
            data = try JSONEncoder().encode(jsonString)
        } catch {
            XCTFail("Failed to encode json.")
        }

        guard let validData = data else {
            XCTFail("Failed to encode json.")
            return
        }

        do {
            let decodedFormatted = try JSONDecoder().decode(Formatted.self, from: validData)

            switch decodedFormatted {
            case .string(let substring):
                XCTAssert(true, "The JSON was decoded to the correct format")
            default:
                XCTFail("Incorrect formatted type.")
            }
        }
    }
}
