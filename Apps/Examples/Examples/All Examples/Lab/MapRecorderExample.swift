import UIKit
@_spi(Experimental) import MapboxMaps

final class MapRecorderExample: UIViewController, ExampleProtocol {

    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.ornaments.options.scaleBar.visibility = .visible

        view.addSubview(mapView)

        mapView.mapboxMap.onStyleLoaded.observeNext { _ in
            // Once the Style is loaded, create the ``MapRecorder`` and start the recording
            guard let recorder = try? self.mapView.mapboxMap.makeRecorder() else { return }
            recorder.start()

            // Build a new set of CameraOptions for the map to fly to
            let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 45.4588, longitude: -73.581), zoom: 11, pitch: 35)

            self.mapView.camera.fly(to: cameraOptions, duration: 10, completion: { _ in
                // When the camera animation is complete, stop the map recording
                // Replay the camera animation twice at double speed by passing the recorded sequence returned from the stop method
                let mapRecordingSequence = recorder.stop()
                recorder.replay(recordedSequence: mapRecordingSequence, options: MapPlayerOptions(playbackCount: 2, playbackSpeedMultiplier: 2.0, avoidPlaybackPauses: false)) {
                    print(recorder.playbackState())
                }
            })
        }.store(in: &cancelables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }
}
