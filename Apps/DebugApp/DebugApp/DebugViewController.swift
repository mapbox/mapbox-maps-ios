import UIKit
import MapboxMaps
import Turf

/**
 NOTE: This view controller should be used as a scratchpad
 while you develop new features. Changes to this file
 should not be committed.
 */

public class DebugViewController: UIViewController {

    internal var mapView: MapView!
    internal var circleAnnotationManager: CircleAnnotationManager?
    internal var lineAnnotationManager: PolylineAnnotationManager?
    internal var pointAnnotationManager: PointAnnotationManager?
    internal var polygonAnnotationManager: PolygonAnnotationManager?
    internal var runningAnimator: CameraAnimator?

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Deliberately set nil style
        mapView = MapView(frame: view.bounds, mapInitOptions: MapInitOptions(styleURI: nil))
        mapView.location.options.puckType = .puck2D()

        view.addSubview(mapView)

        // Convenience that takes a closure that's called when the style
        // is loaded or fails to load.
        //
        // Handling load callbacks is ALSO demonstrated below using the separate `onNext` & `onEvery`
        // callbacks
        mapView.mapboxMap.loadStyleURI(.streets) { result in
            switch result {
            case .success:
                print("The map has finished loading style")
            case let .failure(error):
                print("The map failed to load the style: \(error)")
            }
        }

        /**
         The closure is called when style data has been loaded. This is called
         multiple times. Use the event data to determine what kind of style data
         has been loaded.
         
         When the type is `style` this event most closely matches
         `-[MGLMapViewDelegate mapView:didFinishLoadingStyle:]` in SDK versions
         prior to v10.
         */
        mapView.mapboxMap.onEvery(.styleDataLoaded) { event in
            guard let data = event.data as? [String: Any],
                  let type = data["type"] else {
                return
            }

            print("The map has finished loading style data of type = \(type)")
        }

        /**
         The closure is called during the initialization of the map view and
         after any `styleDataLoaded` events; it is called when the requested
         style has been fully loaded, including the style, specified sprite and
         source metadata.

         This event is the last opportunity to modify the layout or appearance
         of the current style before the map view is displayed to the user.
         Adding a layer at this time to the map may result in the layer being
         presented BEFORE the rest of the map has finished rendering.

         Changes to sources or layers of the current style do not cause this
         event to be emitted.
         */
        mapView.mapboxMap.onNext(.styleLoaded) { (event) in
            print("The map has finished loading style ... Event = \(event)")
        }

        /**
         The closure is called whenever the map finishes loading and the map has
         rendered all visible tiles, either after the initial load OR after a
         style change has forced a reload.

         This is an ideal time to add any runtime styling or annotations to the
         map and ensures that these layers would only be shown after the map has
         been fully rendered.
         */
        mapView.mapboxMap.onNext(.mapLoaded) { (event) in
            print("The map has finished loading... Event = \(event)")
            
            self.pointAnnotationManager = self.mapView.annotations.makePointAnnotationManager()
            var p1 = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            p1.image = PointAnnotation.NamedImage(image: UIImage(named: "star")!, name: "star")
            
            var p2 = PointAnnotation(point: .init(.init(latitude: 10, longitude: 10)))
            p2.image = PointAnnotation.NamedImage(image: UIImage(named: "star")!, name: "star")
            
            var p3 = PointAnnotation(point: .init(.init(latitude: -10, longitude: -10)))
            p3.image = PointAnnotation.NamedImage(image: UIImage(named: "star")!, name: "star")
            
            var p4 = PointAnnotation(point: .init(.init(latitude: -10, longitude: 0)))
            p4.image = PointAnnotation.NamedImage(image: UIImage(named: "triangle")!, name: "triangle")
            
            self.pointAnnotationManager?.annotations = [p1, p2, p3, p4]
            
//            self.circleAnnotationManager = self.mapView.annotations.makeCircleAnnotationManager()
//            self.circleAnnotationManager?.delegate = self
//
//            var circleAnnotation1 = CircleAnnotation(id: "my-first-annotation", point: .init(.init(latitude: 0, longitude: 0)))
//            circleAnnotation1.circleRadius = 30
//            circleAnnotation1.circleOpacity = 1.0
//            circleAnnotation1.circleColor = .init(color: .clear)
//            circleAnnotation1.circleStrokeWidth = 3.0
//            circleAnnotation1.circleStrokeColor = .init(color: .purple)
//
//            var circleAnnotation2 = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
//            circleAnnotation2.circleRadius = 10
//            circleAnnotation2.circleOpacity = 1.0
//            circleAnnotation2.circleColor = .init(color: .blue)
//            circleAnnotation2.circleStrokeWidth = 3.0
//            circleAnnotation2.circleStrokeColor = .init(color: .yellow)
//
//            var circleAnnotation3 = CircleAnnotation(point: .init(.init(latitude: -10, longitude: -10)))
//            circleAnnotation3.circleRadius = 10
//            circleAnnotation3.circleOpacity = 1.0
//            circleAnnotation3.circleColor = .init(color: .green)
//            circleAnnotation3.circleStrokeWidth = 19.0
//            circleAnnotation3.circleStrokeColor = .init(color: .white)
//
//            self.circleAnnotationManager?.annotations = [circleAnnotation1, circleAnnotation2, circleAnnotation3]
//
//            let lineCoordinates = [
//                CLLocationCoordinate2DMake(0, 0),
//                CLLocationCoordinate2DMake(10, 10)
//            ]
//
//            self.lineAnnotationManager = self.mapView.annotations.makePolylineAnnotationManager()
//            self.lineAnnotationManager?.delegate = self
//            var lineAnnotation1 = PolylineAnnotation(line: .init(lineCoordinates))
//            lineAnnotation1.lineColor = .init(color: .red)
//            lineAnnotation1.lineWidth = 50.0
//            lineAnnotation1.lineOpacity = 1.0
//
//            var lineAnnotation2 = PolylineAnnotation(line: .init([.init(latitude: 0, longitude: 0), .init(latitude: -20, longitude: -20)]))
//            lineAnnotation2.lineColor = .init(color: .blue)
//            lineAnnotation2.lineWidth = 10.0
//            lineAnnotation2.lineOpacity = 0.5
//
//            var lineAnnotation3 = PolylineAnnotation(line: .init([.init(latitude: 0, longitude: 0), .init(latitude: 55, longitude: 55)]))
//            lineAnnotation3.lineColor = .init(color: .orange)
//            lineAnnotation3.lineWidth = 3
//            lineAnnotation3.lineOpacity = 1.0
//            lineAnnotation3.lineBlur = 2
//
//            self.lineAnnotationManager?.annotations = [lineAnnotation1, lineAnnotation2, lineAnnotation3]
//
//            lineAnnotation1.lineColor = .init(color: .yellow)
//            lineAnnotation1.lineWidth = 30
//            self.lineAnnotationManager?.annotations.append(lineAnnotation1)
            
        }

        /**
         The closure is called whenever the map has failed to load. This could
         be because of a variety of reasons, including a network connection
         failure or a failure to fetch the style from the server.

         You can use the associated error message to notify the user that map
         data is unavailable.
         */
        mapView.mapboxMap.onNext(.mapLoadingError) { (event) in
            guard let data = event.data as? [String: Any],
                  let type = data["type"],
                  let message = data["message"] else {
                return
            }

            print("The map failed to load.. \(type) = \(message)")
        }
    }
    
    public func addLineAnnotation() {
        lineAnnotationManager = mapView.annotations.makePolylineAnnotationManager()
        lineAnnotationManager?.delegate = self
        let lineString = LineString([
            CLLocationCoordinate2D(latitude: 0, longitude: 0),
            CLLocationCoordinate2D(latitude: 10, longitude: 10)
        ])
        var a1 = PolylineAnnotation(line: lineString)
        a1.lineColor = ColorRepresentable(color: .red)
        a1.lineWidth = 10
        lineAnnotationManager?.annotations = [a1]

//        var lineSource = GeoJSONSource()
//        lineSource.data = .feature(.init(lineString))
//        try! mapView.mapboxMap.style.addSource(lineSource, id: "my-line-source")
//
//        var lineLayer = LineLayer(id: "my-line-id")
//        lineLayer.lineColor = .constant(.init(color: .red))
//        lineLayer.source = "my-line-source"
//        try! mapView.mapboxMap.style.addLayer(lineLayer)
//
        
    }
    
    func addPolygonAnnotation() {
        
    }
    
}


extension DebugViewController: CircleAnnotationInteractionDelegate {
    public func annotationsTapped(forManager manager: CircleAnnotationManager, annotations: [CircleAnnotation]) {
        print("***** Detected tap on annotations: \(annotations.map(\.id))")
    }
}

extension DebugViewController: PolylineAnnotationInteractionDelegate {
    public func annotationsTapped(forManager manager: PolylineAnnotationManager, annotations: [PolylineAnnotation]) {
        print("***** Detected tap on annotations: \(annotations.map(\.id))")
    }
}
