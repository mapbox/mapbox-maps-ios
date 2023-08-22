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
            try formatOptions.fontScaleValue?.toString(),
            #"["case",[">=",["to-number",["get","point_count"]],4],1,2]"#)
        XCTAssertEqual(
            try formatOptions.textFontValue?.toString(),
            #"["case",[">=",["to-number",["get","point_count"]],4],["Open Sans Semibold"],["Arial Unicode MS Bold"]]"#)
        XCTAssertEqual(
            try formatOptions.textColorValue?.toString(),
            ##"["case",[">=",["to-number",["get","point_count"]],4],"#ffffff","#000000"]"##)
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
        XCTAssertEqual(formatOptions.textColor?.rgbaString, "rgba(0.0, 0.0, 0.0, 0.0)")
    }

    func testEncodeWithValue() throws {
        let formatOptions = FormatOptions(fontScale: 1, textFont: ["Open Sans Semibold", "Arial Unicode MS Bold"], textColor: .black)
        let encoded = try DictionaryEncoder().encode(formatOptions)

        XCTAssertEqual(encoded["font-scale"] as? Double, 1)
        XCTAssertEqual(encoded["text-font"] as? [String], ["Open Sans Semibold", "Arial Unicode MS Bold"])
        XCTAssertEqual(encoded["text-color"] as? String, "rgba(0.0, 0.0, 0.0, 1.0)")
    }

    func testEncodeWithConstantAndExpression() throws {
        let formatOptions = FormatOptions(
            fontScale: .constant(1),
            textFont: .constant(["Open Sans Semibold", "Arial Unicode MS Bold"]),
            textColor: .expression(Exp(.switchCase) {
                Exp(.gte) {
                    Exp(.toNumber) {
                        Exp(.get) { "point_count" }
                    }
                    4
                }
                "#ffffff"
                "#000000"
            }))
        XCTAssertEqual(formatOptions.fontScale, 1)
        XCTAssertEqual(formatOptions.textFont, ["Open Sans Semibold", "Arial Unicode MS Bold"])
        XCTAssertNil(formatOptions.textColor)
        let encoded = try DictionaryEncoder().encode(formatOptions)

        XCTAssertEqual(encoded["font-scale"] as? Double, 1)
        XCTAssertEqual(encoded["text-font"] as? [String], ["Open Sans Semibold", "Arial Unicode MS Bold"])
        XCTAssertEqual(
            String(data: try JSONSerialization.data(withJSONObject: encoded["text-color"] as Any), encoding: .utf8),
            ##"["case",[">=",["to-number",["get","point_count"]],4],"#ffffff","#000000"]"##
        )
    }

    func testEncodeWithExpression() throws {
        var formatOptions = FormatOptions(fontScale: 1, textFont: ["Open Sans Semibold", "Arial Unicode MS Bold"], textColor: .black)
        formatOptions.fontScaleValue = .expression(Exp(.switchCase) {
            Exp(.gte) {
                Exp(.toNumber) {
                    Exp(.get) { "point_count" }
                }
                4
            }
            1
            2
        })
        formatOptions.textFontValue = .expression(Exp(.switchCase) {
            Exp(.gte) {
                Exp(.toNumber) {
                    Exp(.get) { "point_count" }
                }
                4
            }
            ["Open Sans Semibold"]
            ["Arial Unicode MS Bold"]
        })
        formatOptions.textColorValue = .expression(Exp(.switchCase) {
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
            String(data: try JSONSerialization.data(withJSONObject: encoded["font-scale"] as Any), encoding: .utf8),
            #"["case",[">=",["to-number",["get","point_count"]],4],1,2]"#
        )
        XCTAssertEqual(
            String(data: try JSONSerialization.data(withJSONObject: encoded["text-font"] as Any), encoding: .utf8),
            #"["case",[">=",["to-number",["get","point_count"]],4],["Open Sans Semibold"],["Arial Unicode MS Bold"]]"#
        )
        XCTAssertEqual(
            String(data: try JSONSerialization.data(withJSONObject: encoded["text-color"] as Any), encoding: .utf8),
            ##"["case",[">=",["to-number",["get","point_count"]],4],"#ffffff","#000000"]"##
        )
    }
}
