import XCTest
@testable import MapboxMaps
import Foundation
import UIKit

class AttributionTests: XCTestCase {

    func testAttribution() {

        let a1 = Attribution(title: "Hello World", url: URL(string: "https://example.com")!)
        XCTAssertEqual(a1.title, "Hello World")
        XCTAssertEqual(a1.titleAbbreviation, "Hello World")
        XCTAssertFalse(a1.isFeedbackURL)

        let a2 = Attribution(title: Attribution.OSM, url: URL(string: "https://example.com")!)
        XCTAssertEqual(a2.title, Attribution.OSM)
        XCTAssertEqual(a2.titleAbbreviation, Attribution.OSMAbbr)

        for urlString in Attribution.improveMapURLs {
            let a3 = Attribution(title: "Don't Improve this map", url: URL(string: urlString)!)
            XCTAssert(a3.isFeedbackURL)
        }

        let a4 = Attribution(title: "Improve this map", url: URL(string: "https://example.com")!)
        XCTAssert(a4.isFeedbackURL)
    }
}
