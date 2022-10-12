import UIKit
import Foundation
import MapboxMaps

/**
 NOTE: This view controller should be used as a scratchpad
 while you develop new features. Changes to this file
 should not be committed.
 */

final class DebugViewController: UIViewController, AnnotationInteractionDelegate {
    func annotationManager(_ manager: MapboxMaps.AnnotationManager, didDetectTappedAnnotations annotations: [MapboxMaps.Annotation]) {
        print("AnnotationManager did detect tapped annotations: \(annotations)")
    }


    var mapView: MapView!
    var annotations = [CircleAnnotation]()
    var circleAnnotationManager: CircleAnnotationManager!
    var selectedAnnotation: [String] = []
    var draggedAnnotation: [String] = []
    var previousAnnotation: CircleAnnotation?
    var annotation: CircleAnnotation?
    var updatedPoint: Point!
    var originPoint: Point!
    var previouslyDraggedAnnotation: CircleAnnotation?


    override func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 39.7128, longitude: -75.0060)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 2))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectAnnotation)))
        mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(dragAnnotation)))
        view.addSubview(mapView)

        mapView.mapboxMap.onNext(event: .mapLoaded) { [weak self] _ in
            self?.addCircles()
        }
    }

    func addCircles() {
        // Create the CircleAnnotationManager
        // Annotation managers are kept alive by `AnnotationOrchestrator`
        // (`mapView.annotations`) until you explicitly destroy them
        // by calling `mapView.annotations.removeAnnotationManager(withId:)`
        circleAnnotationManager = mapView.annotations.makeCircleAnnotationManager()
        circleAnnotationManager.delegate = self


        for _ in 0...100 {
            var annotation = CircleAnnotation(centerCoordinate: .init(latitude: .random(in: -90...90), longitude: .random(in: -180...180)))
            annotation.circleColor = StyleColor(UIColor.random)
            annotation.circleRadius = 12
            annotations.append(annotation)
        }

        circleAnnotationManager.annotations = annotations
    }

    @objc func dragAnnotation(_ sender: UILongPressGestureRecognizer) {


        let dragSourceIdentifier = "dragSource"
        /** The drag layer created by this manager. The dragging annotation will be added to this layer.*/
//        var dragLayer: Layer? = nil
        var dragLayer: CircleLayer? = nil

        //**** Create/add drag source after the circke annotation manager ****
        var dragSource = GeoJSONSource()

        // filter list of annotations by the name of the selected annotation
        annotation = annotations.first(where: {$0.id == selectedAnnotation.last})
        guard var annotation = annotation else { return }
        // update marker position to position of pointer
        originPoint = annotation.point
        var position = sender.location(in: mapView)
        updatedPoint = Point(mapView.mapboxMap.coordinate(for: position))
        previousAnnotation?.point = originPoint
        // need to account for the size of the annotation


        dragSource.data = .feature(Feature(geometry: .point(updatedPoint)))
        // Change this to updating the source instead
        try? mapView.mapboxMap.style.addSource(dragSource, id: dragSourceIdentifier)

        //**** Create/add drag layer after creating annotation manager ****
        let dragLayerId = "drag-layer"
        dragLayer = CircleLayer(id: dragLayerId)
        dragLayer?.source = dragSourceIdentifier
        dragLayer?.circleColor = .constant(annotation.circleColor!)
        dragLayer?.circleRadius = .constant(annotation.circleRadius!)
        guard let dragLayer = dragLayer else { return }
        try? mapView.mapboxMap.style.addLayer(dragLayer)

        if sender.state == .began {
//            self.circleAnnotationManager.annotations.append(previouslyDraggedAnnotation!)
//            // remove all annotations matching the id of the annotation you selected
//            self.circleAnnotationManager.annotations.removeAll {$0.point == previousAnnotation?.point}


//            if previouslyDraggedAnnotation == nil {
//
//            } else {
//
//                if self.previouslyDraggedAnnotation?.id == selectedAnnotation.first {
//                    print("annotations are the same")
//
//
//                } else {
//                    print("annotations not the same.")
//                    self.circleAnnotationManager.annotations.removeAll {$0.point == previousAnnotation?.point}
//                }
//            }
//
//            self.circleAnnotationManager.syncSourceAndLayerIfNeeded()
        }

        if sender.state == .changed {
            if mapView.mapboxMap.style.layerExists(withId: dragLayerId) {
                try? mapView.mapboxMap.style.updateGeoJSONSource(withId: dragSourceIdentifier, geoJSON: .feature(Feature(geometry: .point(updatedPoint))))
            }
        }

        // look at rotate gesture handler to switch on the state (begin/chenge/end)
        if sender.state == .ended {

//            previouslyDraggedAnnotation = annotation
            annotation.isDraggable = true
            annotation.isSelected = false
            guard var previousAnnotation = previousAnnotation else { return }
            self.circleAnnotationManager.annotations.removeAll(where: {$0.id == annotation.id })
            self.circleAnnotationManager.annotations.append(annotation)
//            if annotation.isDraggable == true {
//                self.circleAnnotationManager.annotations.removeAll(where: {$0. == previousAnnotation. })
////                self.circleAnnotationManager.annotations.append(previousAnnotation)
//            }
        }

    }

    // From SymbolClusteringExample
    func createDragLayer() -> CircleLayer {
        // Create a circle layer to represent the points that aren't clustered.
        var dragLayer = CircleLayer(id: "drag-layer")

        let selectedAnnotationId = selectedAnnotation.first
        guard let selectedAnnotationId = selectedAnnotationId else { return CircleLayer(id: "")}
        // Filter out features we're not dragging by checking for `point_count`.
        dragLayer.filter = Exp(.has) {selectedAnnotationId}

        // change color of annotation when being dragged
        dragLayer.circleColor = .constant(.init(.red))

        return dragLayer
    }

    @objc func selectAnnotation(_ sender: UITapGestureRecognizer) {
        print("selected:", selectedAnnotation.count)
        // when i tap (selecAnnotation) on a dragged annotation, it returns to its previous coordinates
        // when I select the annotation it goes back to its original position
        print("------------------ \n original: \(self.previousAnnotation?.id)")

//        if previousAnnotation == nil {
//
//        } else {
//            // determine if the annotation you selected was the same one you justdragged
//            if self.previousAnnotation?.id == annotation?.id {
//                print("eh")
//                // kinda works?
////                self.circleAnnotationManager.annotations.removeAll { $0.point == self.annotation?.point }
////                previousAnnotation = annotation
//
//            }
//        }
//
//        if previousAnnotation == nil {
//            // do nothing
//        } else if previousAnnotation?.isDraggable == false {
//        guard var previousAnnotation = previousAnnotation else { return }
//            self.circleAnnotationManager.annotations.append(previousAnnotation)
//        }



//        self.circleAnnotationManager.annotations.removeAll { $0.point == self.annotation?.point }
//        previousAnnotation?.isDraggable = false

        // if the id of the feature you just tapped matches a feature in the annotation array then highlight that annotation
        let layerIds = [circleAnnotationManager.layerId]
        let tapPoint = sender.location(in: mapView)

        if self.selectedAnnotation.count == 0 {
            // proceed as usual
        } else if self.selectedAnnotation.count == 1 {
            self.selectedAnnotation = []
        }
        mapView?.mapboxMap.queryRenderedFeatures(
            with: tapPoint,
            options: RenderedQueryOptions(layerIds: layerIds, filter: nil)) { [weak self] result in
                switch result {
                case .success(let queriedfeatures):
                    if let firstFeature = queriedfeatures.first?.feature,
                       case let .string(annotationId) = firstFeature.identifier {
                        print("currently selected annotation:  \(annotationId)")
                        let annotation = self?.annotations.filter {$0.id == annotationId}.first
                        //Store current annotation as previous annotation so you can reference the proper color to switch back to when the icon is deselected
                        guard var annotation = annotation else { return }
                        self?.selectedAnnotation.append(annotation.id)
                        self?.previousAnnotation = annotation

                        // set annotation selected property and change color to reflect selection
                        annotation.isSelected = true
                        annotation.circleColor = StyleColor(UIColor(ciColor: .black))

                        // remove annotation from circle annotation layer and re-add annotations
                        self?.circleAnnotationManager.annotations.removeAll { $0.point == self?.previousAnnotation?.point }

                        self?.circleAnnotationManager.annotations.append(annotation)


                    }
                case .failure(let error):
                    print("An error occurred: \(error.localizedDescription)")
                }
            }
    }
}

extension UIColor {
    static var random: UIColor {
        let r:CGFloat  = .random(in: 0...1)
        let g:CGFloat  = .random(in: 0...1)
        let b:CGFloat  = .random(in: 0...1)
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}
