import UIKit
@_implementationOnly import MapboxCommon_Private
@_implementationOnly import MapboxCoreMaps_Private

public class ViewAnnotationManager {

    private weak var view: UIView?

    private let mapViewAnnotationHandler: MapViewAnnotationInterface

    internal init(view: UIView,
                  mapViewAnnotationHandler: MapViewAnnotationInterface) {
        self.view = view
        self.mapViewAnnotationHandler = mapViewAnnotationHandler
        mapViewAnnotationHandler.setViewAnnotationPositionsUpdateListenerFor(listener: self)
    }

    // TODO: Maybe convert to a weak dictionary?
    internal var viewAnnotationsById: [String: ViewAnnotation] = [:]

    public func addViewAnnotation(_ viewAnnotation: ViewAnnotation) {
        guard let view = view else { return }

        mapViewAnnotationHandler.addViewAnnotation(
            forIdentifier: viewAnnotation.id,
            options: viewAnnotation.options)

        viewAnnotationsById[viewAnnotation.id] = viewAnnotation
        viewAnnotation.isHidden = false
        view.addSubview(viewAnnotation)
    }

    public func removeViewAnnotation(_ viewAnnotation: ViewAnnotation) {
        mapViewAnnotationHandler.removeViewAnnotation(
            forIdentifier: viewAnnotation.id)
        viewAnnotation.removeFromSuperview()
        viewAnnotationsById.removeValue(forKey: viewAnnotation.id)
    }

    public func updateViewAnnotation(_ viewAnnotation: ViewAnnotation) {
        mapViewAnnotationHandler.updateViewAnnotation(forIdentifier: viewAnnotation.id, options: viewAnnotation.options)
        viewAnnotationsById[viewAnnotation.id] = viewAnnotation
    }

    internal func placeAnnotations(positions: [ViewAnnotationPositionDescriptor]) {
        var visibleAnnotationIds: Set<String> = []

        for position in positions {
            // Approach:
            // 1. Get the view for this position's identifier
            // 2. Adjust the origin of the view. If the view's center is off screen, then hide the view
            guard let viewAnnotation = self.viewAnnotationsById[position.identifier] else {
                fatalError()
            }
            // TODO: Check if position depends on the device's pixel ratio. (In a previous commit this was divided by two for some reason.)
            viewAnnotation.frame = CGRect(
                origin: position.leftTopCoordinate.point,
                size: viewAnnotation.frame.size)

            viewAnnotation.isHidden = false
            visibleAnnotationIds.insert(position.identifier)
        }

        // Hide annotations that are off screen
        let annotationsToHide = Set<String>(viewAnnotationsById.keys).subtracting(visibleAnnotationIds)
        for id in annotationsToHide {
            self.viewAnnotationsById[id]?.isHidden = true
        }
    }

}

extension ViewAnnotationManager: ViewAnnotationPositionsListener {
    
    public func onViewAnnotationPositionsUpdate(forPositions positions: [ViewAnnotationPositionDescriptor]) {
        placeAnnotations(positions: positions)
    }
    
    
}

// TODO: Add documentation
extension MapboxCoreMaps.ViewAnnotationOptions {
    public convenience init(coordinate: CLLocationCoordinate2D,
                            size: CGSize,
                            associatedFeatureId: String? = nil,
                            height: CGFloat? = nil,
                            allowOverlap: Bool = true,
                            visible: Bool = true,
                            anchor: CGFloat? = nil,
                            offsetX: CGFloat? = nil,
                            offsetY: CGFloat? = nil,
                            selected: Bool = false) {
        self.init(__geometry: MapboxCommon.Geometry(point: coordinate as NSValue),
                   associatedFeatureId: nil,
                   width: size.width as NSNumber,
                   height: size.height as NSNumber,
                   allowOverlap: allowOverlap as NSNumber,
                   visible: visible as NSNumber,
                   anchor: anchor as NSNumber?,
                   offsetX: offsetX as NSNumber?,
                   offsetY: offsetY as NSNumber?,
                   selected: selected as NSNumber)
    }
}

public protocol ViewAnnotation: UIView {
    var id: String { get }
    var options: ViewAnnotationOptions { get }
}
