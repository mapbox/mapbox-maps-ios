import XCTest
@testable import MapboxMaps

internal class ExpressionTests: XCTestCase {

    internal func testExpressionValidity() {
        let sumExp = Exp(.sum) {
            10
            12
        }

        XCTAssertEqual(sumExp.operator, .sum)
        XCTAssertEqual(sumExp.arguments.count, 2)
        XCTAssertEqual(sumExp.arguments[0], .number(10))
        XCTAssertEqual(sumExp.arguments[1], .number(12))
    }
    //swiftlint:enable statement_position

    // Validates basic expression semantics
    internal func expressionValidator(exp: Exp) {
        XCTAssertNotNil(exp.operator)
        XCTAssertTrue(exp.arguments.count >= 1)
    }

    internal func testColorBasedExpression() throws {
        let expression = Exp(.interpolate) {
            Exp(.linear)
            Exp(.zoom)
            0
            UIColor.red
            14
            UIColor.blue
        }
        expressionValidator(exp: expression)
    }

    internal func testExpressionDecodingOnEmptyJSON() throws {

        let jsonString =
        """
        [ "format",
          {
          }
        ]
        """

        let data = jsonString.data(using: .utf8)
        XCTAssertNotNil(data)

        do {
            let decodedExpression = try JSONDecoder().decode(Expression.self, from: data!)
            XCTAssertEqual(decodedExpression.operator, .format)
            verifyExpressionArgument(for: decodedExpression,
                                     toMatch: .option(.format(FormatOptions())),
                                     at: 1)
        } catch {
            XCTFail("Could not decode empty json as format expression")
        }
    }

    // MARK: - Helpers
    internal func verifyExpressionArgument(for expression: Expression, toMatch argument: Expression.Argument, at index: Int) {

        guard let op = expression.elements.first, case .operator = op else {
            XCTFail("There was no valid operator in the first element of the expression array")
            return
        }

        let arg = expression.elements[index]
        guard case let .argument(validArg) = arg else {
            XCTFail("There was no valid argument in the element at index = \(index) of the expression array")
            return
        }
        print(validArg)

        XCTAssertEqual(validArg, argument)
    }
}
