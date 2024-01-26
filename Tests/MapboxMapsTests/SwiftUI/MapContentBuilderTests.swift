import XCTest
@_spi(Experimental) @testable import MapboxMaps

@available(iOS 13.0, *)
final class MapContentBuilderTests: XCTestCase {

    func testCompositeMapContent() throws {
        var visitorIds: [AnyHashable] = []

        @MapContentBuilder func content() -> MapContent {
            DummyMapContent {
                XCTAssertEqual($0.positionalId.last, 0)
                visitorIds += $0.positionalId
            }
            DummyMapContent {
                XCTAssertEqual($0.positionalId.last, 1)
                visitorIds += $0.positionalId
            }
        }

        let composite = try XCTUnwrap(content() as? CompositeMapContent)
        let visitor = DefaultMapContentVisitor()
        composite.visit(visitor)

        XCTAssertEqual(composite.children.count, 2)
        XCTAssertEqual(visitorIds, [0, 1])
        XCTAssertTrue(visitor.positionalId.isEmpty)
    }

    func testOptionalMapContent() throws {
        var visitorIds: [AnyHashable] = []
        var condition = false

        @MapContentBuilder func content() -> MapContent {
            // This will form a nested CompositeMapContent, with one child if condition is true, empty otherwise.
            if condition {
                DummyMapContent {
                    XCTAssertEqual($0.positionalId.last, 0)
                    visitorIds += $0.positionalId
                }
            }
        }

        let visitor = DefaultMapContentVisitor()

        var composite = try XCTUnwrap(content() as? CompositeMapContent)
        XCTAssertEqual(composite.children.count, 1)
        XCTAssertTrue(composite.children.first is CompositeMapContent)

        composite.visit(visitor)
        XCTAssertTrue(visitorIds.isEmpty)
        XCTAssertTrue(visitor.positionalId.isEmpty)

        condition = true
        composite = try XCTUnwrap(content() as? CompositeMapContent)

        XCTAssertEqual(composite.children.count, 1)
        XCTAssertTrue(composite.children.first is CompositeMapContent)

        composite.visit(visitor)
        XCTAssertEqual(visitorIds, [0, 0])
        XCTAssertTrue(visitor.positionalId.isEmpty)
    }

    func testConditionalMapContent() throws {
        var visitorIds: [AnyHashable] = []
        var condition = true

        @MapContentBuilder func content() -> MapContent {
            if condition {
                DummyMapContent {
                    visitorIds += $0.positionalId
                }
            } else {
                DummyMapContent {
                    visitorIds += $0.positionalId
                }
            }
        }

        var composite = try XCTUnwrap(content() as? CompositeMapContent)
        XCTAssertEqual(composite.children.count, 1)
        XCTAssertTrue(composite.children.first is ConditionalMapContent)

        composite.visit(DefaultMapContentVisitor())
        XCTAssertEqual(visitorIds, [0, 1, 0])

        visitorIds = []
        condition = false
        composite = try XCTUnwrap(content() as? CompositeMapContent)
        XCTAssertEqual(composite.children.count, 1)
        XCTAssertTrue(composite.children.first is ConditionalMapContent)

        composite.visit(DefaultMapContentVisitor())
        XCTAssertEqual(visitorIds, [0, 2, 0])
    }

    func testForEvery() throws {
        var visitorIds: [AnyHashable] = []
        let data = Array.random(withLength: 5, generator: { UUID().uuidString })

        @MapContentBuilder func content() -> MapContent {
            ForEvery(data, id: \.self) { _ in
                DummyMapContent {
                    visitorIds += $0.positionalId
                }
            }
        }

        let visitor = DefaultMapContentVisitor()
        let composite = try XCTUnwrap(content() as? CompositeMapContent)
        XCTAssertEqual(composite.children.count, 1)
        XCTAssertTrue(composite.children.first is ForEvery<MapContent, [String], String>)

        composite.visit(visitor)
        XCTAssertEqual(visitorIds, data.flatMap { id -> [AnyHashable] in return [0, id, 0] })
    }
}

private struct DummyMapContent: PrimitiveMapContent {
    var onVisited: (MapContentVisitor) -> Void

    func _visit(_ visitor: MapContentVisitor) {
        onVisited(visitor)
    }
}
