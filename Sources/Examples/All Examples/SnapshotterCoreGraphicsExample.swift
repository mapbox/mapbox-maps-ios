import UIKit
import MapboxMaps

final class SnapshotterCoreGraphicsExample: UIViewController, NonMapViewExampleProtocol {
    private var snapshotter: Snapshotter!
    private var snapshotView: UIImageView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add the `UIImageView` that will eventually render the snapshot.
        snapshotView = UIImageView(frame: CGRect.zero)
        snapshotView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(snapshotView)

        NSLayoutConstraint.activate([
            snapshotView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            snapshotView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // Configure the snapshot options, such as the size, scale and style to be used.
        // Here we use a scale (pixelRatio) that is different than the display's
        // scale (UIScreen.main.scale)
        let options = MapSnapshotOptions(size: CGSize(width: view.bounds.size.width,
                                                      height: view.bounds.height),
                                         pixelRatio: 4)
        snapshotter = Snapshotter(options: options)
        snapshotter.styleURI = .dark
        snapshotter.setCamera(to: CameraOptions(center: CLLocationCoordinate2D(latitude: 51.180885866921386, longitude: 16.26129435178828), zoom: 4))

        snapshotter.onStyleLoaded.observeNext { [weak self] _ in
            self?.startSnapshot()
        }.store(in: &cancelables)
    }

    private func startSnapshot() {
        // Begin the snapshot after the style is loaded into the `Snapshotter`.
        // The `SnapshotOverlay` object contains references to the current
        // graphics context being used by the Snapshotter and provides closures to
        // perform coordinate conversion between map and screen coordinates.
        snapshotter.start { ( overlayHandler ) in
            let context = overlayHandler.context

            // Convert the map coordinates for Berlin and Kraków to points,
            // in order to correctly position the Core Graphics drawing code.
            let berlin = overlayHandler.pointForCoordinate(CLLocationCoordinate2D(latitude: 52.53,
                                                                                  longitude: 13.38))
            let krakow = overlayHandler.pointForCoordinate(CLLocationCoordinate2D(latitude: 50.06,
                                                                                  longitude: 19.92))
            // Draw a yellow line between Berlin and Kraków.
            context.setStrokeColor(UIColor.yellow.cgColor)
            context.setLineWidth(6.0)
            context.setLineCap(.round)
            context.move(to: berlin)
            context.addLine(to: krakow)
            context.strokePath()
        } completion: { [weak self] result in
            switch result {
            case .success(let image):
                self?.snapshotView.image = image
            case .failure(let error):
                print("Error generating snapshot: \(error)")
            }
            // The below line is used for internal testing purposes only.
            self?.finish()
        }
    }
}
