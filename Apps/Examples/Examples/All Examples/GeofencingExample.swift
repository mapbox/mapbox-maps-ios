import UIKit
import OSLog
import Turf
@_spi(Experimental) import MapboxMaps
@_spi(Experimental) import MapboxCommon

/// NOTE: - This example show the usage of experimental Geofencing API which is subject to changes.
final class GeofencingExample: UIViewController, ExampleProtocol, GeofencingObserver {
    private var mapView: MapView!
    private var geofencingBt: UIButton?
    private var geofenceDisabledText: UITextView?
    private var cancelables = Set<AnyCancelable>()
    private var geofencing = GeofencingFactory.getOrCreate()
    private var enterGeofenceId: String?
    private var dwellGeofenceId: String?
    private var exitGeofenceId: String?
    private var geofences: [Turf.Geometry?] = [nil, nil, nil]
    private var geofencingSpinner: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        let options = MapInitOptions(cameraOptions: CameraOptions(center: .helsinki, zoom: 11))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            guard let self = self else { return }
            setupGeofence()

            // The below line is used for internal testing purposes only.
            self.finish()
        }.store(in: &cancelables)

        var puckConfiguration = Puck2DConfiguration.makeDefault()
        puckConfiguration.pulsing = .default
        mapView.location.options.puckType = .puck2D(puckConfiguration)

        mapView.gestures.onMapTap.observe {[weak self] context in
            self?.addCustomGeofence(coordinate: context.coordinate)
        }.store(in: &cancelables)

        mapView.location.onLocationChange.observeNext { [weak mapView] newLocation in
            guard let mapView, let location = newLocation.last else { return }
            mapView.mapboxMap.setCamera(to: CameraOptions(center: location.coordinate, zoom: 18))
        }.store(in: &cancelables)

        addGeofencingButtonAndText()
    }

    private func setupGeofence() {
        CLLocationManager().requestAlwaysAuthorization()
        requestNotificationPermission()

        geofencing.configure(options: GeofencingOptions(maximumMonitoredFeatures: 150_000)) { [weak self] result in
            guard let self else { return }
            geofencing.addObserver(observer: self) { result in print("Add observer: \(result)") }
            updateGeofences()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        geofencing.removeObserver(observer: self) { result in print("Remove observer: \(result)") }
    }

    func onExit(event: MapboxCommon.GeofencingEvent) {
        guard case let .string(id) = event.feature.identifier else { return }
        os_log(.debug, "onExit: %s", id)
        exitGeofenceId = id
        updateGeofences()
    }

    func onEntry(event: MapboxCommon.GeofencingEvent) {
        guard case let .string(id) = event.feature.identifier else { return }
        os_log(.debug, "onEntry: %s", id)
        enterGeofenceId = id
        updateGeofences()
    }

    func onDwell(event: MapboxCommon.GeofencingEvent) {
        guard case let .string(id) = event.feature.identifier else { return }
        os_log(.debug, "onDwell: ", id)
        dwellGeofenceId = id
        updateGeofences()
    }

    func onError(error: MapboxCommon.GeofencingError) {
        os_log(.error, "onError: %s", error.message)
    }

    func onUserConsentChanged(isConsentGiven: Bool) {
        userRevokedConsentUI(isConsentGiven: isConsentGiven)
    }

    private func userRevokedConsentUI(isConsentGiven: Bool) {
        DispatchQueue.main.async {
            self.geofencingBt?.isHidden = !isConsentGiven
            self.geofenceDisabledText?.isHidden = isConsentGiven
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            print("Notification permission request finished. Success: \(success), error: \(String(describing: error))")
        }
    }

    private func sendNotification(title: String, subtitle: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func clearGeofences() {
        geofencing.clearFeatures { result in
            print("Geofences cleared. Result: \(result)")
        }
    }

    private func addCustomGeofence(coordinate: CLLocationCoordinate2D) {
        var feature = Feature(geometry: Point(coordinate))
        feature.identifier = .string(UUID().uuidString)
        feature.properties = [GeofencingPropertiesKeys.dwellTimeKey: 1]

        self.geofencing.addFeature(feature: feature) { result in
            print("Feature added with result: \(result)")
        }

        showToast(message: "Circle Geofence with center at (\(String(format: "%.4f", coordinate.latitude)), \(String(format: "%.4f", coordinate.longitude))) and default radius: \(Constants.defaultRadius) m is added", duration: 2)
    }

    private func getAndUpdateFeature(geofenceId: String, collectionIdx: Int, sourceId: String) {
        geofencing.getFeature(identifier: geofenceId, callback: {[weak self] result in
            switch result {
            case .success(let value):
                var feature = value.feature
                guard let self else { return }

                if let center = feature.coordinate {
                    geofences[collectionIdx] = Turf.Polygon(center: center, radius: 300.0, vertices: 64).geometry
                    feature.geometry = geofences[collectionIdx]
                } else {
                  geofences[collectionIdx] = feature.geometry!
                }

                let geometries = Turf.Geometry.geometryCollection(GeometryCollection(geometries: geofences.compactMap { $0 }))

                DispatchQueue.main.async {
                    self.mapView.camera.fly(to: self.mapView.mapboxMap.camera(for: geometries, padding: UIEdgeInsets(allEdges: 10), bearing: nil, pitch: nil))
                    self.mapView.mapboxMap.updateGeoJSONSource(withId: sourceId, geoJSON: .feature(feature))
                }
            case .failure(let error):
                os_log(.error, "Error while retrieving feature %s: %s", geofenceId, error.message)
            }
        })
    }

    private func updateGeofences() {
        if let enterGeofenceId {
            getAndUpdateFeature(geofenceId: enterGeofenceId, collectionIdx: 0, sourceId: Constants.enterGeofenceDataSourceId)
        }
        if let dwellGeofenceId {
            getAndUpdateFeature(geofenceId: dwellGeofenceId, collectionIdx: 1, sourceId: Constants.dwellGeofenceDataSourceId)
        }
        if let exitGeofenceId {
            getAndUpdateFeature(geofenceId: exitGeofenceId, collectionIdx: 2, sourceId: Constants.exitGeofenceDataSourceId)
        }
    }
}

/// Download data from internet
extension GeofencingExample {
    /// Enqueues a dataset fetch to the global async queue
    func datasetFetch(baseUrl: String, completion: @escaping (Result<Turf.FeatureCollection, Error>) -> Void) {
        let url = URL(string: baseUrl)!
        DispatchQueue.global().async {
            let result: Result<Turf.FeatureCollection, Error>
            do {
                let data = try Data(contentsOf: url)
                let featureCollection = try JSONDecoder().decode(Turf.FeatureCollection.self, from: data)
                result = .success(featureCollection)
            } catch {
                result = .failure(error)
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    /// Fetches the geofences from Mapbox datasets API (starting at startId) and adds them to the geofencing engine
    private func loadGeofences(baseUrl: String = Constants.datastoreBaseUrl) {
        showSpinnerIfNeeded()
        datasetFetch(baseUrl: baseUrl) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let featureCollection):
                featureCollection.features.forEach { feature in
                    var feature = feature
                    let properties: JSONObject = feature.properties!
                    guard let fid = properties["FID"]!!.rawValue as? Double,
                          let fid1 = properties["Fid_1"]!!.rawValue as? Double,
                          let hslId = properties["Id"]!!.rawValue as? String else {
                        os_log(.error, "Missing iso or unitCode")
                        return
                    }
                    let id = String(fid) + "-" + String(fid1) + "-" + hslId
                    feature.identifier = .string(id)
                    feature.properties![GeofencingPropertiesKeys.dwellTimeKey] = 1
                    self.geofencing.addFeature(feature: feature) { result in print("Feature added with result: \(result)") }
                }

                hideSpinner()

            case .failure(let failure):
                os_log(.error, "Failed to read features dataset: %s", failure.localizedDescription)
            }
        }
    }
}

/// UI Layout
extension GeofencingExample {
    private func addGeofencingButtonAndText() {
        let button = UIButton(type: .system)
        button.setTitle("Geofencing", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 0.9882352941, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(geofencingOptions(sender:)), for: .touchUpInside)
        view.addSubview(button)

        let buttonLayoutConstraints = [
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 40)
        ]
        NSLayoutConstraint.activate(buttonLayoutConstraints)
        geofencingBt = button

        let textView = UITextView()
        textView.text = "User consent revoked"
        textView.textColor = .white
        textView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textAlignment = .center
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.layer.cornerRadius = 10
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)

        let textLayoutConstraints = [
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textView.widthAnchor.constraint(equalToConstant: 200),
            textView.heightAnchor.constraint(equalToConstant: 40)
        ]
        NSLayoutConstraint.activate(textLayoutConstraints)
        geofenceDisabledText = textView

        let isConsentGiven = GeofencingUtils.getUserConsent()

        self.geofencingBt?.isHidden = !isConsentGiven
        self.geofenceDisabledText?.isHidden = isConsentGiven
    }

    @objc func geofencingOptions(sender: UIButton) {
        let alert = UIAlertController(title: "Geofencing Options", message: "", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = sender

        alert.addAction(UIAlertAction(title: "Load HSL geofences", style: .default) { _ in
            self.loadGeofences()
        })

        alert.addAction(UIAlertAction(title: "Remove all geofences", style: .destructive) { _ in
            self.clearGeofences()
        })

        alert.addAction(UIAlertAction(title: "Geofence boundaries courtesy Helsingin seuden liiken HSL(CC-BY)", style: .default) { _ in
            UIApplication.shared.open(URL(string: "https://hri.fi/data/en_GB/dataset/hsl-n-taksavyohykkeet")!, options: [:], completionHandler: nil)
        })

        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { _ in })

        present(alert, animated: true)
    }

    private func showSpinnerIfNeeded() {
        if geofencingSpinner == nil {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)

            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.startAnimating()
            spinner.hidesWhenStopped = true
            view.addSubview(spinner)

            NSLayoutConstraint.activate([
                spinner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
                spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                spinner.widthAnchor.constraint(equalToConstant: 200),
                spinner.heightAnchor.constraint(equalToConstant: 40)
            ])

            geofencingBt?.isEnabled = false
            geofencingBt?.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)

            geofencingSpinner = spinner
        }
    }

    private func hideSpinner() {
        guard let spinner = geofencingSpinner else { return }
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        geofencingSpinner = nil
        geofencingBt?.isEnabled = true
        geofencingBt?.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 0.9882352941, alpha: 1)
    }

    func showToast(message: String, duration: Double = 2.0) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.numberOfLines = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true

        let maxSizeTitle = CGSize(width: self.view.bounds.size.width - 40, height: self.view.bounds.size.height)
        var expectedSizeTitle = toastLabel.sizeThatFits(maxSizeTitle)
        expectedSizeTitle.width = min(maxSizeTitle.width, expectedSizeTitle.width)
        expectedSizeTitle.height = min(50, expectedSizeTitle.height)

        toastLabel.frame = CGRect(
            x: (self.view.frame.size.width - expectedSizeTitle.width) / 2,
            y: self.view.frame.size.height - 150,
            width: expectedSizeTitle.width + 20,
            height: expectedSizeTitle.height + 10
        )

        self.view.addSubview(toastLabel)

        UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: { toastLabel.alpha = 0.0 }) { _ in
            toastLabel.removeFromSuperview()
        }
    }
}

/// Support Uset Notifications use case
extension GeofencingExample {
    func updateEnterGeofenceId(id: String) {
        enterGeofenceId = id
        updateGeofences()
    }

    func updateExitGeofenceId(id: String) {
        exitGeofenceId = id
        updateGeofences()
    }

    func updateDwellGeofenceId(id: String) {
        dwellGeofenceId = id
        updateGeofences()
    }
}

private enum Constants {
    static let defaultRadius: UInt32 = 300
    static let enterGeofenceDataSourceId = "enter-geofence-source"
    static let exitGeofenceDataSourceId = "exit-geofence-source"
    static let dwellGeofenceDataSourceId = "dwell-geofence-source"
    // HSL public dataset of Helsinki tariff zones
    static let datastoreBaseUrl = "https://opendata.arcgis.com/datasets/89b6b5142a9b4bb9a5c5f4404ff28963_0.geojson"
}

extension Turf.Feature {
    var coordinate: CLLocationCoordinate2D? { geometry?.point?.coordinates }
}
