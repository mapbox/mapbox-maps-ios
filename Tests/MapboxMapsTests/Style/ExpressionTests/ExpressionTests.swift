import XCTest
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

internal class ExpressionTests: XCTestCase {

    internal func testRoundtripExpressionConversion() throws {
        let expression = Exp(.interpolate) {
            Exp(.linear)
            Exp(.zoom)
            0
            UIColor.red
            14
            UIColor.blue
        }

        do {
            let expressionAsJSON = try expression.jsonObject()
            let expressionAgain = Expression(from: expressionAsJSON)
            XCTAssert(expressionAgain != nil)
            XCTAssert(expression == expressionAgain!)
        } catch {
            XCTFail("Failed to convert expression to JSON and back")
        }
    }

    //swiftlint:disable statement_position
    internal func testExpressionValidity() {
        let sumExp = Exp(.sum) {
            10
            12
        }

        if case let Exp.Element.op(sumOp) = sumExp.elements[0],
           sumOp.rawValue == Exp.Operator.sum.rawValue { } else {
            XCTFail("First element is not the 'sum' expression operator")
        }

        if case let Exp.Element.argument(someArg) = sumExp.elements[1],
           case let Exp.Argument.number(someDouble) = someArg,
           someDouble == 10.0 { } else {
            XCTFail("Second element is not an expression argument with the correct value (10.0)")
        }

        if case let Exp.Element.argument(someArg) = sumExp.elements[2],
           case let Exp.Argument.number(someDouble) = someArg,
           someDouble == 12.0 { } else {
            XCTFail("Third element is not an expression argument with the correct value (12.0)")
        }
    }
    //swiftlint:enable statement_position

    // Validates basic expression semantics
    internal func expressionValidator(exp: Exp) {
        if exp.elements.count == 1 {
            if case Exp.Element.op(_) = exp.elements[0] {
                // First element is an operator
            } else {
                XCTFail("In an expression with one element, the element MUST be an operator")
            }
        }

        if exp.elements.count > 1 {

            if case Exp.Element.op(_) = exp.elements[0] {
                // First element is an operator
            } else {
                XCTFail("In all expressions, the first element MUST be an operator")
            }

            for element in exp.elements[1...] {

                if case let Exp.Element.argument(someArg) = element {
                    if case let Exp.Argument.expression(someNestedExpression) = someArg {
                        expressionValidator(exp: someNestedExpression)
                    }
                } else {
                    XCTFail("In all expressions, every other element after the first is an argument")
                }
            }
        }
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

    internal func testPerformanceOfRoundtripExpressionConversion() throws {
        // This is an example of a performance test case.
        self.measure {
            let expression = Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                0
                UIColor.red
                14
                UIColor.blue
            }

            do {
                let expressionAsJSON = try expression.jsonObject()
                let expressionAgain = Expression(from: expressionAsJSON)
                XCTAssert(expressionAgain != nil)
                XCTAssert(expression == expressionAgain!)
            } catch {
                XCTFail("Failed to convert expression to JSON and back")
            }
        }
    }

}
