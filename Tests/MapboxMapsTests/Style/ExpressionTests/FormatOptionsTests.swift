import XCTest
@testable import MapboxMaps

final class FormatOptionsTests: XCTestCase {

    func testDecodeWithExpression() throws {
        let formatOptionsData = """
            {
                "font-scale": [
                    "case",
                    [
                        ">=",
                        ["to-number", ["get", "point"]],
                        4
                    ],
                    1,
                    2
                ],
                "text-font": [
                    "case",
                    [
                        ">=",
                        ["to-number", ["get", "point"]],
                        4
                    ],
                    ["Open Sans Semibold"],
                    ["Arial Unicode MS Bold"]
                ],
                "text-color": [
                    "case",
                    [
                        ">=",
                        ["to-number", ["get", "point"]],
                        4
                    ],
                    "#ffffff",
                    "#000000"
                ]
            }
            """.data(using: .utf8)

        let formatOptions = try JSONDecoder().decode(FormatOptions.self, from: try XCTUnwrap(formatOptionsData))
    }

    func testDecodeWithValue() throws {
        let formatOptionsData = """
            {
                "font-scale": 1,
                "text-font": ["Open Sans Semibold", "Arial Unicode MS Bold"],
                "text-color": "rgba(0,0,0,0)"
            }
            """.data(using: .utf8)

        let formatOptions = try JSONDecoder().decode(FormatOptions.self, from: try XCTUnwrap(formatOptionsData))
        XCTAssertEqual(formatOptions.fontScale, 1)
        XCTAssertEqual(formatOptions.textFont, ["Open Sans Semibold", "Arial Unicode MS Bold"])
        XCTAssertNotNil(formatOptions.textColor?.rgbaString, "rgba (0, 0, 0, 0)")
    }
}
