import CoreLocation
import XCTest
@testable import MapboxMaps

class MapboxCompassOrnamentViewTests: XCTestCase {

    func testCompassVisibilityVisible() {
        // Given
        let compass = MapboxCompassOrnamentView()
        compass.visibility = .visible
        // When
        compass.currentBearing = 0
        // Then
        XCTAssert(compass.alpha == 1)

        for _ in 0...100 {
            //When bearing is not zero
            compass.currentBearing = Double.random(in: 1...180) * [-1, 1][Int.random(in: 0...1)]
            // Then
            XCTAssertFalse(compass.containerView.isHidden)
        }
    }

    func testCompassVisibilityHidden() {
        // Given
        let compass = MapboxCompassOrnamentView()
        compass.visibility = .hidden
        // When
        compass.currentBearing = 0
        // Then
        XCTAssertTrue(compass.containerView.isHidden)

        for _ in 0...100 {
            //When bearing is not zero
            compass.currentBearing = Double.random(in: 1...180) * [-1, 1][Int.random(in: 0...1)]
            // Then
            XCTAssertTrue(compass.containerView.isHidden)
        }
    }

    func testCompassVisibilityAdaptive() {
        // Given
        let compass = MapboxCompassOrnamentView()
        compass.visibility = .adaptive
        // When
        compass.currentBearing = 0
        // Then
        XCTAssertTrue(compass.containerView.isHidden)

        for _ in 0...100 {
            //When bearing is not zero
            compass.currentBearing = Double.random(in: 1...180) * [-1, 1][Int.random(in: 0...1)]
            // Then
            XCTAssertFalse(compass.containerView.isHidden)
        }
    }

    func testCompassVisibilityStyleChanging() {
        // Given
        let compass = MapboxCompassOrnamentView()
        compass.currentBearing = 0
        // When
        compass.visibility = .visible
        // Then
        XCTAssertFalse(compass.containerView.isHidden)

        // When
        compass.visibility = .hidden
        // Then
        XCTAssertTrue(compass.containerView.isHidden)

        // When
        compass.visibility = .adaptive
        // Then
        XCTAssertTrue(compass.containerView.isHidden)
    }

    func testCompassVisibilityStyleChangingWithBearing() {
        // Given
        let compass = MapboxCompassOrnamentView()
        compass.currentBearing = 30
        // When
        compass.visibility = .visible
        // Then
        XCTAssertFalse(compass.containerView.isHidden)

        // When
        compass.visibility = .hidden
        // Then
        XCTAssertTrue(compass.containerView.isHidden)

        // When
        compass.visibility = .adaptive
        // Then
        XCTAssertFalse(compass.containerView.isHidden)
    }

    func testCustomCompassImage() {
        // Given
        let compass = MapboxCompassOrnamentView()
        // When
        let originalImage = compass.containerView.image
        // Then
        XCTAssertNotNil(originalImage)

        // Given
        let expectedImage = UIImage.emptyImage(with: CGSize(width: 25, height: 25))
        // When
        compass.updateImage(image: expectedImage)
        // Then
        XCTAssertTrue(compass.containerView.image!.isEqual(expectedImage))
        // And
        XCTAssertFalse(compass.containerView.image!.isEqual(originalImage))
    }

    func testReturningDefaultCompassImage() {
        // Given
        let compass = MapboxCompassOrnamentView()
        let originalImageData = compass.containerView.image?.pngData()
        let customImage = UIImage.emptyImage(with: CGSize(width: 25, height: 25))

        // When
        compass.updateImage(image: customImage)

        // Then
        XCTAssertEqual(compass.containerView.image, customImage)

        // When
        compass.updateImage(image: nil)

        // Then
        XCTAssertNotEqual(compass.containerView.image, customImage)
        // And
        XCTAssertNotNil(compass.containerView.image)
        // And
        XCTAssertEqual(compass.containerView.image?.pngData(), originalImageData)
    }
}
