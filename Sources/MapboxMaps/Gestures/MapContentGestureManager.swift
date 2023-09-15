import UIKit

protocol MapContentGestureManagerProtocol {
    var onMapTap: Signal<MapContentGestureContext> { get }
    var onMapLongPress: Signal<MapContentGestureContext> { get }
    func onLayerTap(_ layerId: String, handler: @escaping MapLayerGestureHandler) -> AnyCancelable
    func onLayerLongPress(_ layerId: String, handler: @escaping MapLayerGestureHandler) -> AnyCancelable
}

/// Manages gesture interaction with map content, such as `Annotation`s, `Layer`s or `Map` itself.
final class MapContentGestureManager: MapContentGestureManagerProtocol {
    var onMapTap: Signal<MapContentGestureContext> { mapTapSignal.signal }
    var onMapLongPress: Signal<MapContentGestureContext> { mapLongPressSignal.signal }

    private typealias LayerTapGestureParams = (QueriedFeature, MapContentGestureContext)
    private typealias LayerSubscribersStore = ClosureHandlersStore<LayerTapGestureParams, Bool>

    private struct DragState {
        var point: CGPoint
        let manager: AnnotationManagerInternal
    }

    private let annotations: AnnotationOrchestratorImplProtocol
    private let mapboxMap: MapboxMapProtocol
    private let mapFeatureQueryable: MapFeatureQueryable

    private var tokens = Set<AnyCancelable>()
    private var queryToken: AnyCancelable?
    private let mapTapSignal = SignalSubject<MapContentGestureContext>()
    private let mapLongPressSignal = SignalSubject<MapContentGestureContext>()
    private var dragState: DragState?
    private var layerTapSubscribers = [String: LayerSubscribersStore]()
    private var layerLongPressSubscribers = [String: LayerSubscribersStore]()

    init(
        annotations: AnnotationOrchestratorImplProtocol,
        mapboxMap: MapboxMapProtocol,
        mapFeatureQueryable: MapFeatureQueryable,
        onTap: Signal<CGPoint>,
        onLongPress: Signal<(CGPoint, UIGestureRecognizer.State)>) {
            self.annotations = annotations
            self.mapFeatureQueryable = mapFeatureQueryable
            self.mapboxMap = mapboxMap
            onTap
                .handle(in: MapContentGestureManager.handleTap(_:), ofWeak: self)
                .store(in: &tokens)
            onLongPress
                .handle(in: MapContentGestureManager.handleLongPress(_:), ofWeak: self)
                .store(in: &tokens)
        }

    func onLayerLongPress(_ layerId: String, handler: @escaping MapLayerGestureHandler) -> AnyCancelable {
        addLayerGestureHandler(to: \.layerLongPressSubscribers, layerId: layerId, handler: handler)
    }

    func onLayerTap(_ layerId: String, handler: @escaping MapLayerGestureHandler) -> AnyCancelable {
        addLayerGestureHandler(to: \.layerTapSubscribers, layerId: layerId, handler: handler)
    }

    private func addLayerGestureHandler(
        to keyPath: ReferenceWritableKeyPath<MapContentGestureManager, [String: LayerSubscribersStore]>,
        layerId: String,
        handler: @escaping MapLayerGestureHandler
    ) -> AnyCancelable {
        if let store = self[keyPath: keyPath][layerId] {
            return store.add(handler: handler)
        }

        let store = LayerSubscribersStore()
        self[keyPath: keyPath][layerId] = store
        store.onObserved = { [weak self] observed in
            // When the last observer is gone, we will remove layer from handlers to avoid querying it.
            if !observed {
                self?[keyPath: keyPath].removeValue(forKey: layerId)
            }
        }
        return store.add(handler: handler)
    }

    private func handleTap(_ point: CGPoint) {
        let coordinate = mapboxMap.coordinate(for: point)
        let context = MapContentGestureContext(point: point, coordinate: coordinate)

        let layerIds = Array(annotations.managersByLayerId.keys) + Array(layerTapSubscribers.keys)
        queryToken = mapFeatureQueryable.queryRenderedFeatures(point: point, layerIds: layerIds) { [weak self] queryResult in
            guard let self else { return }
            let result = self.handle(queryResult: queryResult,
                                     context: context,
                                     handleManager: AnnotationManagerInternal.handleTap(with:context:),
                                     layersGestureSubscribers: self.layerTapSubscribers)
            if result == nil {
                // No annotations or layers handled the tap, sending map tap signal.
                self.mapTapSignal.send(context)
            }
        }
    }

    private func handleLongPress(_ data: (CGPoint, UIGestureRecognizer.State)) {
        let (point, state) = data
        let coordinate = mapboxMap.coordinate(for: point)
        let context = MapContentGestureContext(point: point, coordinate: coordinate)

        switch state {
        case .began:
            if let dragState {
                assertionFailure()
                dragState.manager.handleDragEnded()
                self.dragState = nil
            }
            let layerIds = Array(annotations.managersByLayerId.keys) + Array(self.layerLongPressSubscribers.keys)
            queryToken = mapFeatureQueryable.queryRenderedFeatures(point: point, layerIds: layerIds) { [weak self] queryResult in
                guard let self else { return }

                // First, handle long-press gesture
                let longPressResult = self.handle(queryResult: queryResult,
                                                  context: context,
                                                  handleManager: AnnotationManagerInternal.handleLongPress(with:context:),
                                                  layersGestureSubscribers: self.layerLongPressSubscribers)
                if longPressResult == nil {
                    // No annotations or layers handled the long press, sending the map longPress signal
                    self.mapLongPressSignal.send(context)
                }

                // Second, handle drag-begin gesture
                let dragStartResult = self.handle(queryResult: queryResult,
                                                 context: context,
                                                 handleManager: AnnotationManagerInternal.handleDragBegin(with:context:),
                                                 layersGestureSubscribers: [:])
                if let dragStartResult, case let .manager(manager) = dragStartResult {
                    self.dragState = DragState(point: point, manager: manager)
                }
            }

        case .changed:
            guard let dragState else { return }
            let translation = dragState.point - point
            dragState.manager.handleDragChanged(with: translation)
            self.dragState?.point = point

        case .ended, .cancelled:
            dragState?.manager.handleDragEnded()
            dragState = nil
        default:
            break
        }
    }

    private enum ResultingGestureHandler {
        case manager(AnnotationManagerInternal)
        case layer
    }

    /// Takes query result and tries handle the gesture with appropriate handler. Returns that handler if it handled the action.
    /// Returns `nil` if no handler found or no one handled the action.
    private func handle(
        queryResult: [(String, QueriedFeature)],
        context: MapContentGestureContext,
        handleManager: (AnnotationManagerInternal) -> (String, MapContentGestureContext) -> Bool,
        layersGestureSubscribers: [String: LayerSubscribersStore]
    ) -> ResultingGestureHandler? {
        for (layer, queriedFeature) in queryResult {
            if let manager = self.annotations.managersByLayerId[layer],
               let featureId = queriedFeature.feature.identifier?.string {
                if handleManager(manager)(featureId, context) {
                    return .manager(manager)
                }
            }

            if let store = layersGestureSubscribers[layer] {
                for handler in store where handler((queriedFeature, context)) {
                    return .layer
                }
            }
        }
        return nil
    }
}

private extension MapFeatureQueryable {
    /// Queries the map for rendered features and returns result in form of [(LayerId, Feature)] array.
    func queryRenderedFeatures(point: CGPoint, layerIds: [String], completion: @escaping ([(String, QueriedFeature)]) -> Void) -> AnyCancelable {
        if layerIds.isEmpty {
            completion([])
            return .empty
        }
        let options = RenderedQueryOptions(layerIds: layerIds, filter: nil)
        return queryRenderedFeatures(
            with: point,
            options: options) { result in
                switch result {
                case .success(let features):
                    let layerAndFeatures = features.flatMap { feature in
                        feature.layers.map { ($0, feature.queriedFeature) }
                    }
                    completion(layerAndFeatures)
                case .failure(let error):
                    Log.warning(forMessage: "Failed to query map content gesture: \(error)",
                                category: "Gestures")
                    completion([])
                }
            }
            .erased
    }
}
