import UIKit
import MapboxMaps

@objc(VoiceOverAccessibilityExample)
public class VoiceOverAccessibilityExample: UIViewController, ExampleProtocol {

    var mapView: MapView!
    var pointAnnotation: PointAnnotation?
    var pointAnnotationManager: PointAnnotationManager?
    var pointAnnotationView: UIView! = nil
    var pointAnnotationViews = [UIView]()
    var i = 0

    let coordinates = [
        CLLocationCoordinate2D(latitude: 35.67514743608467, longitude: -86.220703125),
        CLLocationCoordinate2D(latitude: 33.65120829920497, longitude: -80.771484375),
        CLLocationCoordinate2D(latitude: 37.43997405227057, longitude: -78.662109375)
    ]

    let annotationProperties = [
        ["Name": "Alabama"],
        ["Name" : "South Carolina"],
        ["Name" : "Virginia"]
    ]

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Set the center coordinate and zoom level.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 33.65120829920497, longitude: -80.771484375)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 4), styleURI: .light)

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        // add double tap gesture to map
        self.addDoubleTapGesture(to: self.mapView)

        // Allow the view controller to receive information about map events.
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.addAnnotations()
            self.addAccesibility()
            self.finish()
        }

        mapView.mapboxMap.onEvery(.cameraChanged) { _ in
            if self.pointAnnotationManager!.annotations.isEmpty {
                self.addAnnotations()
                self.addAccesibility()
            } else {
                self.i = 0
                for view in self.pointAnnotationViews {
                    view.removeFromSuperview()
                }
                self.pointAnnotationManager?.annotations = []
                self.mapView.annotations.removeAnnotationManager(withId: "annotation-manager")
            }
        }


        if !UIAccessibility.isVoiceOverRunning {
            let label = UILabel(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y + 100, width: UIScreen.main.bounds.width, height: 50))
            label.backgroundColor = .gray
            label.textColor = .black
            label.text = "Turn on VoiceOver to interact with the mapview annotations."
            label.textAlignment = .center
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 0
            view.addSubview(label)
        }
    }

    public func addDoubleTapGesture(to mapView: MapView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }

    @objc func doubleTapped() {

        if UIAccessibility.isVoiceOverRunning {
            let focusedElement = UIAccessibility.focusedElement(using: UIAccessibility.AssistiveTechnologyIdentifier.notificationVoiceOver)! as! UIView
            let index = focusedElement.tag
            if let image = UIImage(named: "yellow_star") {
                self.pointAnnotationManager!.annotations[index].image = .init(image: image, name: "yellow_star")
                // unable to get voiceover for doubletapped element
                //focusedElement.accessibilityLabel = "You've starred \(self.pointAnnotationManager!.annotations[index].userInfo?.first?.value)"
            }
        }
    }

    private func addAnnotations() {
        pointAnnotationManager =  mapView.annotations.makePointAnnotationManager(id: "annotation-manager", layerPosition: .default)

        for coordinate in coordinates {
            let point = mapView.mapboxMap.point(for: coordinate)
            pointAnnotation = PointAnnotation(id: "annotation" , coordinate: coordinate)
            pointAnnotation?.userInfo = annotationProperties[i]

            if let image = UIImage(named: "custom_marker") {
                pointAnnotation?.image = .init(image: image, name: "custom_marker")
            }

            pointAnnotationManager?.annotations.append(pointAnnotation!)
            pointAnnotationView = UIView(frame: CGRect(x: point.x - 20, y: point.y - 20, width: 40, height: 45))
            pointAnnotationView?.layer.borderColor = UIColor.clear.cgColor
            pointAnnotationView.layer.cornerRadius = 10
            pointAnnotationView.layer.backgroundColor = UIColor.clear.cgColor
            pointAnnotationView.layer.borderWidth = 2
            pointAnnotationView.accessibilityFrame = self.pointAnnotationView.frame
            pointAnnotationView.isAccessibilityElement = true
            pointAnnotationView.accessibilityElements = [pointAnnotation]
            pointAnnotationView.accessibilityLabel = "\(pointAnnotation!.userInfo!.first!.value) selected."

            if i == 0 {
                pointAnnotationView.tag = 0
            } else {
                pointAnnotationView.tag = i
            }
            //pointAnnotationView.accessibilityHint = " Double tap to change the icon color."
            pointAnnotationView.accessibilityTraits = .allowsDirectInteraction

            view.addSubview(pointAnnotationView)
            pointAnnotationViews.append(pointAnnotationView)
            i = i + 1
        }
    }

    private func addAccesibility() {
        let cameraView = mapView.mapboxMap.cameraBounds.bounds.northeast
        let origin = mapView.mapboxMap.point(for: cameraView)
        let mapviewAccessibilityFrame = CGRect(origin: origin, size: CGSize(width: UIScreen.main.bounds.width / 0.8, height: UIScreen.main.bounds.height / 0.9))

        var visibleAnnotationsInView = [PointAnnotation]()
        let cameraOptions = CameraOptions(cameraState: mapView.cameraState)
        for annotation in pointAnnotationManager!.annotations {
            if mapView.mapboxMap.coordinateBounds(for: cameraOptions).contains(forPoint: annotation.point.coordinates, wrappedCoordinates: true) {
                visibleAnnotationsInView.append(annotation)
            }
        }

        mapView.accessibilityFrame = mapviewAccessibilityFrame
        if visibleAnnotationsInView.count > 1 {
            mapView.accessibilityLabel = "Map view selected. There are \(visibleAnnotationsInView.count) visible annotations: \(visibleAnnotationsInView.map {$0.userInfo!.first!.value})."
        } else {
            mapView.accessibilityLabel = "Map view selected. There is \(visibleAnnotationsInView.count) visible annotation: \(visibleAnnotationsInView.first!.userInfo!.first!.value)."
        }
        mapView.isAccessibilityElement = true
        mapView.accessibilityElements = [pointAnnotationViews]

    }
}

