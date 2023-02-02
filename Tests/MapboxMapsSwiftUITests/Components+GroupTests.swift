@testable import MapboxMapsSwiftUI
import XCTest

struct MyStyle0: StyleComponent {
    var body: some StyleComponent {
        SymbolLayer(id: "s")
        CircleLayer(id: "c")
    }
}


struct MyStyle1: StyleComponent {
    var body: some StyleComponent {
        SymbolLayer(id: "s")
        CircleLayer(id: "c")
    }
}

struct MyStyle2: StyleComponent {
    var body: some StyleComponent {
        SymbolLayer(id: "s")
        CircleLayer(id: "c")
        CircleLayer(id: "c1")
    }
}

struct MyStyle3: StyleComponent {
    var arg1: Bool
    var body: some StyleComponent {
        InternalStyle(arg1: arg1)
        CircleLayer(id: "c")
        CircleLayer(id: "c1").debug {
            print("== Run MyStyle3Body")
        }
    }
}

struct InternalStyle: StyleComponent {
    var arg1: Bool
    var body: some StyleComponent {
        SymbolLayer(id: "internal-1")
            .debug {
                print("== Run InternalStyleBody")
            }
        if arg1 {
            SymbolLayer(id: "internal-2")
                .debug {
                    print("== Run InternalStyleBodyIf")
                }
        }
    }
}

struct MyStyle4: StyleComponent {
    var body: some StyleComponent {
        SymbolLayer(id: "123")
    }
}

struct MyStyle5: StyleComponent {
    var body: some StyleComponent {
        StyleProjection(name: .mercator)
    }
}

final class StyleComponensTests: XCTestCase {
    func testChange() {
        let applier = MockStyleApplier()
        let styleState = StyleState()

        var component = MyStyle3(arg1: true)

        let node = Node(style: styleState)
        component.visit(node)
        let s1 = styleState.take()
        XCTAssertEqual(Set(s1.layers.keys), ["c", "c1", "internal-1", "internal-2"])

        component.arg1 = false
        component.visit(node)
        let s2 = styleState.take()
        XCTAssertEqual(Set(s2.layers.keys), ["c", "c1", "internal-1"])

        applyDiff(from: s1.layers, to: s2.layers, insert: {
            try! applier.addLayer($1)
        }, remove: {
            try! applier.removeLayer(withId: $0)
        })

        XCTAssertEqual(applier.layerAdditions, [])
        XCTAssertEqual(applier.layerRemovals, ["internal-2"])
    }

    func testNoChange() {
        let applier = MockStyleApplier()
        let styleState = StyleState()

        var component = MyStyle3(arg1: true)

        var node = Node(style: styleState)
        component.visit(node)
        var s1 = styleState.take()
        XCTAssertEqual(Set(s1.layers.keys), ["c", "c1", "internal-1", "internal-2"])

        component.arg1 = true
        component.visit(node)
        var s2 = styleState.take()
        XCTAssertEqual(Set(s2.layers.keys), ["c", "c1", "internal-1", "internal-2"])

        applyDiff(from: s1.layers, to: s2.layers, insert: {
            try! applier.addLayer($1)
        }, remove: {
            try! applier.removeLayer(withId: $0)
        })

        XCTAssert(applier.layerAdditions.isEmpty)
        XCTAssert(applier.layerRemovals.isEmpty)
    }
}
