import UIKit
import XCTest

extension UIGestureRecognizerDelegate {
    func assertRecognizedSimultaneously(_ recognizer: UIGestureRecognizer, with others: Set<UIGestureRecognizer>, file: StaticString = #filePath, line: UInt = #line) {
        assert(recognizer, simultaneouslyWith: others, expectation: { result, message in XCTAssertTrue(result, message, file: file, line: line) })
    }

    func assertNotRecognizedSimultaneously(_ recognizer: UIGestureRecognizer, with others: Set<UIGestureRecognizer>, file: StaticString = #filePath, line: UInt = #line) {
        assert(recognizer, simultaneouslyWith: others, expectation: { result, message in XCTAssertFalse(result, message, file: file, line: line) })
    }

    private func assert(_ recognizer: UIGestureRecognizer, simultaneouslyWith others: Set<UIGestureRecognizer>, expectation: (Bool, String) -> Void) {
        others.forEach { other in
            guard let shouldRecognizeSimultaneously = gestureRecognizer?(recognizer, shouldRecognizeSimultaneouslyWith: other) else {
                return XCTFail("shouldRecognizeSimultaneouslyWith not implemented")
            }
            expectation(shouldRecognizeSimultaneously, "Expectation failed on \(other)")
        }
    }
}
