
// This file is generated
import XCTest
@testable import MapboxMaps

final class CircleAnnotationManagerTests: XCTestCase {
    var manager: CircleAnnotationManager!
    var style: MockStyle!
    var displayLinkCoordinator: MockDisplayLinkCoordinator!
    var id = UUID().uuidString
    var annotations = [CircleAnnotation]()
    var expectation: XCTestExpectation?
    var delegateAnnotations: [Annotation]?

    override func setUp() {
      super.setUp()

      style = MockStyle()
      displayLinkCoordinator = MockDisplayLinkCoordinator()
      manager = CircleAnnotationManager(id: id,
                                        style: style,
                                        layerPosition: nil,
                                        displayLinkCoordinator: displayLinkCoordinator)

      for _ in 0...100 {
          var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
          annotations.append(annotation)
      }
    }

    override func tearDown() {
        style = nil
        displayLinkCoordinator = nil
        manager = nil

        super.tearDown()
    }

    func testInitialCirclePitchAlignment() {
        let defaultValue = manager.circlePitchAlignment

        XCTAssertNil(defaultValue)
    }

    func testSetCirclePitchAlignment() {
      let value = CirclePitchAlignment.allCases.randomElement()!
      manager.circlePitchAlignment = value
      XCTAssertEqual(manager.circlePitchAlignment, value)
    }

    func testSetToNilCirclePitchAlignment() {
      manager.circlePitchAlignment = nil
      XCTAssertNil(manager.circlePitchAlignment)
    }

    func testInitialCirclePitchScale() {
        let defaultValue = manager.circlePitchScale

        XCTAssertNil(defaultValue)
    }

    func testSetCirclePitchScale() {
      let value = CirclePitchScale.allCases.randomElement()!
      manager.circlePitchScale = value
      XCTAssertEqual(manager.circlePitchScale, value)
    }

    func testSetToNilCirclePitchScale() {
      manager.circlePitchScale = nil
      XCTAssertNil(manager.circlePitchScale)
    }

    func testInitialCircleTranslate() {
        let defaultValue = manager.circleTranslate

        XCTAssertNil(defaultValue)
    }

    func testSetCircleTranslate() {
      let value = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
      manager.circleTranslate = value
      XCTAssertEqual(manager.circleTranslate, value)
    }

    func testSetToNilCircleTranslate() {
      manager.circleTranslate = nil
      XCTAssertNil(manager.circleTranslate)
    }

    func testInitialCircleTranslateAnchor() {
        let defaultValue = manager.circleTranslateAnchor

        XCTAssertNil(defaultValue)
    }

    func testSetCircleTranslateAnchor() {
      let value = CircleTranslateAnchor.allCases.randomElement()!
      manager.circleTranslateAnchor = value
      XCTAssertEqual(manager.circleTranslateAnchor, value)
    }

    func testSetToNilCircleTranslateAnchor() {
      manager.circleTranslateAnchor = nil
      XCTAssertNil(manager.circleTranslateAnchor)
    }

}

// End of generated file
