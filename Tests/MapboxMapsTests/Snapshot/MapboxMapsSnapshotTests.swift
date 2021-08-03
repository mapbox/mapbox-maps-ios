import XCTest
import MapboxMaps
import Turf
import Foundation
import UIKit

//swiftlint:disable explicit_top_level_acl explicit_acl

class MapboxMapsSnapshotTests: XCTestCase {

    var newAttachment: XCTAttachment!
    var resourceOptions: ResourceOptions!
    var dataPathURL: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        try guardForMetalDevice()
        dataPathURL = try temporaryCacheDirectory()
    }

    override func tearDownWithError() throws {
        if let resourceOptions = resourceOptions {
            let expectation = self.expectation(description: "Clear map data")
            MapboxMap.clearData(for: resourceOptions) { _ in
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10.0)
        }
        try super.tearDownWithError()
    }

    private static var snapshotSize = CGSize(width: 300, height: 300)
    private static var snapshotScale: CGFloat = 4

    // Create snapshot options
    private func snapshotterOptions(size: CGSize = MapboxMapsSnapshotTests.snapshotSize,
                                    scale: CGFloat = MapboxMapsSnapshotTests.snapshotScale) throws -> MapSnapshotOptions {
        let accessToken = try mapboxAccessToken()
        resourceOptions = ResourceOptions(accessToken: accessToken,
                                          dataPathURL: dataPathURL)
        return MapSnapshotOptions(size: size, pixelRatio: scale, resourceOptions: resourceOptions)
    }

    // Testing creating the snapshot
    func testSnapshotCancellation() throws {
        weak var weakSnapshotter: Snapshotter?
        let options = try snapshotterOptions()
        let expectation = self.expectation(description: "snapshot")
         autoreleasepool {
            let snapshotter = Snapshotter(options: options)
            weakSnapshotter = snapshotter
            weakSnapshotter?.setCamera(to: CameraOptions(center: CLLocationCoordinate2D(latitude: 38.9180379, longitude: -77.0600235), zoom: 5))
            weakSnapshotter?.style.uri = .light
            weakSnapshotter?.start(overlayHandler: nil) { (result) in
                expectation.fulfill()
                XCTAssertNotNil(result)
                XCTAssertNil(weakSnapshotter)
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
            weakSnapshotter?.style.uri = .light
            weakSnapshotter?.start(overlayHandler: nil) { (result) in
                expectation.fulfill()
                XCTAssertNotNil(result)
                print(snapshotter)
            }
            wait(for: [expectation], timeout: 10)
        }
        XCTAssertNil(weakSnapshotter)
    }

    // Testing snapshot overlay
    func testSnapshotOverlay() throws {
        let options = try snapshotterOptions()
        let snapshotter = Snapshotter(options: options)
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 38.9180379, longitude: -77.0600235), zoom: 5)
        snapshotter.setCamera(to: cameraOptions)
        snapshotter.style.uri = .light
        let expectation = self.expectation(description: "snapshot")
        expectation.expectedFulfillmentCount = 2
        snapshotter.start { (overlay) in
            guard overlay.context.makeImage() != nil else {
                XCTFail("failed to create snapshot overlay")
                return
            }
            expectation.fulfill()
        } completion: { (result) in
            if case let .success(image) = result {
                let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Snapshot Asset.png")
                do {
                    try image.pngData()?.write(to: url)
                } catch {
                    print(error)
                }
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

    func testSnapshotSizeAndScaleAccuracy() {
        let imageRect = CGRect(x: 0, y: 0, width: 300, height: 300)
        let options = try! snapshotterOptions()
        let snapshotter = Snapshotter(options: options) //should have protocol for GLnative (may have been ticketed)
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 38.9180379, longitude: -77.0600235), zoom: 5)
        snapshotter.setCamera(to: cameraOptions)
        snapshotter.style.uri = .light
        let expectation = self.expectation(description: "snapshot accuracy")
        expectation.expectedFulfillmentCount = 2
        snapshotter.start { (_) in
            expectation.fulfill()
        } completion: { (result) in
            // size comparison for snapshotter
            XCTAssertEqual(snapshotter.snapshotSize, imageRect.size)

            //scale and size comparison for image
            switch result {
            case let .success(image) :
                XCTAssertEqual(image.scale, CGFloat(options.pixelRatio))
                XCTAssertEqual(image.size, imageRect.size)
            case.failure :
                XCTFail("image scale and/or size does not match snapshotter")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

    func testSnapshotLogoVisibility() throws {
        let options = try snapshotterOptions()
        let snapshotterNew = Snapshotter(options: options)
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 38.9180379, longitude: -77.0600235), zoom: 5)
        snapshotterNew.setCamera(to: cameraOptions)
        snapshotterNew.style.uri = .light
        let expectation2 = self.expectation(description: "snapshot logo")
        snapshotterNew.start(overlayHandler: nil) { [self] (result) in
            switch result {
            case let .success(image) :
                let imageEqual = self.compare(observedImage: image,
                                              expectedImageNamed: "testSnapshotLogoVisibility",
                                              expectedImageScale: MapboxMapsSnapshotTests.snapshotScale,
                                              attachmentName: self.name)
                XCTAssert(imageEqual, "Snapshot does not match expected image")

            case.failure :
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
        snapshotter.style.uri = .light

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


    func testSnapshotAttribution() throws {

        // Test range of widths
        for imageWidth in stride(from: 50, through: 300, by: 50) {

            let size = CGSize(width: imageWidth, height: 100)
            let options = try snapshotterOptions(size: size, scale: 2)
            let snapshotter = Snapshotter(options: options)
            let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 38.9180379, longitude: -77.0600235), zoom: 5)

            snapshotter.setCamera(to: cameraOptions)
            snapshotter.style.uri = .streets
            let expectation = self.expectation(description: "snapshot")

            snapshotter.start(overlayHandler: nil) { result in
                switch result {
                case let .success(image) :
                    let imageEqual = self.compare(observedImage: image,
                                                  expectedImageNamed: "testSnapshotAttribution-\(imageWidth)",
                                                  expectedImageScale: 2,
                                                  attachmentName: "testSnapshotAttribution-\(imageWidth)")
                    XCTAssert(imageEqual, "Snapshot does not match expected image")

                case.failure :
                    XCTFail("snapshot asset and snapshot image do not match")
                }
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

}
