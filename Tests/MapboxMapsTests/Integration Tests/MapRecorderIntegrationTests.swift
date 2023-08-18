import XCTest
@testable @_spi(Experimental) import MapboxMaps

internal class MapRecorderIntegrationTests: MapViewIntegrationTestCase {

    func testReplayMapRecording() {
        mapView.mapboxMap.styleURI = .standard
        let mapRecordingExpectation = XCTestExpectation(description: "Wait for map recording replay to finish.")

        didFinishLoadingStyle = { mapView in
            let recorder = mapView.mapboxMap.makeRecorder()
            recorder.start()

            mapView.camera.fly(to: CameraOptions(center: CLLocationCoordinate2D(latitude: 1, longitude: 1)), duration: 3) { _ in
                let mapRecordingSequence = recorder.stop()

                XCTAssertNotNil(mapRecordingSequence)
                XCTAssertEqual(recorder.playbackState(), "stopped")

                recorder.replay(recordedSequence: mapRecordingSequence) {
                    // Confirm the playback state returns to "stopped"
                    XCTAssertEqual(recorder.playbackState(), "stopped")
                    mapRecordingExpectation.fulfill()
                }

                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                    // Confirm map replay is playing
                    XCTAssertEqual(recorder.playbackState(), "playing")
                }
            }
        }

        wait(for: [mapRecordingExpectation], timeout: 10.0)
    }

    func testPauseMapRecording() {
        mapView.mapboxMap.styleURI = .standard
        let mapRecordingExpectation = XCTestExpectation(description: "Wait for map recording replay to stop after pausing.")

        didFinishLoadingStyle = { mapView in
            let recorder = mapView.mapboxMap.makeRecorder()
            recorder.start()

            mapView.camera.fly(to: CameraOptions(center: CLLocationCoordinate2D(latitude: 1, longitude: 1)), duration: 3) { _ in
                let mapRecordingSequence = recorder.stop()

                recorder.replay(recordedSequence: mapRecordingSequence) {
                    // Confirm the playback state returns to "stopped"
                    XCTAssertEqual(recorder.playbackState(), "stopped")
                    mapRecordingExpectation.fulfill()
                }

                // Pause map recording replay
                recorder.togglePauseReplay()

                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                    XCTAssertEqual(recorder.playbackState(), "paused")
                    // Restart map recording replay
                    recorder.togglePauseReplay()
                }
            }
        }

        wait(for: [mapRecordingExpectation], timeout: 10.0)
    }

}
