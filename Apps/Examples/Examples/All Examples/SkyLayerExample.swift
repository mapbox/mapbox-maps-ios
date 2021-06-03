import UIKit
import MapboxMaps

@objc(SkyLayerExample)

public class SkyLayerExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    internal var skyLayer: SkyLayer!
    internal var segmentedControl = UISegmentedControl()
    
    internal var skyAtmosphereSun = [Double]()

    override public func viewDidLoad() {
        super.viewDidLoad()

        let center = CLLocationCoordinate2D(latitude: 35.67283, longitude: 127.60597)
        let cameraOptions = CameraOptions(center: center, zoom: 14, pitch: 83)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .init(url: URL(string: "mapbox://styles/mapbox-map-design/ckhqrf2tz0dt119ny6azh975y")!))
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)
        
        addSliders()
        mapView.mapboxMap.onNext(.styleLoaded) { _ in
            self.addSkyLayer()
        }
    }

    func addSkyLayer() {
        skyLayer = SkyLayer(id: "sky-layer")
        skyLayer.skyType = .constant(.gradient)
        
        skyAtmosphereSun = [0, 90]
        skyLayer.skyAtmosphereSun = .constant(skyAtmosphereSun)
        skyLayer.skyAtmosphereSunIntensity = .constant(10)
        
        skyLayer.skyAtmosphereColor = .constant(ColorRepresentable(color: .skyBlue))
        skyLayer.skyAtmosphereHaloColor = .constant(ColorRepresentable(color: .lightPink))
        
        try! mapView.mapboxMap.style.addLayer(skyLayer)
    }

    // Update the sky layer based on changes to the `UISlider` value.
    @objc func updateSkyLayer() {
        var skyType : Value<SkyType>
        if segmentedControl.selectedSegmentIndex == 0 {
            skyType = .constant(.gradient)
        } else {
            skyType = .constant(.atmosphere)
        }
        try! mapView.mapboxMap.style.updateLayer(withId: skyLayer.id) { (layer: inout SkyLayer) throws in
            skyLayer.skyType = skyType
            skyLayer.skyAtmosphereSunIntensity = .constant(100)
        }
    }

    func addSliders() {
        segmentedControl = UISegmentedControl(items: ["Gradient", "Atmosphere"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(updateSkyLayer), for: .valueChanged)
        view.insertSubview(segmentedControl, aboveSubview: mapView)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            segmentedControl.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -80),
            segmentedControl.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor)
        ])
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }
}

extension UIColor {
    static var skyBlue: UIColor {
        return UIColor(red: 0.53, green: 0.81, blue: 0.92, alpha: 1.00)
    }
    
    static var lightPink: UIColor {
        return UIColor(red: 1.00, green: 0.82, blue: 0.88, alpha: 1.00)
    }
}
