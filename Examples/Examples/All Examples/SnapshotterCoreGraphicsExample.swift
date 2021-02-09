import UIKit
import MapboxMaps

@objc(SnapshotterCoreGraphicsExample)

public class SnapshotterCoreGraphicsExample: UIViewController, ExampleProtocol {
    internal var mapView: MapView!
    public var snapshotter: Snapshotter!
    public var snapshotView: UIImageView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        let accessToken = AccountManager.shared.accessToken!

        // TODO: Fix crash that occurs when omitting MapViewController.
        let testRect = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        self.mapView = MapView(with: testRect, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Add the `UIImageView` that will eventually render the snapshot.
        snapshotView = UIImageView(frame: CGRect.zero)
        snapshotView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(snapshotView)

        NSLayoutConstraint.activate([
            snapshotView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            snapshotView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // Configure the snapshot options, such as the size and style to be used.
        let resourceOptions = ResourceOptions(accessToken: accessToken)
        let options = MapSnapshotOptions(size: CGSize(width: view.bounds.size.width,
                                                      height: view.bounds.height),
                                         resourceOptions: resourceOptions)
        self.snapshotter = Snapshotter(options: options)
        self.snapshotter.style.styleURL = .dark

        self.snapshotter.on(.styleFullyLoaded) { _ in
            self.startSnapshot()
        }
    }

    public func startSnapshot() {
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
        } completion: { ( result ) in
            switch result {
            case .success(let image):
                self.snapshotView.image = image
            case .failure(let error):
                print("Error generating snapshot: \(error)")
            }
            // The below line is used for internal testing purposes only.
            self.finish()
        }
    }
}
