@testable import MapboxMaps
import XCTest

final class ArrayExtensionTests: XCTestCase {
    private struct Item: Equatable {
        var id: Int
        var value: String
    }

    func testRemoveDuplicates() {
        var array = [
            Item(id: 1, value: "A"),
            Item(id: 1, value: "B"),
            Item(id: 1, value: "C"),
            Item(id: 2, value: "A"),
            Item(id: 3, value: "C"),
            Item(id: 4, value: "E"),
            Item(id: 4, value: "F")
        ]
        var duplicates = array.removeDuplicates(by: \.id)
        XCTAssertEqual(array, [
            Item(id: 1, value: "A"),
            Item(id: 2, value: "A"),
            Item(id: 3, value: "C"),
            Item(id: 4, value: "E")
        ])
        XCTAssertEqual(duplicates, [
            Item(id: 1, value: "B"),
            Item(id: 1, value: "C"),
            Item(id: 4, value: "F")
        ])

        duplicates = array.removeDuplicates(by: \.value)
        XCTAssertEqual(array, [
            Item(id: 1, value: "A"),
            Item(id: 3, value: "C"),
            Item(id: 4, value: "E")
        ])
        XCTAssertEqual(duplicates, [
            Item(id: 2, value: "A"),
        ])
    }
}
