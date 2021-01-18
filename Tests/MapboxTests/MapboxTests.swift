import XCTest
 @testable import MapboxMaps

 final class MapboxTests: XCTestCase {
    var mapView: MapView!

    override func setUp() {
        mapView = MapView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    }
    func testFrame() {
         // This is an example of a functional test case.
         // Use XCTAssert and related functions to verify your tests produce the correct
         // results.
        let rect = CGRect(x: 0, y: 0, width: 40, height: 40)
        XCTAssertEqual(mapView.frame, rect)

        print("Hello test")
     }

     static var allTests = [
         ("testFrame", testFrame)
     ]
 }
