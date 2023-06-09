import XCTest
@testable import MapboxMaps
import UIKit

class MapboxMapsSnapshotTests: XCTestCase {

    var newAttachment: XCTAttachment!
    var dataPathURL: URL!

    let emptyBlueStyle =
        #"""
        {
            "version": 8,
            "sources": {
                "dummy" : {
                    "type": "vector",
                    "tiles": [],
                    "attribution" : "<a href=\"https://www.mapbox.com/about/maps/\" target=\"_blank\">&copy; Mapbox</a> <a href=\"https://www.mapbox.com/about/maps/\" target=\"_blank\">Mapbox Tests</a> <a class=\"mapbox-improve-map\" href=\"https://apps.mapbox.com/feedback/\" target=\"_blank\">Improve this map</a>"
                }
            },
            "layers": [{
                "id": "background",
                "type": "background",
                "paint": {
                    "background-color": "blue"
                }
            }]
        }
        """#

    override func setUpWithError() throws {
        try super.setUpWithError()
        try guardForMetalDevice()
        dataPathURL = try temporaryCacheDirectory()
    }

    override func tearDownWithError() throws {
        let expectation = self.expectation(description: "Clear map data")
        MapboxMapsOptions.clearData { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        try super.tearDownWithError()
    }

    private static var snapshotSize = CGSize(width: 300, height: 300)
    private static var snapshotScale: CGFloat = 2

    // Create snapshot options
    private func snapshotterOptions(size: CGSize = MapboxMapsSnapshotTests.snapshotSize,
                                    scale: CGFloat = MapboxMapsSnapshotTests.snapshotScale) throws -> MapSnapshotOptions {
        MapboxMapsOptions.dataPath = dataPathURL
        return MapSnapshotOptions(size: size, pixelRatio: scale)
    }

    // Testing creating the snapshot
    func testSnapshotCancellation() throws {
        weak var weakSnapshotter: Snapshotter?
        let options = try snapshotterOptions()
        let expectation = self.expectation(description: "snapshot completion is called")
        autoreleasepool {
            let snapshotter = Snapshotter(options: options)
            weakSnapshotter = snapshotter
            snapshotter.setCamera(to: CameraOptions(center: CLLocationCoordinate2D(latitude: 38.9180379, longitude: -77.0600235), zoom: 5))
            snapshotter.styleJSON = emptyBlueStyle
            snapshotter.start(overlayHandler: nil) { result in
                if case .failure = result {
                    expectation.fulfill()
                } else {
                    XCTFail("Snapshot should be cancelled with a failure result")
                }
            }
        }
        XCTAssertNil(weakSnapshotter)
        wait(for: [expectation], timeout: 10)
    }

    func testCapturingSnapshotterInSnapshotCompletion() throws {
        weak var weakSnapshotter: Snapshotter?
        try autoreleasepool {
            let expectation = self.expectation(description: "snapshot")
            let options = try snapshotterOptions()
            let snapshotter = Snapshotter(options: options)
            weakSnapshotter = snapshotter
            weakSnapshotter?.setCamera(to: CameraOptions(center: CLLocationCoordinate2D(latitude: 38.9180379, longitude: -77.0600235), zoom: 5))
            weakSnapshotter?.styleJSON = emptyBlueStyle
            weakSnapshotter?.start(overlayHandler: nil) { (result) in
                expectation.fulfill()
                XCTAssertNotNil(result)
                print(snapshotter)
            }
            wait(for: [expectation], timeout: 15)
        }
        XCTAssertNil(weakSnapshotter)
    }

    // Testing snapshot overlay
    @available(iOS 13.0, *)
    func testSnapshotOverlay() throws {
        let options = try snapshotterOptions()
        let snapshotter = Snapshotter(options: options)
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 38.9180379, longitude: -77.0600235), zoom: 5)
        snapshotter.setCamera(to: cameraOptions)
        snapshotter.styleJSON = emptyBlueStyle
        let expectation = self.expectation(description: "snapshot")
        expectation.expectedFulfillmentCount = 2
        snapshotter.start { overlayHandler in

            let context = overlayHandler.context

            // Draw a yellow line between Berlin and Kraków.
            context.setStrokeColor(UIColor.yellow.cgColor)
            context.setLineWidth(6.0)
            context.setLineCap(.round)
            context.move(to: CGPoint(x: 20, y: 20))
            context.addLine(to: CGPoint(x: 280, y: 280))
            context.strokePath()

            expectation.fulfill()
        } completion: { (result) in
            switch result {
            case let .success(image):
                self.compare(observedImage: image,
                             expectedImageNamed: "testSnapshotOverlay",
                             expectedImageScale: MapboxMapsSnapshotTests.snapshotScale,
                             attachmentName: "testSnapshotOverlay")

                XCTAssertEqual(image.size, options.size)
                XCTAssertEqual(image.scale, CGFloat(options.pixelRatio))

            case.failure:
                XCTFail("Failed to render snapshot")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

    @available(iOS 13.0, *)
    func testSnapshotLogoVisibility() throws {
        let options = try snapshotterOptions()
        let snapshotterNew = Snapshotter(options: options)
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 38.9180379, longitude: -77.0600235), zoom: 5)
        snapshotterNew.setCamera(to: cameraOptions)
        snapshotterNew.styleJSON = emptyBlueStyle
        let expectation2 = self.expectation(description: "snapshot logo")
        snapshotterNew.start(overlayHandler: nil) { [self] (result) in
            switch result {
            case let .success(image):
                self.compare(observedImage: image,
                             expectedImageNamed: "testSnapshotLogoVisibility",
                             expectedImageScale: MapboxMapsSnapshotTests.snapshotScale,
                             attachmentName: self.name)

            case.failure:
                XCTFail("snapshot asset and snapshot image do not match")
            }
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 10)
    }

    func testDataClearing() throws {
        let options = try snapshotterOptions()
        let snapshotter = Snapshotter(options: options)
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 38.9180379, longitude: -77.0600235), zoom: 5)
        snapshotter.setCamera(to: cameraOptions)
        snapshotter.styleJSON = emptyBlueStyle

        let snapshotExpectation = self.expectation(description: "snapshot")

        snapshotter.start(overlayHandler: nil) { _ in
            snapshotExpectation.fulfill()
        }
        wait(for: [snapshotExpectation], timeout: 10.0)

        let expectation = self.expectation(description: "Clear data using instance function")
        snapshotter.clearData { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    @available(iOS 13.0, *)
    func testSnapshotAttribution() throws {
        // Test range of widths
        for imageWidth in stride(from: 50, through: 300, by: 50) {

            let size = CGSize(width: imageWidth, height: 100)
            let options = try snapshotterOptions(size: size, scale: 2)
            let snapshotter = Snapshotter(options: options)
            let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 38.9180379, longitude: -77.0600235), zoom: 5)

            snapshotter.setCamera(to: cameraOptions)
            snapshotter.styleJSON = emptyBlueStyle
            let expectation = self.expectation(description: "snapshot")

            snapshotter.start(overlayHandler: nil) { result in
                switch result {
                case let .success(image):
                    self.compare(observedImage: image,
                                                  expectedImageNamed: "testSnapshotAttribution-\(imageWidth)",
                                                  expectedImageScale: 2,
                                                  attachmentName: "testSnapshotAttribution-\(imageWidth)")

                case.failure:
                    XCTFail("snapshot asset and snapshot image do not match")
                }
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    @available(iOS 13.0, *)
    func testShowsLogoAndAttribution() throws {
        let options = try snapshotterOptions()
        showLogoAttributionHelper(options: options, fileName: "\(#function)")
    }

    @available(iOS 13.0, *)
    func testDoesNotShowLogo() throws {
        var options = try snapshotterOptions()
        options.showsLogo = false

        showLogoAttributionHelper(options: options, fileName: "\(#function)")
    }

    @available(iOS 13.0, *)
    func testDoesNotShowAttribution() throws {
        var options = try snapshotterOptions()
        options.showsAttribution = false

        showLogoAttributionHelper(options: options, fileName: "\(#function)")
    }

    @available(iOS 13.0, *)
    func testDoesNotShowLogoAndAttribution() throws {
        var options = try snapshotterOptions()
        options.showsLogo = false
        options.showsAttribution = false

        showLogoAttributionHelper(options: options, fileName: "\(#function)")
    }

    @available(iOS 13.0, *)
    private func showLogoAttributionHelper(options: MapSnapshotOptions, fileName: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotter = Snapshotter(options: options)

        // Adding a simple custom style
        snapshotter.styleJSON = emptyBlueStyle

        let expectation = self.expectation(description: "snapshot")
        snapshotter.start(overlayHandler: nil, completion: { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(image):
                self.compare(observedImage: image,
                             expectedImageNamed: fileName,
                             expectedImageScale: MapboxMapsSnapshotTests.snapshotScale,
                             attachmentName: fileName, file: file, line: line)

            case.failure:
                XCTFail("Failure: snapshot asset and snapshot image do not match")
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10)
    }
}
