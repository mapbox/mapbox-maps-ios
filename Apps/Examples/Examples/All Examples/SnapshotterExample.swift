import UIKit
@_spi(Experimental) import MapboxMaps

final class SnapshotterExample: UIViewController, ExampleProtocol {
    private var cancelables = Set<AnyCancelable>()
    private var mapView: MapView!
    private var snapshotter: Snapshotter!
    private var snapshotView: UIImageView!
    private var snapshotting = false
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: view.safeAreaLayoutGuide.layoutFrame)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 12.0
        return stackView
    }()
    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.mapboxMap.mapStyle = .standard(lightPreset: .dawn, showRoadLabels: false)
        // Add the `MapViewController`'s view to the stack view as a
        // child view controller.
        stackView.addArrangedSubview(mapView)

        // Add the image view to the stack view, which will eventually contain the snapshot.
        snapshotView = UIImageView()
        snapshotView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(snapshotView)

        // Add the stack view to the root view.
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        if #available(iOS 15.0, *) {
            view.backgroundColor = .systemMint
        } else {
            view.backgroundColor = .systemGray
        }
        if #available(iOS 13.0, *) {
            snapshotView.backgroundColor = .systemGray4
        } else {
            snapshotView.backgroundColor = .systemGray
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let size = CGSize(
            width: view.safeAreaLayoutGuide.layoutFrame.width,
            height: (view.safeAreaLayoutGuide.layoutFrame.height - stackView.spacing) / 2)

        if let snapshotter {
            snapshotter.snapshotSize = size
        } else {
            initializeSnapshotter(with: size)
        }
    }

    private func initializeSnapshotter(with size: CGSize) {
        // Configure the snapshotter object with its size, map style, and camera.
        let options = MapSnapshotOptions(
            size: size,
            pixelRatio: UIScreen.main.scale)

        snapshotter = Snapshotter(options: options)
        snapshotter.load(mapStyle: .standard(lightPreset: .dusk))

        // Set the camera of the snapshotter

        mapView.mapboxMap.onMapIdle.observe { [weak self] _ in
            // Allow the previous snapshot to complete before starting a new one.
            guard let self = self, !self.snapshotting else {
                return
            }

            let snapshotterCameraOptions = CameraOptions(cameraState: self.mapView.mapboxMap.cameraState)
            self.snapshotter.setCamera(to: snapshotterCameraOptions)
            self.startSnapshot()
        }.store(in: &cancelables)
    }

    public func startSnapshot() {
        snapshotting = true
        snapshotter.start(overlayHandler: nil) { ( result ) in
            switch result {
            case .success(let image):
                self.snapshotView.image = image
            case .failure(let error):
                print("Error generating snapshot: \(error)")
            }
            self.snapshotting = false
            // The below line is used for internal testing purposes only.
            self.finish()
        }
    }
}
