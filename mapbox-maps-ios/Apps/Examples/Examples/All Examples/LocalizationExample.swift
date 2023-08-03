import UIKit
import MapboxMaps

public class LocalizationExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override public func viewDidLoad() {
        super.viewDidLoad()

        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 49.82598438746018, longitude: 9.6984608286634), zoom: 2)
        mapView = MapView(frame: view.bounds, mapInitOptions: MapInitOptions(cameraOptions: cameraOptions, styleURI: .streets))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        configureLanguageButton()

        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.onMapLoaded.observeNext { _ in
            self.finish() // Needed for internal testing purposes.
        }.store(in: &cancelables)
    }

    private func configureLanguageButton() {
        // Set up layer postion change button
        let button = UIButton(type: .system)
        button.setTitle("Change Language", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 0.9882352941, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(changeLanguage(sender:)), for: .touchUpInside)
        view.addSubview(button)

        // Set button location
        let horizontalConstraint = button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        let verticalConstraint = button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 200)
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 40)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }

    @objc public func changeLanguage(sender: UIButton) {
        let alert = UIAlertController(title: "Languages",
                                      message: "Please select a language to localize to.",
                                      preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = sender

        alert.addAction(UIAlertAction(title: "Device Locale", style: .default, handler: { [weak self] _ in
            do {
                try self?.mapView.mapboxMap.localizeLabels(into: Locale.current)
            } catch {
                print(error)
            }
        }))

        alert.addAction(UIAlertAction(title: "Spanish", style: .default, handler: { [weak self] _ in
            try! self?.mapView.mapboxMap.localizeLabels(into: Locale(identifier: "es"))
        }))

        alert.addAction(UIAlertAction(title: "French", style: .default, handler: { [weak self] _ in
            try! self?.mapView.mapboxMap.localizeLabels(into: Locale(identifier: "fr"))
        }))

        alert.addAction(UIAlertAction(title: "Traditional Chinese", style: .default, handler: { [weak self] _ in
            try! self?.mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh-Hant"))
        }))

        alert.addAction(UIAlertAction(title: "Arabic", style: .default, handler: { [weak self] _ in
            try! self?.mapView.mapboxMap.localizeLabels(into: Locale(identifier: "ar"))
        }))

        alert.addAction(UIAlertAction(title: "English", style: .default, handler: { [weak self] _ in
            try! self?.mapView.mapboxMap.localizeLabels(into: Locale(identifier: "en"))
        }))

        alert.addAction(UIAlertAction(title: "Japanese - Countries Only", style: .default, handler: { [weak self] _ in
            try! self?.mapView.mapboxMap.localizeLabels(into: Locale(identifier: "ja"), forLayerIds: ["country-label"])
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
}
