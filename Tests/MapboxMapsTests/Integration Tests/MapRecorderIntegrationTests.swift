import XCTest
@testable @_spi(Experimental) import MapboxMaps

internal class MapRecorderIntegrationTests: MapViewIntegrationTestCase {
    private var playbackTimer: Timer?

    override func tearDownWithError() throws {
        // super removes the map view, which runs a pending fly completion that schedules the timer.
        defer {
            playbackTimer?.invalidate()
            playbackTimer = nil
        }
        try super.tearDownWithError()
    }

    func testReplayMapRecording() {
        let styleLoaded = XCTestExpectation(description: "Style loaded")
        let mapRecordingExpectation = XCTestExpectation(description: "Wait for map recording replay to finish.")

        didFinishLoadingStyle = { [weak self] mapView in
            styleLoaded.fulfill()
            do {
                let recorder = try mapView.mapboxMap.makeRecorder()
                recorder.start()

                mapView.camera.fly(to: CameraOptions(center: CLLocationCoordinate2D(latitude: 1, longitude: 1)), duration: 3) { position in
                    // A fly cancelled by teardown must not start a replay on the dying map.
                    guard position == .end else { return }
                    let mapRecordingSequence = recorder.stop()

                    XCTAssertNotNil(mapRecordingSequence)
                    XCTAssertEqual(recorder.playbackState(), "stopped")

                    recorder.replay(recordedSequence: mapRecordingSequence) {
                        // Confirm the playback state returns to "stopped"
                        XCTAssertEqual(recorder.playbackState(), "stopped")
                        mapRecordingExpectation.fulfill()
                    }

                    self?.playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                        // Confirm map replay is playing
                        XCTAssertEqual(recorder.playbackState(), "playing")
                    }
                }
            } catch {
                XCTFail("Unable to create MapRecorder \(error)")
            }
        }

        mapView.mapboxMap.styleURI = .standard
        // The Standard load time varies with the previous map's teardown, so it gets its own
        // budget and the 10s covers only the 3s fly and the replay.
        wait(for: [styleLoaded], timeout: 20)
        wait(for: [mapRecordingExpectation], timeout: 10.0)
    }

    func testPauseMapRecording() {
        mapView.mapboxMap.styleURI = .standard
        let mapRecordingExpectation = XCTestExpectation(description: "Wait for map recording replay to stop after pausing.")

        didFinishLoadingStyle = { [weak self] mapView in
            do {
                let recorder = try mapView.mapboxMap.makeRecorder()
                recorder.start()

                mapView.camera.fly(to: CameraOptions(center: CLLocationCoordinate2D(latitude: 1, longitude: 1)), duration: 3) { position in
                    // A fly cancelled by teardown must not start a replay on the dying map.
                    guard position == .end else { return }
                    let mapRecordingSequence = recorder.stop()

                    recorder.replay(recordedSequence: mapRecordingSequence) {
                        // Confirm the playback state returns to "stopped"
                        XCTAssertEqual(recorder.playbackState(), "stopped")
                        mapRecordingExpectation.fulfill()
                    }

                    // Pause map recording replay
                    recorder.togglePauseReplay()

                    self?.playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                        XCTAssertEqual(recorder.playbackState(), "paused")
                        // Restart map recording replay
                        recorder.togglePauseReplay()
                    }
                }
            } catch {
                XCTFail("Unable to create MapRecorder \(error)")
            }
        }

        wait(for: [mapRecordingExpectation], timeout: 20)
    }

}
