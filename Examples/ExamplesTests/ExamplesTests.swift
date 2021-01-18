import XCTest
@testable import Examples

//swiftlint:disable force_cast
class ExamplesTests: XCTestCase {

    func testExampleClassExists() throws {

        for example in Examples.all {
            // Check view controller can be extrapolated from the example file name.
            XCTAssert(example.type is UIViewController.Type)

            // Check if the example file name has the word "Example" appended to the end.
            let string = "\(example.type)"
            let indexEnd = string.index(string.endIndex, offsetBy: -("Example".count))
            XCTAssertTrue(string[indexEnd...] == "Example")

            // Check that examples have descriptions.
            XCTAssertFalse(example.description.isEmpty, "Examples should have a description.")

            // Check punctuation for titles.
            XCTAssertFalse(example.title.last == ".", "Example titles should not end with punctuation.")
        }
    }

}
