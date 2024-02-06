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
    private typealias ManagerHandlerBlock = (AnnotationManagerInternal) -> (String, Feature, MapContentGestureContext) -> Bool

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
        onLongPress: Signal<(CGPoint, UIGestureRecognizer.State)>
    ) {
            self.annotations = annotations
            self.mapboxMap = mapboxMap
            self.mapFeatureQueryable = mapFeatureQueryable
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

        queryFeatures(context: context, subscribers: \.layerTapSubscribers) { [weak self] queriedFeatures, context in
            guard let self else { return }

            for queriedFeature in queriedFeatures {
                if !self.handle(using: { manager in manager.handleTap }, queriedFeature: queriedFeature, context: context) {
                    if !self.handle(subscribers: \.layerTapSubscribers, queriedFeature: queriedFeature, context: context) {
                        continue
                    }
                }
                return
            }

            self.mapTapSignal.send(context)
        }
    }

    private func handleLongPress(_ data: (CGPoint, UIGestureRecognizer.State)) {
        let (point, state) = data
        let coordinate = mapboxMap.coordinate(for: point)
        let context = MapContentGestureContext(point: point, coordinate: coordinate)

        switch state {
        case .began:
            queryFeatures(context: context, subscribers: \.layerLongPressSubscribers) { [weak self] queriedFeatures, context in
                guard let self else { return }
                var isLongPressHandled = false

                for queriedFeature in queriedFeatures {
                    if !self.handle(using: { manager in manager.handleLongPress }, queriedFeature: queriedFeature, context: context) {
                        if !self.handle(subscribers: \.layerLongPressSubscribers, queriedFeature: queriedFeature, context: context) {
                            continue
                        }
                    }
                    isLongPressHandled = true
                }

                if !isLongPressHandled { self.mapLongPressSignal.send(context) }

                self.handeDragBegin(queriedFeatures: queriedFeatures, context: context)
            }

        case .changed:
            guard let dragState else { return }
            let translation = dragState.point - point
            dragState.manager.handleDragChange(with: translation, context: context)
            self.dragState?.point = point

        case .ended, .cancelled:
            dragState?.manager.handleDragEnd(context: context)
            dragState = nil

        default:
            break
        }
    }

    private func handeDragBegin(queriedFeatures: [(String, QueriedFeature)], context: MapContentGestureContext) {
        if let dragState {
            assertionFailure()
            dragState.manager.handleDragEnd(context: context)
        }

        for (layerId, queriedFeature) in queriedFeatures {
            if let manager = annotations.managersByLayerId[layerId], let featureId = queriedFeature.feature.stringId {
                if manager.handleDragBegin(with: featureId, context: context) {
                    dragState = DragState(point: context.point, manager: manager)
                    return
                }
            }
        }
    }

    private func handle(
        using handledUsing: ManagerHandlerBlock,
        queriedFeature: (String, QueriedFeature),
        context: MapContentGestureContext
    ) -> Bool {
        let (layerId, queriedFeature) = queriedFeature
        if let manager = annotations.managersByLayerId[layerId],
            handledUsing(manager)(layerId, queriedFeature.feature, context) {
            return true
        }
        return false
    }

    private func handle(
        subscribers: KeyPath<MapContentGestureManager, [String: LayerSubscribersStore]>,
        queriedFeature: (String, QueriedFeature),
        context: MapContentGestureContext
    ) -> Bool {
        let (layerId, queriedFeature) = queriedFeature
        if let store = self[keyPath: subscribers][layerId] {
            for handler in store where handler((queriedFeature, context)) {
                return true
            }
        }
        return false
    }

    private func queryFeatures(
        context: MapContentGestureContext,
        subscribers: KeyPath<MapContentGestureManager, [String: LayerSubscribersStore]>? = nil,
        handler: @escaping ([(String, QueriedFeature)], MapContentGestureContext) -> Void
    ) {
        var layerIds = Array(annotations.managersByLayerId.keys)
        if let subscribers { layerIds += self[keyPath: subscribers].keys }
        queryToken = mapFeatureQueryable.queryRenderedFeatures(point: context.point, layerIds: layerIds) { queriedFeatures in
            handler(queriedFeatures, context)
        }
    }
}

private extension MapFeatureQueryable {
    /// Queries the map for rendered features and returns result in form of [(LayerId, Feature)] array.
    func queryRenderedFeatures(
        point: CGPoint,
        layerIds: [String],
        completion: @escaping ([(String, QueriedFeature)]) -> Void
    ) -> AnyCancelable {
        guard !layerIds.isEmpty else {
            completion([])
            return .empty
        }

        let options = RenderedQueryOptions(layerIds: layerIds, filter: nil)
        return queryRenderedFeatures(with: point, options: options) { result in
            switch result {
            case .success(let features):
                let layerAndFeatures = features.flatMap { feature in
                    feature.layers.map { ($0, feature.queriedFeature) }
                }
                completion(layerAndFeatures)
            case .failure(let error):
                Log.warning(forMessage: "Failed to query map content gesture: \(error)", category: "Gestures")
                completion([])
            }
        }
        .erased
    }
}

private extension Feature {
    var stringId: String? { identifier?.string }
}
