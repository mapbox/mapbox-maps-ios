import XCTest
@testable import MapboxMaps

final class StyleColorTests: XCTestCase {

    var red: Double!
    var green: Double!
    var blue: Double!
    var alpha: Double!

    var rgbaString: String {
        "rgba(\(red!), \(green!), \(blue!), \(alpha!))"
    }

    override func setUp() {
        super.setUp()
        red = .random(in: 0...255)
        green = .random(in: 0...255)
        blue = .random(in: 0...255)
        alpha = .random(in: 0...1)
    }

    override func tearDown() {
        alpha = nil
        blue = nil
        green = nil
        red = nil
        super.tearDown()
    }

    func verify(_ styleColor: StyleColor?, line: UInt = #line) {
        XCTAssertEqual(styleColor?.red, red, line: line)
        XCTAssertEqual(styleColor?.green, green, line: line)
        XCTAssertEqual(styleColor?.blue, blue, line: line)
        XCTAssertEqual(styleColor?.alpha, alpha, line: line)
    }

    func invalidComponentValue(outsideOf range: ClosedRange<Double>) -> Double {
        precondition(range.lowerBound != -.greatestFiniteMagnitude)
        precondition(range.upperBound != .greatestFiniteMagnitude)
        return Bool.random()
            ? .random(in: -.greatestFiniteMagnitude...range.lowerBound)
            : .random(in: range.upperBound...(.greatestFiniteMagnitude))
    }

    func testComponentWiseInit() {
        verify(StyleColor(red: red, green: green, blue: blue, alpha: alpha))
    }

    func testComponentWiseInitFailure() {
        XCTAssertNil(StyleColor(red: invalidComponentValue(outsideOf: 0...255), green: 0, blue: 0, alpha: 0))
        XCTAssertNil(StyleColor(red: 0, green: invalidComponentValue(outsideOf: 0...255), blue: 0, alpha: 0))
        XCTAssertNil(StyleColor(red: 0, green: 0, blue: invalidComponentValue(outsideOf: 0...255), alpha: 0))
        XCTAssertNil(StyleColor(red: 0, green: 0, blue: 0, alpha: invalidComponentValue(outsideOf: 0...1)))
    }

    func testUIColorInit() {
        // use local input values since the ones from setUp are in the wrong range for this test
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        let alpha = CGFloat.random(in: 0...1)

        let color = StyleColor(UIColor(red: red, green: green, blue: blue, alpha: alpha))

        XCTAssertEqual(color.red, Double(red * 255))
        XCTAssertEqual(color.green, Double(green * 255))
        XCTAssertEqual(color.blue, Double(blue * 255))
        XCTAssertEqual(color.alpha, Double(alpha))
    }

    func testExpressionInit() {
        let expression = Exp(.rgba) {
            red!
            green!
            blue!
            alpha!
        }

        verify(StyleColor(expression: expression))
    }

    func testExpressionInitFailureWrongOperator() {
        let op = Expression.Operator.allCases.filter { $0 != .rgba }.randomElement()!
        let expression = Exp(op) {
            red!
            green!
            blue!
            alpha!
        }
        XCTAssertNil(StyleColor(expression: expression))
    }

    func testExpressionInitFailureValuesOutOfBounds() {
        func makeExpression(red: Double = 0, green: Double = 0, blue: Double = 0, alpha: Double = 0) -> Expression {
            Exp(.rgba) {
                red
                green
                blue
                alpha
            }
        }
        XCTAssertNil(StyleColor(expression: makeExpression(red: invalidComponentValue(outsideOf: 0...255))))
        XCTAssertNil(StyleColor(expression: makeExpression(green: invalidComponentValue(outsideOf: 0...255))))
        XCTAssertNil(StyleColor(expression: makeExpression(blue: invalidComponentValue(outsideOf: 0...255))))
        XCTAssertNil(StyleColor(expression: makeExpression(alpha: invalidComponentValue(outsideOf: 0...1))))
    }

    func testExpressionInitFailureTooFewArguments() {
        XCTAssertNil(StyleColor(expression: Exp(operator: .rgba, arguments: Array(repeating: .number(0), count: .random(in: 0...3)))))
    }

    func testExpressionInitFailureTooManyArguments() {
        XCTAssertNil(StyleColor(expression: Exp(operator: .rgba, arguments: Array(repeating: .number(0), count: .random(in: 5...20)))))
    }

    func testRGBAStringInit() {
        func randomSpaces() -> String {
            String(repeating: " ", count: .random(in: 0...100))
        }
        verify(StyleColor(rgbaString: "\(randomSpaces())rgba(\(randomSpaces())\(red!)\(randomSpaces()),\(randomSpaces())\(green!)\(randomSpaces()),\(randomSpaces())\(blue!)\(randomSpaces()),\(randomSpaces())\(alpha!)\(randomSpaces()))\(randomSpaces())"))
    }

    func testRGBAStringInitNoDecimals() {
        red = 1
        green = 2
        blue = 3
        alpha = 0
        verify(StyleColor(rgbaString: "rgba(1,2,3,0)"))
    }

    func testRGBAStringInitFailureInvalidStructure() {
        XCTAssertNil(StyleColor(rgbaString: ""))
        XCTAssertNil(StyleColor(rgbaString: "rgba (0, 0, 0, 0)"))
        XCTAssertNil(StyleColor(rgbaString: "rgb(0, 0, 0)"))
        XCTAssertNil(StyleColor(rgbaString: "rgb(0, 0, 0, 0)"))
        XCTAssertNil(StyleColor(rgbaString: "rgba(0, 0, 0)"))
        XCTAssertNil(StyleColor(rgbaString: "rgba(a, b, c)"))
        XCTAssertNil(StyleColor(rgbaString: "rgba(0.0.0, 0.0.0, 0.0.0, 0.0.0)"))
        XCTAssertNil(StyleColor(rgbaString: "abcdrgba(1,2,3,0)"))
        XCTAssertNil(StyleColor(rgbaString: "rgba(1,2,3,0)abcd"))
    }

    func testRGBAStringInitFailureValuesOutOfBounds() {
        func makeRGBAString(red: Double = 0, green: Double = 0, blue: Double = 0, alpha: Double = 0) -> String {
            "rgba(\(red),\(green),\(blue),\(alpha))"
        }
        XCTAssertNil(StyleColor(rgbaString: makeRGBAString(red: invalidComponentValue(outsideOf: 0...255))))
        XCTAssertNil(StyleColor(rgbaString: makeRGBAString(green: invalidComponentValue(outsideOf: 0...255))))
        XCTAssertNil(StyleColor(rgbaString: makeRGBAString(blue: invalidComponentValue(outsideOf: 0...255))))
        XCTAssertNil(StyleColor(rgbaString: makeRGBAString(alpha: invalidComponentValue(outsideOf: 0...1))))
    }

    func testRGBAString() {
        let styleColor = StyleColor(red: red, green: green, blue: blue, alpha: alpha)

        XCTAssertEqual(styleColor?.rgbaString, rgbaString)
    }

    func testEquatable() {
        XCTAssertEqual(
            StyleColor(red: red, green: green, blue: blue, alpha: alpha),
            StyleColor(red: red, green: green, blue: blue, alpha: alpha))
    }

    func testCodableRoundtrip() throws {
        let color = StyleColor(red: red, green: green, blue: blue, alpha: alpha)!

        let data = try JSONEncoder().encode(color)

        let decodedColor = try JSONDecoder().decode(StyleColor.self, from: data)

        XCTAssertEqual(decodedColor, color)
    }

    func testEncoding() throws {
        let color = StyleColor(red: red, green: green, blue: blue, alpha: alpha)!

        let data = try JSONEncoder().encode(color)

        // Double quotes are added to the expected value to make it a JSON string
        XCTAssertEqual(data, #""\#(rgbaString)""#.data(using: .utf8))
    }

    func testDecodingRGBAExpression() throws {
        let expressionData = #"["rgba",\#(red!),\#(green!),\#(blue!),\#(alpha!)]"#.data(using: .utf8)!

        let color = try JSONDecoder().decode(StyleColor.self, from: expressionData)

        XCTAssertEqual(color, StyleColor(red: red, green: green, blue: blue, alpha: alpha)!)
    }

    func testDecodingRGBAString() throws {
        // Double quotes are added to make it a JSON string
        let rgbaJSONString = #""\#(rgbaString)""#.data(using: .utf8)!

        let color = try JSONDecoder().decode(StyleColor.self, from: rgbaJSONString)

        XCTAssertEqual(color, StyleColor(red: red, green: green, blue: blue, alpha: alpha)!)
    }
}
