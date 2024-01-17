@testable import MapboxMaps
import XCTest

final class CollectionDiffTests: XCTestCase {
    struct Element: Equatable {
        var id: Int
        var value: String
    }

    func testDiffFromEmpty() {
        let new = [
            Element(id: 1, value: "1"),
            Element(id: 2, value: "2")
        ]
        let result = new.diff(from: [], id: \.id)
        XCTAssertEqual(
            result,
            CollectionDiff(
                add: [
                    Element(id: 1, value: "1"),
                    Element(id: 2, value: "2")
                ]
            )
        )
        XCTAssertEqual(result.isEmpty, false)
    }

    func testUpdate() {
        let old = [
            Element(id: 1, value: "1"),
        ]
        let new = [
            Element(id: 1, value: "X"),
        ]
        let result = new.diff(from: old, id: \.id)
        XCTAssertEqual(
            result,
            CollectionDiff(
                update: [Element(id: 1, value: "X")]
            )
        )
        XCTAssertEqual(result.isEmpty, false)
    }

    func testRemoveAddUpdate() {
        let old = [
            Element(id: 1, value: "1"),
            Element(id: 2, value: "2")
        ]
        let new = [
            Element(id: 2, value: "Y"),
            Element(id: 3, value: "3")
        ]
        let result = new.diff(from: old, id: \.id)
        XCTAssertEqual(
            result,
            CollectionDiff(
                remove: [1],
                update: [Element(id: 2, value: "Y")],
                add: [Element(id: 3, value: "3")]
            )
        )
        XCTAssertEqual(result.isEmpty, false)
    }

    func testUpdateAndInsert() {
        let old = [
            Element(id: 1, value: "1"),
            Element(id: 3, value: "3")
        ]
        let new = [
            Element(id: 1, value: "X"),
            Element(id: 2, value: "2"),
            Element(id: 3, value: "Y")
        ]
        let result = new.diff(from: old, id: \.id)
        XCTAssertEqual(
            result,
            CollectionDiff(
                remove: [3],
                update: [Element(id: 1, value: "X")],
                add: [
                    Element(id: 2, value: "2"),
                    Element(id: 3, value: "Y")
                ]
            )
        )
        XCTAssertEqual(result.isEmpty, false)
    }

    func testNoDiff() {
        let old = [
            Element(id: 1, value: "1"),
            Element(id: 2, value: "2")
        ]
        let new = [
            Element(id: 1, value: "1"),
            Element(id: 2, value: "2")
        ]
        let result = new.diff(from: old, id: \.id)
        XCTAssertEqual(result, CollectionDiff())
        XCTAssertEqual(result.isEmpty, true)
    }
}
