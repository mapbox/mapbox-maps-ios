
// This file is generated
import XCTest
@testable import MapboxMaps

final class PolylineAnnotationManagerTests: XCTestCase {
    var manager: PolylineAnnotationManager!
    var style: MockStyle!
    var displayLinkCoordinator: MockDisplayLinkCoordinator!
    var id = UUID().uuidString
    var annotations = [PolylineAnnotation]()
    var expectation: XCTestExpectation?
    var delegateAnnotations: [Annotation]?

    override func setUp() {
      super.setUp()

      style = MockStyle()
      displayLinkCoordinator = MockDisplayLinkCoordinator()
      manager = PolylineAnnotationManager(id: id,
                                        style: style,
                                        layerPosition: nil,
                                        displayLinkCoordinator: displayLinkCoordinator)

      for _ in 0...100 {
          let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
          annotations.append(annotation)
      }
    }

    override func tearDown() {
        style = nil
        displayLinkCoordinator = nil
        manager = nil

        super.tearDown()
    }

    func testInitialLineCap() {
        let defaultValue = manager.lineCap

        XCTAssertNil(defaultValue)
    }

    func testSetLineCap() {
      let value = LineCap.allCases.randomElement()!
      manager.lineCap = value
      XCTAssertEqual(manager.lineCap, value)
    }

    func testSetToNilLineCap() {
      manager.lineCap = nil
      XCTAssertNil(manager.lineCap)
    }

    func testInitialLineMiterLimit() {
        let defaultValue = manager.lineMiterLimit

        XCTAssertNil(defaultValue)
    }

    func testSetLineMiterLimit() {
      let value = Double.random(in: -100000...100000)
      manager.lineMiterLimit = value
      XCTAssertEqual(manager.lineMiterLimit, value)
    }

    func testSetToNilLineMiterLimit() {
      manager.lineMiterLimit = nil
      XCTAssertNil(manager.lineMiterLimit)
    }

    func testInitialLineRoundLimit() {
        let defaultValue = manager.lineRoundLimit

        XCTAssertNil(defaultValue)
    }

    func testSetLineRoundLimit() {
      let value = Double.random(in: -100000...100000)
      manager.lineRoundLimit = value
      XCTAssertEqual(manager.lineRoundLimit, value)
    }

    func testSetToNilLineRoundLimit() {
      manager.lineRoundLimit = nil
      XCTAssertNil(manager.lineRoundLimit)
    }

    func testInitialLineDasharray() {
        let defaultValue = manager.lineDasharray

        XCTAssertNil(defaultValue)
    }

    func testSetLineDasharray() {
      let value = Array.random(withLength: .random(in: 0...10), generator: { Double.random(in: -100000...100000) })
      manager.lineDasharray = value
      XCTAssertEqual(manager.lineDasharray, value)
    }

    func testSetToNilLineDasharray() {
      manager.lineDasharray = nil
      XCTAssertNil(manager.lineDasharray)
    }

    func testInitialLineTranslate() {
        let defaultValue = manager.lineTranslate

        XCTAssertNil(defaultValue)
    }

    func testSetLineTranslate() {
      let value = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
      manager.lineTranslate = value
      XCTAssertEqual(manager.lineTranslate, value)
    }

    func testSetToNilLineTranslate() {
      manager.lineTranslate = nil
      XCTAssertNil(manager.lineTranslate)
    }

    func testInitialLineTranslateAnchor() {
        let defaultValue = manager.lineTranslateAnchor

        XCTAssertNil(defaultValue)
    }

    func testSetLineTranslateAnchor() {
      let value = LineTranslateAnchor.allCases.randomElement()!
      manager.lineTranslateAnchor = value
      XCTAssertEqual(manager.lineTranslateAnchor, value)
    }

    func testSetToNilLineTranslateAnchor() {
      manager.lineTranslateAnchor = nil
      XCTAssertNil(manager.lineTranslateAnchor)
    }

    func testInitialLineTrimOffset() {
        let defaultValue = manager.lineTrimOffset

        XCTAssertNil(defaultValue)
    }

    func testSetLineTrimOffset() {
      let value = [Double.random(in: 0...1), Double.random(in: 0...1)].sorted()
      manager.lineTrimOffset = value
      XCTAssertEqual(manager.lineTrimOffset, value)
    }

    func testSetToNilLineTrimOffset() {
      manager.lineTrimOffset = nil
      XCTAssertNil(manager.lineTrimOffset)
    }

}

// End of generated file
