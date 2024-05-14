import XCTest
@testable import MapboxMaps

final class FormatOptionsTests: XCTestCase {
    private let jsonString = """
        {
                "font-scale": [
                    "case",
                    [
                        ">=",
                        ["to-number", ["get", "point_count"]],
                        4
                    ],
                    1,
                    2
                ],
                "text-font": [
                    "case",
                    [
                        ">=",
                        ["to-number", ["get", "point_count"]],
                        4
                    ],
                    ["Open Sans Semibold"],
                    ["Arial Unicode MS Bold"]
                ],
                "text-color": [
                    "case",
                    [
                        ">=",
                        ["to-number", ["get", "point_count"]],
                        4
                    ],
                    "#ffffff",
                    "#000000"
                ]
        }
        """

    func testDecodeWithExpression() throws {
        let formatOptions = try JSONDecoder().decode(FormatOptions.self, from: try XCTUnwrap(jsonString.data(using: .utf8)))
        XCTAssertEqual(
            try formatOptions.fontScale?.toString(),
            #"["case",[">=",["to-number",["get","point_count"]],4],1,2]"#)
        XCTAssertEqual(
            try formatOptions.textFont?.toString(),
            #"["case",[">=",["to-number",["get","point_count"]],4],["Open Sans Semibold"],["Arial Unicode MS Bold"]]"#)
        XCTAssertEqual(
            try formatOptions.textColor?.toString(),
            ##"["case",[">=",["to-number",["get","point_count"]],4],"#ffffff","#000000"]"##)
    }

    func testDecodeWithValue() throws {
        let formatOptionsData = Data("""
            {
                "font-scale": 1,
                "text-font": ["Open Sans Semibold", "Arial Unicode MS Bold"],
                "text-color": "rgba(0,0,0,0)"
            }
            """.utf8)

        let formatOptions = try JSONDecoder().decode(FormatOptions.self, from: try XCTUnwrap(formatOptionsData))
        XCTAssertEqual(formatOptions.fontScale?.asConstant, 1)
        XCTAssertEqual(formatOptions.textFont?.asConstant, ["Open Sans Semibold", "Arial Unicode MS Bold"])
        XCTAssertEqual(formatOptions.textColor?.asConstant?.rawValue, "rgba(0,0,0,0)")
    }

    func testEncodeWithValue() throws {
        let formatOptions = FormatOptions(
            fontScale: .constant(1),
            textFont: .constant(["Open Sans Semibold", "Arial Unicode MS Bold"]),
            textColor: .constant(StyleColor(.black)))
        let encoded = try DictionaryEncoder().encode(formatOptions)

        XCTAssertEqual(encoded["font-scale"] as? Double, 1)
        XCTAssertEqual(encoded["text-font"] as? [String], ["Open Sans Semibold", "Arial Unicode MS Bold"])
        XCTAssertEqual(encoded["text-color"] as? String, "rgba(0.00, 0.00, 0.00, 1.00)")
    }

    func testEncodeWithExpression() throws {
        var formatOptions = FormatOptions()
        formatOptions.fontScale = .expression(Exp(.switchCase) {
            Exp(.gte) {
                Exp(.toNumber) {
                    Exp(.get) { "point_count" }
                }
                4
            }
            1
            2
        })
        formatOptions.textFont = .expression(Exp(.switchCase) {
            Exp(.gte) {
                Exp(.toNumber) {
                    Exp(.get) { "point_count" }
                }
                4
            }
            ["Open Sans Semibold"]
            ["Arial Unicode MS Bold"]
        })
        formatOptions.textColor = .expression(Exp(.switchCase) {
            Exp(.gte) {
                Exp(.toNumber) {
                    Exp(.get) { "point_count" }
                }
                4
            }
            "#ffffff"
            "#000000"
        })

        let encoded = try DictionaryEncoder().encode(formatOptions)
        XCTAssertEqual(
            String(decoding: try JSONSerialization.data(withJSONObject: encoded["font-scale"] as Any), as: UTF8.self),
            #"["case",[">=",["to-number",["get","point_count"]],4],1,2]"#
        )
        XCTAssertEqual(
            String(decoding: try JSONSerialization.data(withJSONObject: encoded["text-font"] as Any), as: UTF8.self),
            #"["case",[">=",["to-number",["get","point_count"]],4],["Open Sans Semibold"],["Arial Unicode MS Bold"]]"#
        )
        XCTAssertEqual(
            String(decoding: try JSONSerialization.data(withJSONObject: encoded["text-color"] as Any), as: UTF8.self),
            ##"["case",[">=",["to-number",["get","point_count"]],4],"#ffffff","#000000"]"##
        )
    }
}
