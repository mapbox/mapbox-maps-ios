
// This file is generated
import XCTest
@testable import MapboxMaps

final class PolygonAnnotationManagerTests: XCTestCase {
    var manager: PolygonAnnotationManager!
    var style: MockStyle!
    var displayLinkCoordinator: MockDisplayLinkCoordinator!
    var id = UUID().uuidString
    var annotations = [PolygonAnnotation]()
    var expectation: XCTestExpectation?
    var delegateAnnotations: [Annotation]?

    override func setUp() {
      super.setUp()

      style = MockStyle()
      displayLinkCoordinator = MockDisplayLinkCoordinator()
      manager = PolygonAnnotationManager(id: id,
                                        style: style,
                                        layerPosition: nil,
                                        displayLinkCoordinator: displayLinkCoordinator)

      for _ in 0...100 {
          let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
          annotations.append(annotation)
      }
    }

    override func tearDown() {
        style = nil
        displayLinkCoordinator = nil
        manager = nil

        super.tearDown()
    }

    func testInitialFillAntialias() {
        let defaultValue = manager.fillAntialias

        XCTAssertNil(defaultValue)
    }

    func testSetFillAntialias() {
      let value = Bool.random()
      manager.fillAntialias = value
      XCTAssertEqual(manager.fillAntialias, value)
    }

    func testSetToNilFillAntialias() {
      manager.fillAntialias = nil
      XCTAssertNil(manager.fillAntialias)
    }

    func testInitialFillTranslate() {
        let defaultValue = manager.fillTranslate

        XCTAssertNil(defaultValue)
    }

    func testSetFillTranslate() {
      let value = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
      manager.fillTranslate = value
      XCTAssertEqual(manager.fillTranslate, value)
    }

    func testSetToNilFillTranslate() {
      manager.fillTranslate = nil
      XCTAssertNil(manager.fillTranslate)
    }

    func testInitialFillTranslateAnchor() {
        let defaultValue = manager.fillTranslateAnchor

        XCTAssertNil(defaultValue)
    }

    func testSetFillTranslateAnchor() {
      let value = FillTranslateAnchor.allCases.randomElement()!
      manager.fillTranslateAnchor = value
      XCTAssertEqual(manager.fillTranslateAnchor, value)
    }

    func testSetToNilFillTranslateAnchor() {
      manager.fillTranslateAnchor = nil
      XCTAssertNil(manager.fillTranslateAnchor)
    }

}

// End of generated file
