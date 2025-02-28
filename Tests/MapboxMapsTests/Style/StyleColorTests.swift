import XCTest
@testable import MapboxMaps

final class StyleColorTests: XCTestCase {

    var red: Double!
    var green: Double!
    var blue: Double!
    var alpha: Double!
    var colorSpaces: [CGColorSpace]!
    var hue: Double!
    var saturation: Double!
    var lightness: Double!

    var rgbString: String { String(format: "rgb(%.2f, %.2f, %.2f)", red, green, blue) }
    var rgbaString: String { String(format: "rgba(%.2f, %.2f, %.2f, %.2f)", red, green, blue, alpha) }
    var hslString: String { String(format: "hsl(%.2f, %.2f, %.2f)", hue, saturation, lightness) }
    var hslaString: String { String(format: "hsla(%.2f, %.2f, %.2f, %.2f)", hue, saturation, lightness, alpha) }

    override func setUp() {
        super.setUp()
        colorSpaces = [
            CGColorSpace.genericCMYK,
            CGColorSpace.displayP3,
            CGColorSpace.genericRGBLinear,
            CGColorSpace.adobeRGB1998,
            CGColorSpace.sRGB,
            CGColorSpace.genericGrayGamma2_2,
            CGColorSpace.genericXYZ,
            CGColorSpace.genericLab,
            CGColorSpace.acescgLinear,
            CGColorSpace.itur_709,
            CGColorSpace.itur_2020,
            CGColorSpace.rommrgb,
            CGColorSpace.dcip3,
            CGColorSpace.extendedSRGB,
            CGColorSpace.linearSRGB,
            CGColorSpace.extendedLinearSRGB,
            CGColorSpace.extendedGray,
            CGColorSpace.linearGray,
            CGColorSpace.extendedLinearGray,
        ].map { CGColorSpace(name: $0)! }
        red = 83
        green = 67
        blue = 219
        hue = 93
        saturation = 37
        lightness = 8
        alpha = 0.5
    }

    override func tearDown() {
        alpha = nil
        blue = nil
        green = nil
        red = nil
        colorSpaces = nil
        hue = nil
        saturation = nil
        lightness = nil
        super.tearDown()
    }

    func testComponentWiseInit() {
        XCTAssertEqual(StyleColor(red: red, green: green, blue: blue)?.rawValue, rgbString)
        XCTAssertEqual(StyleColor(red: red, green: green, blue: blue, alpha: alpha)?.rawValue, rgbaString)
        XCTAssertEqual(StyleColor(hue: hue, saturation: saturation, lightness: lightness)?.rawValue, hslString)
        XCTAssertEqual(StyleColor(hue: hue, saturation: saturation, lightness: lightness, alpha: alpha)?.rawValue, hslaString)
    }

    func testComponentWiseInitFailure() {
        for invalidComponent in [-1.0, 10000.0] {
            XCTAssertNil(StyleColor(red: invalidComponent, green: 0, blue: 0))
            XCTAssertNil(StyleColor(red: 0, green: invalidComponent, blue: 0))
            XCTAssertNil(StyleColor(red: 0, green: 0, blue: invalidComponent))

            XCTAssertNil(StyleColor(red: invalidComponent, green: 0, blue: 0, alpha: 0))
            XCTAssertNil(StyleColor(red: 0, green: invalidComponent, blue: 0, alpha: 0))
            XCTAssertNil(StyleColor(red: 0, green: 0, blue: invalidComponent, alpha: 0))
            XCTAssertNil(StyleColor(red: 0, green: 0, blue: 0, alpha: invalidComponent))

            XCTAssertNil(StyleColor(hue: invalidComponent, saturation: 0, lightness: 0))
            XCTAssertNil(StyleColor(hue: 0, saturation: invalidComponent, lightness: 0))
            XCTAssertNil(StyleColor(hue: 0, saturation: 0, lightness: invalidComponent))

            XCTAssertNil(StyleColor(hue: invalidComponent, saturation: 0, lightness: 0, alpha: 0))
            XCTAssertNil(StyleColor(hue: 0, saturation: invalidComponent, lightness: 0, alpha: 0))
            XCTAssertNil(StyleColor(hue: 0, saturation: 0, lightness: invalidComponent, alpha: 0))
            XCTAssertNil(StyleColor(hue: 0, saturation: 0, lightness: 0, alpha: invalidComponent))
        }
    }

    func testUIColorInit() {
        let rgbaColor = StyleColor(UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha))
        let hslaColor = StyleColor(UIColor(hue: hue / 360.0, saturation: saturation / 100.0, brightness: lightness / 100.0, alpha: alpha))

        XCTAssertEqual(rgbaColor.rawValue, rgbaString)
        XCTAssertEqual(hslaColor.rawValue, "rgba(16.25, 20.40, 12.85, 0.50)")
    }

    func testExpressionInit() {
        let expressions = [
            Exp(.rgb) { red!; green!; blue! },
            Exp(.rgba) { red!; green!; blue!; alpha! },
            Exp(.hsl) { hue!; saturation!; lightness! },
            Exp(.hsla) { hue!; saturation!; lightness!; alpha! }
        ]
        let expectedColorStrings = [
            rgbString,
            rgbaString,
            hslString,
            hslaString
        ]

        for (expression, colorString) in zip(expressions, expectedColorStrings) {
            XCTAssertEqual(StyleColor(expression: expression)?.rawValue, colorString)
        }
    }

    func testExpressionInitFailureWrongOperator() {
        let expression = Exp(.init(rawValue: .randomASCII(withLength: 10))) {
            red!
            green!
            blue!
            alpha!
        }
        XCTAssertNil(StyleColor(expression: expression))
    }

    func testExpressionInitFailureValuesOutOfBounds() {
        let invalidComponents = [
            [0, 0, -1],
            [0, 0, 1000]
        ].map { $0.map(Exp.Argument.number) }

        for var components in invalidComponents {
            for _ in 0..<components.count {
                XCTAssertNil(StyleColor(expression: Exp(operator: .rgb, arguments: components)))
                XCTAssertNil(StyleColor(expression: Exp(operator: .rgba, arguments: components + [.number(0)])))
                XCTAssertNil(StyleColor(expression: Exp(operator: .hsl, arguments: components)))
                XCTAssertNil(StyleColor(expression: Exp(operator: .hsla, arguments: components + [.number(0)])))

                // shift the invalid component by one to the left to test all of them
                components = components.rotatingLeft(positions: 1)
            }
        }

        // tests handling of invalid alpha component
        XCTAssertNil(StyleColor(expression: Exp(operator: .rgba, arguments: [.number(0), .number(0), .number(0), .number(-1)])))
        XCTAssertNil(StyleColor(expression: Exp(operator: .rgba, arguments: [.number(0), .number(0), .number(0), .number(1000)])))
        XCTAssertNil(StyleColor(expression: Exp(operator: .hsla, arguments: [.number(0), .number(0), .number(0), .number(-1)])))
        XCTAssertNil(StyleColor(expression: Exp(operator: .hsla, arguments: [.number(0), .number(0), .number(0), .number(1000)])))
    }

    func testExpressionInitFailureTooFewArguments() {
        XCTAssertNil(StyleColor(expression: Exp(operator: .rgb, arguments: [.number(0), .number(0)])))
        XCTAssertNil(StyleColor(expression: Exp(operator: .rgba, arguments: [.number(0), .number(0), .number(9)])))
        XCTAssertNil(StyleColor(expression: Exp(operator: .hsl, arguments: [.number(0), .number(0)])))
        XCTAssertNil(StyleColor(expression: Exp(operator: .hsla, arguments: [.number(0), .number(0), .number(9)])))
    }

    func testExpressionInitFailureTooManyArguments() {
        XCTAssertNil(StyleColor(expression: Exp(operator: .rgb, arguments: [.number(0), .number(0), .number(9), .number(9)])))
        XCTAssertNil(StyleColor(expression: Exp(operator: .rgba, arguments: [.number(0), .number(0), .number(9), .number(3), .number(3)])))
        XCTAssertNil(StyleColor(expression: Exp(operator: .hsl, arguments: [.number(0), .number(0), .number(9), .number(9)])))
        XCTAssertNil(StyleColor(expression: Exp(operator: .hsla, arguments: [.number(0), .number(0), .number(9), .number(3), .number(3)])))
    }

    func testStringInit() {
        let colorString = "rgb(1,2,3)"
        XCTAssertEqual(StyleColor(rawValue: colorString).rawValue, colorString)
    }

    func testLiteralInit() {
        XCTAssertEqual("rgb(1,2,3)" as StyleColor, "rgb(1,2,3)")
        XCTAssertEqual("rgb(\(1),\(2),\(3))" as StyleColor, "rgb(1,2,3)")
    }

    func testEquatable() {
        XCTAssertEqual(
            StyleColor(red: red, green: green, blue: blue),
            StyleColor(red: red, green: green, blue: blue)
        )
        XCTAssertEqual(
            StyleColor(red: red, green: green, blue: blue, alpha: alpha),
            StyleColor(red: red, green: green, blue: blue, alpha: alpha)
        )
        XCTAssertEqual(
            StyleColor(hue: hue, saturation: saturation, lightness: lightness),
            StyleColor(hue: hue, saturation: saturation, lightness: lightness)
        )
        XCTAssertEqual(
            StyleColor(hue: hue, saturation: saturation, lightness: lightness, alpha: alpha),
            StyleColor(hue: hue, saturation: saturation, lightness: lightness, alpha: alpha)
        )
    }

    func testCodableRoundtrip() throws {
        let colors = [
            StyleColor(red: red, green: green, blue: blue)!,
            StyleColor(red: red, green: green, blue: blue, alpha: alpha)!,
            StyleColor(hue: hue, saturation: saturation, lightness: lightness)!,
            StyleColor(hue: hue, saturation: saturation, lightness: lightness, alpha: alpha)!
        ]
        for color in colors {
            // wrapping in an array since iOS 12 and lower only support
            // Array and Dictionary as the top level JSON values
            let data = try JSONEncoder().encode([color])

            let decodedColor = try JSONDecoder().decode([StyleColor].self, from: data)

            XCTAssertEqual(decodedColor, [color])
        }
    }

    func testEncoding() throws {
        let colors = [
            StyleColor(red: red, green: green, blue: blue)!,
            StyleColor(red: red, green: green, blue: blue, alpha: alpha)!,
            StyleColor(hue: hue, saturation: saturation, lightness: lightness)!,
            StyleColor(hue: hue, saturation: saturation, lightness: lightness, alpha: alpha)!
        ]
        let expectedColorStrings = [rgbString, rgbaString, hslString, hslaString]

        for (color, expectedColorString) in zip(colors, expectedColorStrings) {
            // wrapping in an array since iOS 12 and lower only support
            // Array and Dictionary as the top level JSON values
            let data = try JSONEncoder().encode([color])

            // Double quotes are added to the expected value to make it a JSON string
            XCTAssertEqual(data, Data(#"["\#(expectedColorString)"]"#.utf8))
        }
    }

    func testDecodingExpression() throws {
        let rawExpressions = [
            #"["rgb",\#(red!),\#(green!),\#(blue!)]"#,
            #"["rgba",\#(red!),\#(green!),\#(blue!),\#(alpha!)]"#,
            #"["hsl",\#(hue!),\#(saturation!),\#(lightness!)]"#,
            #"["hsla",\#(hue!),\#(saturation!),\#(lightness!),\#(alpha!)]"#
        ]
        let expectedColorStrings = [rgbString, rgbaString, hslString, hslaString]

        for (rawExpression, colorString) in zip(rawExpressions, expectedColorStrings) {
            let color = try JSONDecoder().decode(StyleColor.self, from: rawExpression.data(using: .utf8)!)

            XCTAssertEqual(color.rawValue, colorString)
        }
    }

    func testDecodingString() throws {
        let colorStrings = [rgbString, rgbaString, hslString, hslaString]
        let expectedColors = [
            StyleColor(red: red, green: green, blue: blue)!,
            StyleColor(red: red, green: green, blue: blue, alpha: alpha)!,
            StyleColor(hue: hue, saturation: saturation, lightness: lightness)!,
            StyleColor(hue: hue, saturation: saturation, lightness: lightness, alpha: alpha)!
        ]

        for (colorString, expectedColor) in zip(colorStrings, expectedColors) {
            // wrapping in an array since iOS 12 and lower only support
            // Array and Dictionary as the top level JSON values
            // Double quotes are added to make it a JSON string
            let rgbaJSONString = Data(#"["\#(colorString)"]"#.utf8)

            let color = try JSONDecoder().decode([StyleColor].self, from: rgbaJSONString)

            XCTAssertEqual(color, [expectedColor])
        }
    }

        func testColorSpacesWithStandardRangeColorValues() throws {
        // given
        let uiColors = colorSpaces
            .map { CGColor(colorSpace: $0, components: [0.5, 0.5, 0.5, 0.5, 0.5])! }
            .map { UIColor(cgColor: $0) }

        // when
        // colors are successfully converted
        let styleColors = uiColors.map { StyleColor($0) }

        // the test will fail if StyleColor can't be initialized with the supplied color space
        XCTAssertEqual(styleColors.count, colorSpaces.count)
    }

    func testColorSpacesWithExtendedRangeColorValues() throws {
        // given
        let uiColors = colorSpaces
            .map { CGColor(colorSpace: $0, components: [-1.0, 0.5, 2, 3, 5])! }
            .map { UIColor(cgColor: $0) }

        // when
        // colors are successfully converted
        let styleColors = uiColors.map { StyleColor($0) }

        // the test will fail if StyleColor can't be initialized with the supplied color space
        XCTAssertEqual(styleColors.count, colorSpaces.count)
    }

    func testFaultyUIColorFallsToBlack() {
        // given
        let faultyUIColor = UIColor(patternImage: .empty)

        // when
        let styleColor = StyleColor(faultyUIColor)

        // then
        XCTAssertEqual(styleColor.rawValue, "rgba(0.00, 0.00, 0.00, 1.00)")
    }
}

extension Array {
    func rotatingLeft(positions: Int) -> Self {
        let index = index(startIndex, offsetBy: positions, limitedBy: endIndex) ?? endIndex
        return Array(self[index...] + self[..<index])
    }
}
