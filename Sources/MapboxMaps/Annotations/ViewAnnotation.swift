import UIKit
@_implementationOnly import MapboxCommon_Private
@_implementationOnly import MapboxCoreMaps_Private

public protocol MapViewAnnotationInterface: AnyObject {

    // TODO: Add documentation
    func setViewAnnotationPositionsUpdateListenerFor(listener: ViewAnnotationPositionsListener)

    /**
     * Add view annotation.
     *
     * @return position for all views that need to be updated on the screen or null if views' placement remained the same.
     */
    func addViewAnnotation(forIdentifier identifier: String, options: ViewAnnotationOptions)

    /**
     * Update view annotation if it exists.
     *
     * @return position for all views that need to be updated on the screen or null if views' placement remained the same.
     */
    func updateViewAnnotation(forIdentifier identifier: String, options: ViewAnnotationOptions)

    /**
     * Remove view annotation if it exists.
     *
     * @return position for all views that need to be updated on the screen or null if views' placement remained the same.
     */
    func removeViewAnnotation(forIdentifier identifier: String)
    
    // TODO: Add documentation
    func getViewAnnotationOptions(forIdentifier identifier: String) -> Result<ViewAnnotationOptions, Error>
}

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

    public func addViewAnnotation(_ annotatonView: UIView, _ options: ViewAnnotationOptions) -> ViewAnnotation {
        guard let view = view else { fatalError() }

        let viewAnnotation = ViewAnnotation(view: annotatonView, options: options)
        mapViewAnnotationHandler.addViewAnnotation(
            forIdentifier: viewAnnotation.id,
            options: options)
        viewAnnotationsById[viewAnnotation.id] = viewAnnotation
        viewAnnotation.view.isHidden = false
        view.addSubview(viewAnnotation.view)
        return viewAnnotation
    }

    public func removeViewAnnotation(_ viewAnnotation: ViewAnnotation) {
        mapViewAnnotationHandler.removeViewAnnotation(
            forIdentifier: viewAnnotation.id)
        viewAnnotation.view.removeFromSuperview()
        viewAnnotationsById.removeValue(forKey: viewAnnotation.id)
    }

    public func updateViewAnnotation(_ viewAnnotation: ViewAnnotation, _ options: ViewAnnotationOptions) -> ViewAnnotation {
        var viewAnnotation = viewAnnotation
        mapViewAnnotationHandler.updateViewAnnotation(forIdentifier: viewAnnotation.id, options: options)
        // TODO: error handling
        if case let .success(options) = mapViewAnnotationHandler.getViewAnnotationOptions(forIdentifier: viewAnnotation.id) {
            viewAnnotation.updateOptions(newOptions: options)
            viewAnnotationsById[viewAnnotation.id] = viewAnnotation
        }
        return viewAnnotation
    }
    
    public func getViewAnnotation(forFeatureIdentifier identifier: String) -> ViewAnnotation? {
        return viewAnnotationsById.values.first(where: { viewAnnotation in
            viewAnnotation.options.associatedFeatureId == identifier
        })
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
            viewAnnotation.view.frame = CGRect(
                origin: position.leftTopCoordinate.point,
                size: CGSize(width: viewAnnotation.options.width?.CGFloat ?? 0.0, height: viewAnnotation.options.height?.CGFloat ?? 0.0))

            viewAnnotation.view.isHidden = false
            visibleAnnotationIds.insert(position.identifier)
        }

        // Hide annotations that are off screen
        let annotationsToHide = Set<String>(viewAnnotationsById.keys).subtracting(visibleAnnotationIds)
        for id in annotationsToHide {
            self.viewAnnotationsById[id]?.view.isHidden = true
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
    public convenience init(coordinate: CLLocationCoordinate2D? = nil,
                            width: CGFloat? = nil,
                            height: CGFloat? = nil,
                            associatedFeatureId: String? = nil,
                            allowOverlap: Bool? = nil,
                            visible: Bool? = true,
                            anchor: ViewAnnotationAnchor? = nil,
                            offsetX: CGFloat? = nil,
                            offsetY: CGFloat? = nil,
                            selected: Bool? = nil) {
        self.init(__geometry: coordinate != nil ? MapboxCommon.Geometry(point: coordinate! as NSValue) : nil,
                   associatedFeatureId: nil,
                   width: width as NSNumber?,
                   height: height as NSNumber?,
                   allowOverlap: allowOverlap as NSNumber?,
                   visible: visible as NSNumber?,
                   anchor: anchor?.rawValue as NSNumber?,
                   offsetX: offsetX as NSNumber?,
                   offsetY: offsetY as NSNumber?,
                   selected: selected as NSNumber?)
    }
}

public struct ViewAnnotation {
    public var view: UIView
    public let id: String = UUID().uuidString
    public private(set) var options: ViewAnnotationOptions
    
    fileprivate mutating func updateOptions(newOptions: ViewAnnotationOptions) {
        options = newOptions
    }
}
