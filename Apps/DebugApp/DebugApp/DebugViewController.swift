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
        let selectedAnnotationIds = annotations.map(\.id)
        var allAnnotations = circleAnnotationManager.annotations.map { annotation in
            var mutableAnnotation = annotation
            if selectedAnnotationIds.contains(annotation.id) {
                mutableAnnotation.circleStrokeColor = .init(UIColor.red)
                mutableAnnotation.circleStrokeWidth = 2
            } else {
                mutableAnnotation.circleStrokeColor = nil
                mutableAnnotation.circleStrokeWidth = nil
            }
            return mutableAnnotation
        }

        circleAnnotationManager.annotations = allAnnotations
    }


    var mapView: MapView!
//    var annotations = [CircleAnnotation]()
    var circleAnnotationManager: CircleAnnotationManager!
//    var selectedAnnotation: [String] = []
//    var draggedAnnotation: [String] = []
//    var previousAnnotation: CircleAnnotation?
    var annotationBeingDragged: CircleAnnotation?
//    var updatedPoint: Point!
//    var originPoint: Point!
//    var previouslyDraggedAnnotation: CircleAnnotation?


    override func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 39.7128, longitude: -75.0060)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 2))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectAnnotation)))
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

        //**** Create/add drag source after the circke annotation manager ****
        var dragSource = GeoJSONSource()
        dragSource.data = .empty
        // Change this to updating the source instead
        try? mapView.mapboxMap.style.addSource(dragSource, id: "dragSource")

        //**** Create/add drag layer after creating annotation manager ****
        let dragLayerId = "drag-layer"
        var dragLayer = CircleLayer(id: "drag-layer")
        dragLayer = CircleLayer(id: dragLayerId)
        dragLayer.source = "dragSource"
        dragLayer.circleColor = .constant(StyleColor(.systemOrange))
        dragLayer.circleRadius = .constant(12)
        try? mapView.mapboxMap.style.addLayer(dragLayer)

        var annotations: [CircleAnnotation] = []
        for _ in 0...100 {
            var annotation = CircleAnnotation(centerCoordinate: .init(latitude: .random(in: -90...90), longitude: .random(in: -180...180)))
            annotation.circleColor = StyleColor(UIColor.random)
            annotation.circleRadius = 120
            annotation.isDraggable = true
            annotations.append(annotation)
        }

        circleAnnotationManager.annotations = annotations
    }

    @objc func dragAnnotation(_ sender: UILongPressGestureRecognizer) {
        let position = sender.location(in: mapView)

        switch sender.state {
        case .began:
            mapView?.mapboxMap.queryRenderedFeatures(
                with: position,
                options: RenderedQueryOptions(layerIds: [circleAnnotationManager.layerId], filter: nil)) { [weak self] result in
                    switch result {
                    case .success(let queriedfeatures):
                        if let firstFeature = queriedfeatures.first?.feature,
                           case let .string(annotationId) = firstFeature.identifier {
                            guard let annotation = self?.circleAnnotationManager.annotations.filter({$0.id == annotationId}).first,
                            annotation.isDraggable else {
                                return
                            }

                            try? self?.mapView.mapboxMap.style.updateLayer(withId: "drag-layer", type: CircleLayer.self, update: { layer in
                                layer.circleColor = annotation.circleColor.map(Value.constant)
                                layer.circleRadius = annotation.circleRadius.map(Value.constant)
                                layer.circleStrokeWidth = annotation.circleStrokeWidth.map(Value.constant)
                                layer.circleStrokeColor = annotation.circleStrokeColor.map(Value.constant)

                            })
                            print("drag start:  \(annotationId)")
                            self?.annotationBeingDragged = annotation
                            self?.circleAnnotationManager.annotations.removeAll(where: { $0.id == annotation.id })

                            guard let self = self else { return }
                            let updatedPoint = Point(self.mapView.mapboxMap.coordinate(for: position))
                            self.annotationBeingDragged?.point = updatedPoint
                            try? self.mapView.mapboxMap.style.updateGeoJSONSource(withId: "dragSource", geoJSON: updatedPoint.geometry.geoJSONObject)

                        }
                    case .failure(let error):
                        break
                    }
                }
        case .changed:
            guard let annotationBeingDragged = annotationBeingDragged else { return }

            let updatedPoint = Point(mapView.mapboxMap.coordinate(for: position))
            self.annotationBeingDragged?.point = updatedPoint
            print("drag update:  \(annotationBeingDragged.id)")
            try? mapView.mapboxMap.style.updateGeoJSONSource(withId: "dragSource", geoJSON: updatedPoint.geometry.geoJSONObject)
        case .ended, .cancelled:
            guard let annotationBeingDragged = annotationBeingDragged else { return }
            print("drag end:  \(annotationBeingDragged.id)")
            self.circleAnnotationManager.annotations.append(annotationBeingDragged)
            self.annotationBeingDragged = nil
        case .possible, .failed:
            break
        @unknown default:
            break
        }
    }

    @objc func selectAnnotation(_ sender: UITapGestureRecognizer) {
//        print("selected:", selectedAnnotation.count)
        // when i tap (selecAnnotation) on a dragged annotation, it returns to its previous coordinates
        // when I select the annotation it goes back to its original position
//        print("------------------ \n original: \(self.previousAnnotation?.id)")

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
//        let layerIds = [circleAnnotationManager.layerId]
//        let tapPoint = sender.location(in: mapView)
//
//        if self.selectedAnnotation.count == 0 {
//            // proceed as usual
//        } else if self.selectedAnnotation.count == 1 {
//            self.selectedAnnotation = []
//        }
//        mapView?.mapboxMap.queryRenderedFeatures(
//            with: tapPoint,
//            options: RenderedQueryOptions(layerIds: layerIds, filter: nil)) { [weak self] result in
//                switch result {
//                case .success(let queriedfeatures):
//                    if let firstFeature = queriedfeatures.first?.feature,
//                       case let .string(annotationId) = firstFeature.identifier {
//                        print("currently selected annotation:  \(annotationId)")
//                        let annotation = self?.circleAnnotationManager.annotations.filter {$0.id == annotationId}.first
//                        //Store current annotation as previous annotation so you can reference the proper color to switch back to when the icon is deselected
//                        guard var annotation = annotation else { return }
//                        self?.selectedAnnotation.append(annotation.id)
////                        self?.previousAnnotation = annotation
//
//                        // set annotation selected property and change color to reflect selection
//                        annotation.isSelected = true
//                        annotation.circleColor = StyleColor(UIColor(ciColor: .black))
//
//                        // remove annotation from circle annotation layer and re-add annotations
////                        self?.circleAnnotationManager.annotations.removeAll { $0.point == self?.previousAnnotation?.point }
//
//                        self?.circleAnnotationManager.annotations.append(annotation)
//
//
//                    }
//                case .failure(let error):
//                    print("An error occurred: \(error.localizedDescription)")
//                }
//            }
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
