import UIKit
import MapboxMaps

final class FeatureStateExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var descriptionView: EarthquakeDescriptionView!
    private var previouslyTappedEarthquakeId: String = ""
    private var cancelables = Set<AnyCancelable>()

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current

        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Center the map over the United States.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 39.368279,
                                                      longitude: -97.646484)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 2.4))

        // Set up map view
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.ornaments.options.scaleBar.visibility = .hidden
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Set up description view
        descriptionView = EarthquakeDescriptionView(frame: .zero)
        view.addSubview(descriptionView)
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 2.0).isActive = true
        descriptionView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        descriptionView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        descriptionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2.0).isActive = true

        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            self?.setupSourceAndLayer()

            // The below lines are used for internal testing purposes only.
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self?.finish()
            }
        }.store(in: &cancelables)

        mapView.gestures.onLayerTap("earthquake-viz") { [weak self] queriedFeature, _ in
            self?.handleTappedFeature(queriedFeature)
            return true
        }.store(in: &cancelables)
    }

    func setupSourceAndLayer() {

        // Create a new GeoJSON data source which gets its data from an external URL.
        guard let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
            preconditionFailure("Could not calculate date for seven days ago.")
        }

        // Format the date to ISO8601 as required by the earthquakes API
        let iso8601DateFormatter = ISO8601DateFormatter()
        iso8601DateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let startTime = iso8601DateFormatter.string(from: sevenDaysAgo)

        // Create the url required for the GeoJSONSource
        guard let earthquakeURL = URL(string: "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&eventtype=earthquake&minmagnitude=1&starttime=" + startTime) else {
            preconditionFailure("URL is not valid")
        }

        var earthquakeSource = GeoJSONSource(id: Self.earthquakeSourceId)
        earthquakeSource.data = .url(earthquakeURL)
        earthquakeSource.generateId = true

        do {
            try mapView.mapboxMap.addSource(earthquakeSource)
        } catch {
            print("Ran into an error adding a source: \(error)")
        }

        // Add earthquake-viz layer
        var earthquakeVizLayer = CircleLayer(id: Self.earthquakeLayerId, source: Self.earthquakeSourceId)

        // The feature-state dependent circle-radius expression will render
        // the radius size according to its magnitude when
        // a feature's selected state is set to true
        earthquakeVizLayer.circleRadius = .expression(
            Exp(.switchCase) {
                Exp(.boolean) {
                    Exp(.featureState) { "selected" }
                    false
                }
                Exp(.interpolate) {
                    Exp(.linear)
                    Exp(.get) { "mag" }
                    1
                    8
                    1.5
                    10
                    2
                    12
                    2.5
                    14
                    3
                    16
                    3.5
                    18
                    4.5
                    20
                    6.5
                    22
                    8.5
                    24
                    10.5
                    26
                }
                5
            }
        )
        earthquakeVizLayer.circleRadiusTransition = StyleTransition(duration: 0.5, delay: 0)
        earthquakeVizLayer.circleStrokeColor = .constant(StyleColor(.black))
        earthquakeVizLayer.circleStrokeWidth = .constant(1)

        // The feature-state dependent circle-color expression will render
        // the color according to its magnitude when
        // a feature's hover state is set to true
        earthquakeVizLayer.circleColor = .expression(
            Exp(.switchCase) {
                Exp(.boolean) {
                    Exp(.featureState) { "selected" }
                    false
                }
                Exp(.interpolate) {
                    Exp(.linear)
                    Exp(.get) { "mag" }
                    1
                    "#fff7ec"
                    1.5
                    "#fee8c8"
                    2
                    "#fdd49e"
                    2.5
                    "#fdbb84"
                    3
                    "#fc8d59"
                    3.5
                    "#ef6548"
                    4.5
                    "#d7301f"
                    6.5
                    "#b30000"
                    8.5
                    "#7f0000"
                    10.5
                    "#000"
                }
                "#000"
            }
        )
        earthquakeVizLayer.circleColorTransition = StyleTransition(duration: 0.5, delay: 0)

        do {
            try mapView.mapboxMap.addLayer(earthquakeVizLayer)
        } catch {
            print("Ran into an error adding a layer: \(error)")
        }
    }

    private func handleTappedFeature(_ queriedFeature: QueriedFeature) {
        let earthquakeFeature = queriedFeature.feature
        if case .number(let earthquakeIdDouble) = earthquakeFeature.identifier,
           case .point(let point) = earthquakeFeature.geometry,
           case let .number(magnitude) = earthquakeFeature.properties?["mag"],
           case let .string(place) = earthquakeFeature.properties?["place"],
           case let .number(timestamp) = earthquakeFeature.properties?["time"] {

            let earthquakeId = Int(earthquakeIdDouble).description

            // Set the description of the earthquake from the `properties` object
            self.setDescription(magnitude: magnitude, timeStamp: timestamp, location: place)

            // Set the earthquake to be "selected"
            self.setSelectedState(earthquakeId: earthquakeId)

            // Reset a previously tapped earthquake to be "unselected".
            self.resetPreviouslySelectedStateIfNeeded(currentTappedEarthquakeId: earthquakeId)

            // Store the currently tapped earthquake so it can be reset when another earthquake is tapped.
            self.previouslyTappedEarthquakeId = earthquakeId

            // Center the selected earthquake on the screen
            self.mapView.camera.fly(to: CameraOptions(center: point.coordinates, zoom: 10))
        }
    }

    func setDescription(magnitude: Double, timeStamp: Double, location: String) {
        self.descriptionView.magnitudeLabel.text = "Magnitude: \(magnitude)"
        self.descriptionView.locationLabel.text = "Location: \(location)"
        self.descriptionView.dateLabel.text = "Date: " + self.dateFormatter.string(
            from: Date(timeIntervalSince1970: timeStamp / 1000.0))
    }

    // Sets a particular earthquake to be selected
    func setSelectedState(earthquakeId: String) {
        self.mapView.mapboxMap.setFeatureState(sourceId: Self.earthquakeSourceId,
                                               sourceLayerId: nil,
                                               featureId: earthquakeId,
                                               state: ["selected": true]) { result in
            switch result {
            case .failure(let error):
                print("Could not retrieve feature state: \(error).")
            case .success:
                print("Succesfully set feature state.")
            }
        }
    }

    // Resets the previously selected earthquake to be "unselected" if needed.
    func resetPreviouslySelectedStateIfNeeded(currentTappedEarthquakeId: String) {

        if self.previouslyTappedEarthquakeId != ""
            && currentTappedEarthquakeId != self.previouslyTappedEarthquakeId {
            // Reset a previously tapped earthquake to be "unselected".
            self.mapView.mapboxMap.setFeatureState(sourceId: Self.earthquakeSourceId,
                                                    sourceLayerId: nil,
                                                    featureId: self.previouslyTappedEarthquakeId,
                                                   state: ["selected": false]) { result in
                switch result {
                case .failure(let error):
                    print("Could not retrieve feature state: \(error).")
                case .success:
                    print("Succesfully set feature state.")
                }
            }
        }
    }

    // Present an alert with a given title.
    func showAlert(with title: String) {
        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

private class EarthquakeDescriptionView: UIView {

    var magnitudeLabel: UILabel!
    var locationLabel: UILabel!
    var dateLabel: UILabel!
    var stackView: UIStackView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.opacity = 0.7
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.black.cgColor
        createSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createSubviews() {

        func createLabel(placeholder: String) -> UILabel {
            let label = UILabel(frame: .zero)
            label.font = UIFont.systemFont(ofSize: 10)
            label.numberOfLines = 0
            label.text = placeholder
            label.textColor = .black
            return label
        }

        magnitudeLabel = createLabel(placeholder: "Magnitude: ---")
        locationLabel = createLabel(placeholder: "Location: ---")
        dateLabel = createLabel(placeholder: "Date: ---")

        let stackview = UIStackView()
        stackview.axis = .vertical
        stackview.spacing = 1
        stackview.alignment = .leading
        stackview.distribution = .fillEqually
        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.addArrangedSubview(magnitudeLabel)
        magnitudeLabel.widthAnchor.constraint(equalTo: stackview.widthAnchor).isActive = true

        stackview.addArrangedSubview(locationLabel)
        locationLabel.widthAnchor.constraint(equalTo: stackview.widthAnchor).isActive = true

        stackview.addArrangedSubview(dateLabel)
        dateLabel.widthAnchor.constraint(equalTo: stackview.widthAnchor).isActive = true

        self.addSubview(stackview)
        stackview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        stackview.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        stackview.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackview.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

    }
}

private extension FeatureStateExample {
    static let earthquakeSourceId: String = "earthquakes"
    static let earthquakeLayerId: String = "earthquake-viz"
}
