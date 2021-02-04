import XCTest
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

internal class ExpressionBuilderTests: XCTestCase {

    func testStopsDictionariesAreSorted() {
        let stopsDictionary = [
            0.0: UIColor.red,
            10.0: UIColor.blue,
            7.0: UIColor.green
        ]

        let expressionElements = stopsDictionary.expressionElements

        if case Expression.Element.argument(let arg1) = expressionElements[0],
           case Expression.Element.argument(let arg2) = expressionElements[2],
           case Expression.Element.argument(let arg3) = expressionElements[4] {

            if case Expression.Argument.number(let number1) = arg1,
               case Expression.Argument.number(let number2) = arg2,
               case Expression.Argument.number(let number3) = arg3 {

                if number1 > number2 || number2 > number3 {
                    XCTFail("Stops dictionaries should always be sorted in ascending order of keys")
                }
            } else {
                XCTFail("Invalid expression")
            }
        } else {
            XCTFail("Invalid expression")
        }
    }
}
