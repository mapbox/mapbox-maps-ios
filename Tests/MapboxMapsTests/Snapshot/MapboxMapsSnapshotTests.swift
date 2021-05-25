import XCTest
import MapboxMaps
import MapboxCoreMaps
import Turf
import Foundation
import UIKit
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsSnapshot
#endif
//swiftlint:disable explicit_top_level_acl explicit_acl

class MapboxMapsSnapshotTests: XCTestCase {
    
    var newAttachment: XCTAttachment!
    var resourceOptions: ResourceOptions!
    
    // Create snapshot options
    private func snapshotterOptions() throws -> MapSnapshotOptions {
        resourceOptions = try! ResourceOptions(accessToken: mapboxAccessToken())
        return MapSnapshotOptions(size: CGSize(width: 300, height: 300), pixelRatio: 4, resourceOptions: resourceOptions)
    }
    
    // Testing creating the snapshot
    func testSnapshotCancellation() throws {
        weak var weakSnapshotter: Snapshotter?
        let expectation = self.expectation(description: "snapshot")
        try autoreleasepool {
            let options = try snapshotterOptions()
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
//            let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//            let mapView = MapView(frame: frame)
            weakSnapshotter?.setCamera(to: CameraOptions(center: CLLocationCoordinate2D(latitude: 38.9180379, longitude: -77.0600235), zoom: 5))
            weakSnapshotter?.style.uri = .light
            weakSnapshotter?.start(overlayHandler: nil) { (result) in
                expectation.fulfill()
                XCTAssertNotNil(result)
                print(snapshotter)
//                print(mapView)
            }
            wait(for: [expectation], timeout: 60)
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
            guard let _ = overlay.context.makeImage() else {
                XCTFail()
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
        snapshotter.start { (overlay) in
            expectation.fulfill()
        } completion: { (result) in
            // size comparison for snapshotter
            XCTAssertEqual(snapshotter.snapshotSize, imageRect.size)
            
            //scale and size comparison for image
            switch result {
            case let .success(image) :
                XCTAssertEqual(image.scale, CGFloat(options.pixelRatio))
                XCTAssertEqual(image.size, imageRect.size)
            case.failure(_) :
                XCTFail()
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
        snapshotterNew.start(overlayHandler: nil) { (result) in
            switch result {
            case let .success(image) :
                let newAttachment = XCTAttachment(image: image)
                newAttachment.lifetime = .keepAlways
                self.add(newAttachment)
                
                // Compare snapshot asset data vs snapshot image data
                let path = Bundle.mapboxMapsTests.path(forResource: "Snapshot-Asset", ofType: "png")!
                let url = URL(fileURLWithPath: path)
                let expectedImageData = try? Data(contentsOf: url)
                
                XCTAssertEqual(expectedImageData, image.pngData(), "has the camera changed?")
                
            case.failure(_) :
                XCTFail()
            }
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 10)
    }
}
