import UIKit
@_spi(Experimental) import MapboxMaps

// MARK: - Draggable View Annotations Example

/// Shows how to make view annotations draggable: set `ViewAnnotation.isDraggable`,
/// observe `onDragCoordinateChanged`/`onDraggingChanged`, and use the updated
/// coordinates to edit map geometry (a polygon or polyline) as the user drags.
///
/// UIKit analog for the SwiftUI ``DraggableViewAnnotationsExample``.
final class DraggableViewAnnotationExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    // Polygon
    private var polygonManager: PolygonAnnotationManager?
    private var polygonVertices = DraggableViewAnnotationData.polygon

    // Polyline
    private var polylineManager: PolylineAnnotationManager?
    private var polylineVertices = DraggableViewAnnotationData.polyline

    override func viewDidLoad() {
        super.viewDidLoad()

        let options = MapInitOptions(cameraOptions: DraggableViewAnnotationData.cameraOptions, styleURI: .outdoors)
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            guard let self else { return }
            self.addViewAnnotation()
            self.addEditablePolygon()
            self.addEditablePolyline()
            self.finish()
        }.store(in: &cancelables)
    }

    // MARK: View Annotation

    private func addViewAnnotation() {
        let pinView = CustomPinView()
        let annotation = ViewAnnotation(coordinate: DraggableViewAnnotationData.point, view: pinView)
        annotation.isDraggable = true
        annotation.onDraggingChanged = { [weak pinView] isDragging in
            pinView?.setDragging(isDragging)
        }
        annotation.allowOverlap = true
        annotation.variableAnchors = [ViewAnnotationAnchorConfig(anchor: .bottom)]
        mapView.viewAnnotations.add(annotation)
    }

    // MARK: Edit Polygon

    private func addEditablePolygon() {
        polygonManager = mapView.annotations.makePolygonAnnotationManager()
        updatePolygon()

        for (index, vertex) in polygonVertices.enumerated() {
            let circleView = CustomCircleView(color: .systemGreen)
            let annotation = ViewAnnotation(coordinate: vertex.coordinate, view: circleView)
            annotation.isDraggable = true
            annotation.onDraggingChanged = { [weak circleView] isDragging in
                circleView?.setDragging(isDragging)
            }
            annotation.onDragCoordinateChanged = { [weak self] newCoordinate in
                self?.polygonVertices[index].coordinate = newCoordinate
                self?.updatePolygon()
            }
            annotation.allowOverlap = true
            mapView.viewAnnotations.add(annotation)
        }
    }

    private func updatePolygon() {
        guard let polygonManager else { return }
        var ring = polygonVertices.map(\.coordinate)
        if let first = ring.first {
            ring.append(first)
        }
        var annotation = PolygonAnnotation(polygon: Polygon([ring]))
        annotation.fillColor = StyleColor(.systemGreen)
        annotation.fillOpacity = 0.4
        polygonManager.annotations = [annotation]
    }

    // MARK: Edit Polyline

    private func addEditablePolyline() {
        polylineManager = mapView.annotations.makePolylineAnnotationManager()
        updatePolyline()

        for (index, vertex) in polylineVertices.enumerated() {
            let circleView = CustomCircleView(color: .systemIndigo)
            let annotation = ViewAnnotation(coordinate: vertex.coordinate, view: circleView)
            annotation.isDraggable = true
            annotation.onDraggingChanged = { [weak circleView] isDragging in
                circleView?.setDragging(isDragging)
            }
            annotation.onDragCoordinateChanged = { [weak self] newCoordinate in
                self?.polylineVertices[index].coordinate = newCoordinate
                self?.updatePolyline()
            }
            annotation.allowOverlap = true
            mapView.viewAnnotations.add(annotation)
        }
    }

    private func updatePolyline() {
        guard let polylineManager else { return }
        var annotation = PolylineAnnotation(lineCoordinates: polylineVertices.map(\.coordinate))
        annotation.lineColor = StyleColor(.systemIndigo)
        annotation.lineWidth = 4
        polylineManager.annotations = [annotation]
    }
}

// MARK: - Helper Views

private final class CustomPinView: UIView {
    private let imageView = UIImageView(image: UIImage(named: "dest-pin"))

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 40, height: 52))
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        CGSize(width: 40, height: 52)
    }

    func setDragging(_ isDragging: Bool) {
        animateSpring {
            self.imageView.transform = isDragging ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
        }
    }
}

private final class CustomCircleView: UIView {
    private let circleView: UIView

    init(color: UIColor) {
        circleView = UIView(frame: CGRect(x: 11, y: 11, width: 22, height: 22))
        super.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        circleView.backgroundColor = .white
        circleView.layer.cornerRadius = 11
        circleView.layer.borderWidth = 2
        circleView.layer.borderColor = color.cgColor
        addSubview(circleView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        CGSize(width: 44, height: 44)
    }

    func setDragging(_ isDragging: Bool) {
        let size: CGFloat = isDragging ? 30 : 22
        animateSpring {
            self.circleView.bounds.size = CGSize(width: size, height: size)
            self.circleView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            self.circleView.layer.cornerRadius = size / 2
        }
    }
}

// UIKit analog of SwiftUI's `.animation(.interactiveSpring(), value: isDragging)`.
private func animateSpring(_ animations: @escaping () -> Void) {
    UIView.animate(
        withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.86, initialSpringVelocity: 0,
        options: [.allowUserInteraction], animations: animations)
}
