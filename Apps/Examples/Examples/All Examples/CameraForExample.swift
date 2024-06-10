import UIKit
@_spi(Experimental) import MapboxMaps

@available(iOS 13.0, *)
final class CameraForExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()
    private var selectedPlace: [CLLocationCoordinate2D] = .baltic

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.debugOptions = [.camera, .padding]
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        addBottomSheet()
        addPolygons()

        setCamera(immediately: true, onMapLoaded: true)
    }

    private func setCamera(immediately: Bool, onMapLoaded: Bool) {
        if immediately {
            setCamera(coordinates: selectedPlace, mapPadding: .zero, coordinatesPadding: .zero)
        }

        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            guard let self else { return }
            if onMapLoaded {
                setCamera(coordinates: selectedPlace, mapPadding: .zero, coordinatesPadding: .zero)
            }
            finish() // for testing purposes
        }.store(in: &cancelables)
    }

    private func setCamera(
        coordinates: [CLLocationCoordinate2D],
        mapPadding: UIEdgeInsets,
        coordinatesPadding: UIEdgeInsets
    ) {
        do {
            let initialCameraOptions = CameraOptions(
                padding: mapPadding,
                bearing: 0,
                pitch: 0
            )

            let boundingPolygonCameraOptions = try mapView.mapboxMap.camera(
                for: coordinates,
                camera: initialCameraOptions,
                coordinatesPadding: coordinatesPadding,
                maxZoom: nil,
                offset: nil
            )

            if mapView.mapboxMap.isStyleLoaded {
                mapView.camera.ease(to: boundingPolygonCameraOptions, duration: 0.5)
            } else {
                mapView.mapboxMap.setCamera(to: boundingPolygonCameraOptions)
            }

        } catch {
            showAlert(with: String(describing: error))
        }
    }

    private func addPolygons() {
        mapView.mapboxMap.setMapStyleContent {
            GeoJSONSource(id: "poly-south-pole")
                .data(.geometry(.lineString(LineString(.antarctic))))

            LineLayer(id: "poly-south-pole-line", source: "poly-south-pole")
                .lineWidth(2.0)
                .lineColor(.red)

            GeoJSONSource(id: "poly-baltic")
                .data(.geometry(.lineString(LineString(.baltic))))

            LineLayer(id: "poly-baltic-line", source: "poly-baltic")
                .lineWidth(2.0)
                .lineColor(.red)
        }
    }

    private func addBottomSheet() {
        let bottomSheet = BottomSheet(frame: CGRect(
            x: 0,
            y: view.bounds.height - 280,
            width: view.bounds.width,
            height: 280
        ))
        bottomSheet.layer.cornerRadius = 16
        bottomSheet.layer.opacity = 0.8
        bottomSheet.backgroundColor = .white
        bottomSheet.selectedPlace = selectedPlace
        bottomSheet.onSelectionChanged = { [weak self] cordinates, mapPadding, coordinatesPadding in
            self?.setCamera(coordinates: cordinates, mapPadding: mapPadding, coordinatesPadding: coordinatesPadding)
        }

        view.addSubview(bottomSheet)
    }
}

private final class BottomSheet: UIView {
    let placesControl = UISegmentedControl(items: places.map(\.name))
    let mapAllEdgesInset = UISegmentedControl(items: insetValues)
    let leftCoordinatesInset = UISegmentedControl(items: insetValues)
    let rightCoordinatesInsets = UISegmentedControl(items: insetValues)

    let titles = ["right coordinates padding", "left coordinates padding", "map padding", "place"]
    var titleLabels: [UILabel] = []

    var onSelectionChanged: (([CLLocationCoordinate2D], UIEdgeInsets, UIEdgeInsets) -> Void)?
    var selectedPlace: [CLLocationCoordinate2D]?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        setupSegmentedControl(placesControl, selected: places.firstIndex(where: { $0.coordinates == selectedPlace }) ?? 0)
        setupSegmentedControl(mapAllEdgesInset)
        setupSegmentedControl(leftCoordinatesInset)
        setupSegmentedControl(rightCoordinatesInsets)

        addSubview(placesControl)
        addSubview(mapAllEdgesInset)
        addSubview(leftCoordinatesInset)
        addSubview(rightCoordinatesInsets)

        createLabels()
        layoutViews()
    }

    func setupSegmentedControl(_ segmentedControl: UISegmentedControl, selected: Int = 0) {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = selected
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }

    @objc func segmentedControlValueChanged(_ segmentedControl: UISegmentedControl) {
        let mapPadding = UIEdgeInsets(
            allEdges: CGFloat((insetValues[mapAllEdgesInset.selectedSegmentIndex] as NSString).floatValue)
        )

        let coordinatesPadding = UIEdgeInsets(
            top: 0,
            left: CGFloat((insetValues[leftCoordinatesInset.selectedSegmentIndex] as NSString).floatValue),
            bottom: 0,
            right: CGFloat((insetValues[rightCoordinatesInsets.selectedSegmentIndex] as NSString).floatValue)
        )

        onSelectionChanged?(places[placesControl.selectedSegmentIndex].coordinates, mapPadding, coordinatesPadding)
    }

    func createLabels() {
        for (_, title) in titles.enumerated() {
            let label = UILabel()
            label.text = title
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            titleLabels.append(label)
        }
    }

    func layoutViews() {
        let spacing: CGFloat = 20
        var lastBottomAnchor = bottomAnchor

        let controls = [rightCoordinatesInsets, leftCoordinatesInset, mapAllEdgesInset, placesControl]

        for (index, segmentedControl) in controls.enumerated() {
            NSLayoutConstraint.activate([
                segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
                segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing),
                segmentedControl.bottomAnchor.constraint(equalTo: lastBottomAnchor, constant: -spacing - 10),

                titleLabels[index].leftAnchor.constraint(equalTo: segmentedControl.leftAnchor),
                titleLabels[index].bottomAnchor.constraint(equalTo: segmentedControl.topAnchor, constant: 0)
            ])

            lastBottomAnchor = segmentedControl.topAnchor
        }
    }
}

private extension Array where Element == CLLocationCoordinate2D {
    static let baltic: [CLLocationCoordinate2D] = [.helsinki, .vyborg, .saintPetersburg, .talinn, .helsinki]
    static let antarctic: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: -74.41429582091831, longitude: -105.02738295071447),
        CLLocationCoordinate2D(latitude: -82.41571395310365, longitude: -108.67784207799926),
        CLLocationCoordinate2D(latitude: -71.45151781686236, longitude: -117.5641615804278),
        CLLocationCoordinate2D(latitude: -74.41429582091831, longitude: -105.02738295071447)
    ]
}

private extension CLLocationCoordinate2D {
    static let saintPetersburg = CLLocationCoordinate2D(latitude: 59.9375, longitude: 30.308611)
    static let talinn = CLLocationCoordinate2D(latitude: 59.437039, longitude: 24.745739)
    static let vyborg = CLLocationCoordinate2D(latitude: 60.7, longitude: 28.766667)
}

private let insetValues = ["0", "20", "50", "100"]

private struct Place {
    let name: String
    let coordinates: [CLLocationCoordinate2D]
}

private let places = [
    Place(name: "baltic", coordinates: .baltic),
    Place(name: "antarctic", coordinates: .antarctic)
]
