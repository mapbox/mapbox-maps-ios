import Foundation
import UIKit
@_implementationOnly import MapboxCommon_Private

internal protocol AnnotationOrchestratorImplProtocol: AnyObject {
    var managersByLayerId: [String: AnnotationManagerInternal] { get }
    var annotationManagersById: [String: AnnotationManager] { get }
    func makePointAnnotationManager(id: String,
                                    layerPosition: LayerPosition?,
                                    clusterOptions: ClusterOptions?) -> AnnotationManagerInternal
    func makePolygonAnnotationManager(id: String, layerPosition: LayerPosition?) -> AnnotationManagerInternal
    func makePolylineAnnotationManager(id: String, layerPosition: LayerPosition?) -> AnnotationManagerInternal
    func makeCircleAnnotationManager(id: String, layerPosition: LayerPosition?) -> AnnotationManagerInternal
    func removeAnnotationManager(withId id: String)
}

final class AnnotationOrchestratorImpl: NSObject, AnnotationOrchestratorImplProtocol {
    private(set) var managersByLayerId: [String: AnnotationManagerInternal] = [:]

    private let factory: AnnotationManagerFactoryProtocol

    init(factory: AnnotationManagerFactoryProtocol) {
        self.factory = factory
        super.init()
    }

    /// Dictionary of annotation managers keyed by their identifiers.
    var annotationManagersById: [String: AnnotationManager] { annotationManagersByIdInternal }

    private var annotationManagersByIdInternal = [String: AnnotationManagerInternal]() {
        didSet {
            // calculate (layerId, manager) pairs
            let pairs = annotationManagersByIdInternal.values.flatMap { manager in
                manager.allLayerIds.map { ($0, manager) }
            }
            self.managersByLayerId = Dictionary(uniqueKeysWithValues: pairs)
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
    func makePointAnnotationManager(
        id: String,
        layerPosition: LayerPosition?,
        clusterOptions: ClusterOptions?
    ) -> AnnotationManagerInternal {
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
    func makePolygonAnnotationManager(id: String, layerPosition: LayerPosition?) -> AnnotationManagerInternal {
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
    func makePolylineAnnotationManager(id: String, layerPosition: LayerPosition?) -> AnnotationManagerInternal {
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
    func makeCircleAnnotationManager(id: String, layerPosition: LayerPosition?) -> AnnotationManagerInternal {
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
}
