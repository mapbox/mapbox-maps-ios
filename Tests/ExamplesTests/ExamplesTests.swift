import XCTest
@testable import Examples

class ExamplesTests: XCTestCase {

    func testExampleClassExists() throws {

        for example in Examples.all.flatMap(\.examples) {
            print("Validating \(example)")
            // Check view controller can be extrapolated from the example file name.
            XCTAssert(example.type is UIViewController.Type)

            // Check if the example file name has the word "Example" appended to the end.
            let string = "\(example.type)"
            let indexEnd = string.index(string.endIndex, offsetBy: -("Example".count))
            XCTAssertTrue(string[indexEnd...] == "Example")

            // Check that examples have descriptions.
            XCTAssertFalse(example.description.isEmpty, "Example '\(example.type)' should have a description.")

            // Check that examples have titles.
            XCTAssertFalse(example.title.isEmpty, "Example '\(example.type)' should have a title.")

            // Check that example titles do not end in punctuation
            if let last = example.title.last {
                XCTAssertTrue(CharacterSet(charactersIn: String(last)).isDisjoint(with: .punctuationCharacters),
                              "Title for example '\(example.type)' should not end with punctuation.")
            }
        }
    }

}
