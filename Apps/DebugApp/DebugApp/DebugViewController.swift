import UIKit
import MapboxMaps

/**
 NOTE: This view controller should be used as a scratchpad
 while you develop new features. Changes to this file
 should not be committed.
 */

final class DebugViewController: UIViewController {

    var mapView: MapView!

    private var devices: [String] = [
        "iPhone 11 Pro",
        "Galaxy Pixel 12",
        "Huawei Vision 23"
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(mapView, at: 0)

        for deviceName in devices {
            let options = ViewAnnotationOptions(
                geometry: Point(LocationCoordinate2D(latitude: .random(in: 40...60), longitude: .random(in: 10...30))),
                width: 150,
                height: 20)
            let label = UILabel()
            label.text = deviceName
            label.backgroundColor = .white

            try! mapView.viewAnnotations.add(label, id: deviceName, options: options)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.update(device: self.devices.randomElement()!)
        }
    }

    private func update(device: String) {
        for device in devices {
            let view = mapView.viewAnnotations.view(forId: device)
            view?.backgroundColor = .white
        }

        let view = mapView.viewAnnotations.view(forId: device)
        view?.backgroundColor = .systemRed
    }
}
