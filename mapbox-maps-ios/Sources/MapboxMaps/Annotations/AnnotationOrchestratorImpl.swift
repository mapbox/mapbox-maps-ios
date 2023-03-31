import Foundation
import UIKit
@_implementationOnly import MapboxCommon_Private

internal protocol AnnotationOrchestratorImplProtocol: AnyObject {
    var annotationManagersById: [String: AnnotationManager] { get }
    func makePointAnnotationManager(id: String,
                                    layerPosition: LayerPosition?,
                                    clusterOptions: ClusterOptions?) -> AnnotationManagerInternal
    func makePolygonAnnotationManager(id: String, layerPosition: LayerPosition?) -> AnnotationManagerInternal
    func makePolylineAnnotationManager(id: String, layerPosition: LayerPosition?) -> AnnotationManagerInternal
    func makeCircleAnnotationManager(id: String, layerPosition: LayerPosition?) -> AnnotationManagerInternal
    func removeAnnotationManager(withId id: String)
}

internal final class AnnotationOrchestratorImpl: NSObject, AnnotationOrchestratorImplProtocol {

    private let tapGestureRecognizer: UIGestureRecognizer

    private let longPressGestureRecognizer: MapboxLongPressGestureRecognizer

    private let mapFeatureQueryable: MapFeatureQueryable

    private let factory: AnnotationManagerFactoryProtocol

    internal init(tapGestureRecognizer: UIGestureRecognizer,
                  longPressGestureRecognizer: MapboxLongPressGestureRecognizer,
                  mapFeatureQueryable: MapFeatureQueryable,
                  factory: AnnotationManagerFactoryProtocol) {
        self.tapGestureRecognizer = tapGestureRecognizer
        self.longPressGestureRecognizer = longPressGestureRecognizer
        self.mapFeatureQueryable = mapFeatureQueryable
        self.factory = factory
        super.init()
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap(_:)))
        longPressGestureRecognizer.addTarget(self, action: #selector(handleDrag(_:)))
        longPressGestureRecognizer.delegate = self
        tapGestureRecognizer.delegate = self
        longPressGestureRecognizer.isEnabled = false
        tapGestureRecognizer.isEnabled = false
    }

    /// Dictionary of annotation managers keyed by their identifiers.
    internal var annotationManagersById: [String: AnnotationManager] {
        annotationManagersByIdInternal
    }

    private var annotationManagersByIdInternal = [String: AnnotationManagerInternal]() {
        didSet {
            longPressGestureRecognizer.isEnabled = !annotationManagersByIdInternal.isEmpty
            tapGestureRecognizer.isEnabled = !annotationManagersByIdInternal.isEmpty
        }
    }

    /// Creates a `PointAnnotationManager` which is used to manage a collection of
    /// `PointAnnotation`s. Annotations persist across style changes. If an annotation manager with
    /// the same `id` has already been created, the old one will be removed as if
    /// `removeAnnotationManager(withId:)` had been called. `AnnotationOrchestrator`
    ///  keeps a strong reference to any `PointAnnotationManager` until it is removed.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager.
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    ///   - clusterOptions: Optionally set the `ClusterOptions` to cluster the Point Annotations
    /// - Returns: An instance of `PointAnnotationManager`
    internal func makePointAnnotationManager(id: String,
                                             layerPosition: LayerPosition?,
                                             clusterOptions: ClusterOptions?) -> AnnotationManagerInternal {
        removeAnnotationManager(withId: id, warnIfRemoved: true, function: #function)
        let annotationManager = factory.makePointAnnotationManager(
            id: id,
            layerPosition: layerPosition,
            clusterOptions: clusterOptions)
        annotationManagersByIdInternal[id] = annotationManager
        return annotationManager
    }

    /// Creates a `PolygonAnnotationManager` which is used to manage a collection of
    /// `PolygonAnnotation`s. Annotations persist across style changes. If an annotation manager with
    /// the same `id` has already been created, the old one will be removed as if
    /// `removeAnnotationManager(withId:)` had been called. `AnnotationOrchestrator`
    ///  keeps a strong reference to any `PolygonAnnotationManager` until it is removed.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager..
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    /// - Returns: An instance of `PolygonAnnotationManager`
    internal func makePolygonAnnotationManager(id: String, layerPosition: LayerPosition?) -> AnnotationManagerInternal {
        removeAnnotationManager(withId: id, warnIfRemoved: true, function: #function)
        let annotationManager = factory.makePolygonAnnotationManager(
            id: id,
            layerPosition: layerPosition)
        annotationManagersByIdInternal[id] = annotationManager

        return annotationManager
    }

    /// Creates a `PolylineAnnotationManager` which is used to manage a collection of
    /// `PolylineAnnotation`s. Annotations persist across style changes. If an annotation manager with
    /// the same `id` has already been created, the old one will be removed as if
    /// `removeAnnotationManager(withId:)` had been called. `AnnotationOrchestrator`
    ///  keeps a strong reference to any `PolylineAnnotationManager` until it is removed.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager.
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    /// - Returns: An instance of `PolylineAnnotationManager`
    internal func makePolylineAnnotationManager(id: String, layerPosition: LayerPosition?) -> AnnotationManagerInternal {
        removeAnnotationManager(withId: id, warnIfRemoved: true, function: #function)
        let annotationManager = factory.makePolylineAnnotationManager(
            id: id,
            layerPosition: layerPosition)
        annotationManagersByIdInternal[id] = annotationManager
        return annotationManager
    }

    /// Creates a `CircleAnnotationManager` which is used to manage a collection of
    /// `CircleAnnotation`s. Annotations persist across style changes. If an annotation manager with
    /// the same `id` has already been created, the old one will be removed as if
    /// `removeAnnotationManager(withId:)` had been called. `AnnotationOrchestrator`
    ///  keeps a strong reference to any `CircleAnnotationManager` until it is removed.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager.
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    /// - Returns: An instance of `CircleAnnotationManager`
    internal func makeCircleAnnotationManager(id: String, layerPosition: LayerPosition?) -> AnnotationManagerInternal {
        removeAnnotationManager(withId: id, warnIfRemoved: true, function: #function)
        let annotationManager = factory.makeCircleAnnotationManager(
            id: id,
            layerPosition: layerPosition)
        annotationManagersByIdInternal[id] = annotationManager
        return annotationManager
    }

    /// Removes an annotation manager, this will remove the underlying layer and source from the style.
    /// A removed annotation manager will not be able to reuse anymore, you will need to create new annotation manger to add annotations.
    /// - Parameter id: Identifer of annotation manager to remove
    public func removeAnnotationManager(withId id: String) {
        removeAnnotationManager(withId: id, warnIfRemoved: false, function: #function)
    }

    private func removeAnnotationManager(withId id: String, warnIfRemoved: Bool, function: StaticString = #function) {
        guard let annotationManager = annotationManagersByIdInternal.removeValue(forKey: id) else {
            return
        }
        annotationManager.destroy()
        if warnIfRemoved {
            Log.warning(
                forMessage: "\(type(of: annotationManager)) with id \(id) was removed implicitly when invoking \(function) with the same id.",
                category: "Annotations")
        }
    }

    @objc private func handleTap(_ tap: UITapGestureRecognizer) {
        let managers = annotationManagersByIdInternal.values
        guard !managers.isEmpty else { return }

        let layerIds = managers.map(\.layerId)
        let options = RenderedQueryOptions(layerIds: layerIds, filter: nil)
        mapFeatureQueryable.queryRenderedFeatures(
            at: tap.location(in: tap.view),
            options: options) { (result) in

                switch result {

                case .success(let queriedFeatures):

                    // Get the identifiers of all the queried features
                    let queriedFeatureIds: [String] = queriedFeatures.compactMap {
                        guard case let .string(featureId) = $0.feature.identifier else {
                            return nil
                        }
                        return featureId
                    }

                    for manager in managers {
                        manager.handleQueriedFeatureIds(queriedFeatureIds)
                    }
                case .failure(let error):
                    Log.warning(forMessage: "Failed to query map for annotations due to error: \(error)",
                                category: "Annotations")
                }
            }
    }

    // swiftlint:disable:next cyclomatic_complexity
    @objc private func handleDrag(_ recognizer: MapboxLongPressGestureRecognizer) {
        let managers = annotationManagersByIdInternal.values
        guard !managers.isEmpty else { return }

        switch recognizer.state {
        case .began:
            let layerIdentifiers = managers.flatMap(\.allLayerIds)
            let options = RenderedQueryOptions(layerIds: layerIdentifiers, filter: nil)
            let gestureLocation = recognizer.location(in: recognizer.view)
            mapFeatureQueryable.queryRenderedFeatures(at: gestureLocation, options: options) { result in

                switch result {
                case .success(let queriedFeatures):
                    let queriedFeatureIds: [String] = queriedFeatures.compactMap {
                        guard case let .string(featureId) = $0.feature.identifier else {
                            return nil
                        }
                        return featureId
                    }

                    for manager in managers {
                        manager.handleDragBegin(with: queriedFeatureIds)
                    }

                case .failure(let error):
                    Log.error(forMessage: error.localizedDescription, category: "Gestures")
                }
            }

        case .changed:
            let translation = recognizer.translation(in: recognizer.view)

            for manager in managers {
                manager.handleDragChanged(with: translation)
            }
            recognizer.setTranslation(.zero, in: recognizer.view)

        case .ended, .cancelled:
            for manager in managers {
                manager.handleDragEnded()
            }

        case .possible, .failed:
            fallthrough
        @unknown default:
            break
        }
    }
}

extension AnnotationOrchestratorImpl: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        switch gestureRecognizer {
        case self.tapGestureRecognizer where otherGestureRecognizer is UITapGestureRecognizer:
            return true
        case self.longPressGestureRecognizer where otherGestureRecognizer is UILongPressGestureRecognizer:
            return true
        default:
            return false
        }
    }
}
