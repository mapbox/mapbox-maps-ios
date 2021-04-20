import UIKit
import MapboxMaps

@objc(BasicMapExample)

public class BasicMapExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    internal var startTime: CFAbsoluteTime?
    private var metaView: MapMetaView?

    override public func viewDidLoad() {
        super.viewDidLoad()

        startTime = CFAbsoluteTimeGetCurrent()
        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Set the center coordinate of the map to Honolulu, Hawaii
        let centerCoordinate = CLLocationCoordinate2D(latitude: 35.655238, longitude: 139.709769)
        // Create a camera
        let camera = CameraOptions(center: centerCoordinate,
                                     zoom: 15)
        mapView.cameraManager.setCamera(to: camera)
        mapView.style.uri = .streets
        
        mapView.on(.mapLoaded) { (event) in
            guard let start = self.startTime else {
                return
            }
            let timeElapsed = CFAbsoluteTimeGetCurrent() - start
            print(Double(timeElapsed))
            self.metaView?.set(diff: timeElapsed)
        }
        view.addSubview(mapView)
        
        metaView = MapMetaView()
        metaView!.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(metaView!)
        
        NSLayoutConstraint.activate([
            metaView!.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            metaView!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            metaView!.widthAnchor.constraint(equalToConstant: 200),
            metaView!.heightAnchor.constraint(equalToConstant: 70),
        ])
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }
}



public class MapMetaView: UIView {
    private var latlngzLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        view.textColor = .black
        return view
    }()
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    private func commonInit() {
        backgroundColor = .lightGray
        addSubview(latlngzLabel)
        NSLayoutConstraint.activate([
            latlngzLabel.topAnchor.constraint(equalTo: topAnchor),
            latlngzLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            latlngzLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            latlngzLabel.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }
    public func set(diff: CFAbsoluteTime) {
        let diff = String(format: "%.7f", diff)
        latlngzLabel.text = "Diff: \(diff)"
    }
}

