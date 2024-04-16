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

        let resultNoTrackingMoves = new.diff(from: [], id: \.id)
        let resultWithTrackingMoves = new.diff(from: [], id: \.id, trackMoves: true)

        XCTAssertEqual(resultNoTrackingMoves, CollectionDiff(
            add: [
                Element(id: 1, value: "1"),
                Element(id: 2, value: "2")]
            )
        )
        XCTAssertEqual(resultNoTrackingMoves.isEmpty, false)

        XCTAssertEqual(resultWithTrackingMoves, CollectionDiff(
            add: [
                Element(id: 1, value: "1"),
                Element(id: 2, value: "2")]
            )
        )
        XCTAssertEqual(resultWithTrackingMoves.isEmpty, false)
    }

    func testUpdate() {
        let old = [Element(id: 1, value: "1")]
        let new = [Element(id: 1, value: "X")]

        let resultNoTrackingMoves = new.diff(from: old, id: \.id)
        let resultWithTrackingMoves = new.diff(from: old, id: \.id, trackMoves: true)

        XCTAssertEqual(resultNoTrackingMoves, CollectionDiff(
            update: [Element(id: 1, value: "X")]
        ))

        XCTAssertEqual(resultWithTrackingMoves, CollectionDiff(
            update: [Element(id: 1, value: "X")]
        ))

        XCTAssertEqual(resultWithTrackingMoves.isEmpty, false)
        XCTAssertEqual(resultNoTrackingMoves.isEmpty, false)
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

        let resultNoTrackingMoves = new.diff(from: old, id: \.id)
        let resultWithTrackingMoves = new.diff(from: old, id: \.id, trackMoves: true)

        XCTAssertEqual(resultNoTrackingMoves, CollectionDiff(
            remove: [Element(id: 1, value: "1")],
            add: [Element(id: 3, value: "3")],
            update: [Element(id: 2, value: "Y")]
        ))

        XCTAssertEqual(resultWithTrackingMoves, CollectionDiff(
            remove: [Element(id: 1, value: "1")],
            add: [Element(id: 3, value: "3")],
            update: [Element(id: 2, value: "Y")]
        ))

        XCTAssertEqual(resultWithTrackingMoves.isEmpty, false)
        XCTAssertEqual(resultNoTrackingMoves.isEmpty, false)
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

        let resultNoTrackingMoves = new.diff(from: old, id: \.id)
        let resultWithTrackingMoves = new.diff(from: old, id: \.id, trackMoves: true)

        XCTAssertEqual(resultNoTrackingMoves, CollectionDiff(
            remove: [Element(id: 3, value: "3")],
            add: [
                Element(id: 2, value: "2"),
                Element(id: 3, value: "Y")
            ],
            update: [Element(id: 1, value: "X")]
        ))

        XCTAssertEqual(resultWithTrackingMoves, CollectionDiff(
            remove: [],
            add: [Element(id: 2, value: "2")],
            update: [
                Element(id: 1, value: "X"),
                Element(id: 3, value: "Y")
            ]
        ))

        XCTAssertEqual(resultWithTrackingMoves.isEmpty, false)
        XCTAssertEqual(resultNoTrackingMoves.isEmpty, false)
    }

    func testInsertInTheMiddle() {
        let old = [
            Element(id: 1, value: "1"),
            Element(id: 3, value: "3"),
            Element(id: 5, value: "5")
        ]
        let new = [
            Element(id: 1, value: "1"),
            Element(id: 2, value: "2"),
            Element(id: 3, value: "3"),
            Element(id: 4, value: "4"),
            Element(id: 5, value: "5")
        ]

        let resultNoTrackingMoves = new.diff(from: old, id: \.id)
        let resultWithTrackingMoves = new.diff(from: old, id: \.id, trackMoves: true)

        XCTAssertEqual(resultNoTrackingMoves, CollectionDiff(
            remove: [
                Element(id: 3, value: "3"),
                Element(id: 5, value: "5")
            ],
            add: [
                Element(id: 2, value: "2"),
                Element(id: 3, value: "3"),
                Element(id: 4, value: "4"),
                Element(id: 5, value: "5")
            ]
        ))

        XCTAssertEqual(resultWithTrackingMoves, CollectionDiff(
            add: [
                Element(id: 2, value: "2"),
                Element(id: 4, value: "4")
            ]
        ))

        XCTAssertEqual(resultWithTrackingMoves.isEmpty, false)
        XCTAssertEqual(resultNoTrackingMoves.isEmpty, false)
    }

    func testMoves() {
        let old = [
            Element(id: 1, value: "1"),
            Element(id: 2, value: "2"),
            Element(id: 3, value: "3"),
            Element(id: 4, value: "4"),
            Element(id: 5, value: "5")
        ]
        let new = [
            Element(id: 2, value: "2"),
            Element(id: 3, value: "3"),
            Element(id: 1, value: "1"),
            Element(id: 5, value: "5"),
            Element(id: 4, value: "4")
        ]

        let resultNoTrackingMoves = new.diff(from: old, id: \.id)
        let resultWithTrackingMoves = new.diff(from: old, id: \.id, trackMoves: true)

        XCTAssertEqual(resultNoTrackingMoves, CollectionDiff(
            remove: [
                Element(id: 2, value: "2"),
                Element(id: 3, value: "3"),
                Element(id: 1, value: "1"),
                Element(id: 5, value: "5"),
                Element(id: 4, value: "4")
            ],
            add: [
                Element(id: 2, value: "2"),
                Element(id: 3, value: "3"),
                Element(id: 1, value: "1"),
                Element(id: 5, value: "5"),
                Element(id: 4, value: "4")
            ]
        ))

        XCTAssertEqual(resultWithTrackingMoves, CollectionDiff(
            move: [
                CollectionDiff<[Element]>.Move(value: Element(id: 2, value: "2"), from: 1, to: 0),
                CollectionDiff<[Element]>.Move(value: Element(id: 3, value: "3"), from: 2, to: 1),
                CollectionDiff<[Element]>.Move(value: Element(id: 5, value: "5"), from: 4, to: 3),
            ]
        ))

        XCTAssertEqual(resultWithTrackingMoves.isEmpty, false)
        XCTAssertEqual(resultNoTrackingMoves.isEmpty, false)
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

        let resultNoTrackingMoves = new.diff(from: old, id: \.id)
        let resultWithTrackingMoves = new.diff(from: old, id: \.id, trackMoves: true)

        XCTAssertEqual(resultWithTrackingMoves, CollectionDiff())
        XCTAssertEqual(resultNoTrackingMoves, CollectionDiff())
        XCTAssertEqual(resultWithTrackingMoves.isEmpty, true)
        XCTAssertEqual(resultNoTrackingMoves.isEmpty, true)
    }
}
