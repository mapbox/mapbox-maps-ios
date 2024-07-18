import XCTest
@testable import MapboxMaps

internal class ExpressionBuilderTests: XCTestCase {

    func testStopsDictionariesAreSorted() {
        let stopsDictionary: [Double: UIColor] = [
            0.0: .red,
            10.0: .blue,
            7.0: .green]

        let args = stopsDictionary.expressionArguments

        if case Exp.Argument.number(let number1) = args[0],
           case Exp.Argument.number(let number2) = args[2],
           case Exp.Argument.number(let number3) = args[4] {

            if number1 > number2 || number2 > number3 {
                XCTFail("Stops dictionaries should always be sorted in ascending order of keys")
            }
        } else {
            XCTFail("Invalid expression")
        }
    }
}
