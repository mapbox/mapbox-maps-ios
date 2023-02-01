@testable import MapboxMapsSwiftUI
import XCTest

struct MyStyle: StyleComponentProtocol {
    var showGeoJson: Bool
    var body: StyleContent {
        CircleLayer(id: "123")
        CircleLayer(id: "123")
        GeoJSONSource()
        if showGeoJson {
            GeoJSONSource()
        }
        InternalStyle()
    }
}

struct InternalStyle: StyleComponentProtocol {
    var body: StyleContent {
        SymbolLayer(id: "my-symbol-internal-layer")
    }
}

final class StyleComponensTests: XCTestCase {
    func testStyleBuild() {
        var style = MyStyle(showGeoJson: false)
        var components = style.body.components
        XCTAssertEqual(components.count, 4)

        style.showGeoJson = true
        components = style.body.components
        XCTAssertEqual(components.count, 5)
    }
}
