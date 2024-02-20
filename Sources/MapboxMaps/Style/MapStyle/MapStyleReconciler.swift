import os

/// Style reconciler incrementally applies style changes to the map.
/// Use `mapStyle` setter or `loadStyle` function to update style or import configurations.
/// The update will trigger actual style load only if needed.
final class MapStyleReconciler {
    var mapStyle: MapStyle? {
        get { _mapStyle }
        set {
            if let newValue {
                loadStyle(newValue)
            } else {
                _mapStyle = nil
            }
        }
    }

    /// Triggers `true` when the root style description is loaded and `false` when it's in progress, or failed to load.
    /// Emits a value upon subscription.
    var isStyleRootLoaded: Signal<Bool> { _isStyleRootLoaded.signal.skipRepeats() }

    private let styleManager: StyleManagerProtocol
    private var pendingCompletions = [(Error?) -> Void]()
    private var _mapStyle: MapStyle?
    private let _isStyleRootLoaded: CurrentValueSignalSubject<Bool>
    private var styleModel = MapStyleModel()
    private var accessors: StyleAccessors

    init(styleManager: StyleManagerProtocol, sourceManager: StyleSourceManagerProtocol) {
        self.styleManager = styleManager
        self.accessors = StyleAccessors(styleManager: styleManager, styleSourceManager: sourceManager)
        self._isStyleRootLoaded = .init(false)
    }

    func loadStyle(
        _ style: MapStyle,
        transition: TransitionOptions? = nil,
        completion: ((Error?) -> Void)? = nil
    ) {
        var oldModel = styleModel
        styleModel = style.buildModel(transition: transition)

        if _mapStyle?.loadMethod != style.loadMethod {
            _mapStyle = style
            oldModel = MapStyleModel() // New load, so update from an empty model

            let callbacks = RuntimeStylingCallbacks(
                sources: { [weak self] in
                    self?.reconcile(stages: [.sources], from: oldModel)
                },
                layers: { [weak self] in
                    if let transition {
                        self?.styleManager.setStyleTransitionFor(transition)
                    }
                    // This callback means the style description is loaded.
                    self?.reconcile(stages: [.layers], from: oldModel)
                    self?._isStyleRootLoaded.value = true
                },
                images: { [weak self] in
                    self?.reconcile(stages: [.images], from: oldModel)
                },
                completed: { [weak self] in
                    completion?(nil)
                    self?.completeLoad(nil)
                },
                cancelled: { [weak self] in
                    let error = CancelError()
                    completion?(error)
                    self?.completeLoad(error)
                },
                error: { [weak self] error in
                    completion?(error)
                    self?.completeLoad(error)
                })
            switch style.loadMethod {
            case let .json(json):
                styleManager.setStyleJSON(json, callbacks: callbacks)
            case let .uri(uri):
                styleManager.setStyleURI(uri.rawValue, callbacks: callbacks)
            }
            updateStyleRootLoaded()
            return
        }
        _mapStyle = style

        if styleManager.isStyleLoaded() {
            self.reconcile(stages: StyleLoadingStage.all, from: oldModel)
            completion?(nil)
        } else {
            // The style with the same uri is already loading, save completion for future execution.
            pendingCompletions += completion.asArray
        }
    }

    private func completeLoad(_ error: Error?) {
        let completions = pendingCompletions
        pendingCompletions.removeAll()
        for completion in completions {
            completion(error)
        }
        updateStyleRootLoaded()
    }

    private func updateStyleRootLoaded() {
        _isStyleRootLoaded.value = styleManager.isStyleLoaded()
    }

    private enum StyleLoadingStage {
        case layers
        case sources
        case images
        static var all = [StyleLoadingStage.layers, .sources, .images]
    }

    private func reconcile(stages: [StyleLoadingStage], from old: MapStyleModel) {
        for stage in stages {
            switch stage {
            case .layers:
                reconcileStyleImports(from: old.importConfigurations)
                applyLayerDiff(old: old.layers, new: styleModel.layers, accessor: accessors.layers)
                updateProperty(old: old.projection, new: styleModel.projection, accessor: accessors.projection)
                updateProperty(old: old.atmosphere, new: styleModel.atmosphere, accessor: accessors.atmosphere)
                updateProperty(old: old.terrain, new: styleModel.terrain, accessor: accessors.terrain)
            case .sources:
                applyDiff(old: old.sources, new: styleModel.sources, accessor: accessors.sources)
            case .images:
                applyDiff(old: old.images, new: styleModel.images, accessor: accessors.images)
            }
        }
    }

    private func reconcileStyleImports(from old: [StyleImportConfiguration]?) {
        guard let mapStyle else { return }
        Self.reconcileStyleImports(
            from: old,
            to: mapStyle.importConfigurations,
            styleManager: styleManager)
    }
}

extension MapStyle {
    func buildModel(transition: TransitionOptions?) -> MapStyleModel {
        let visitor = MapStyleContentVisitor()
        let mapStyleContent = (content?()) ?? EmptyMapStyleContent()
        mapStyleContent.visit(visitor)
        visitor.model.transition = transition
        visitor.model.importConfigurations = importConfigurations
        return visitor.model
    }
}

extension MapStyleReconciler {
    static func reconcileStyleImports(
        from old: [StyleImportConfiguration]?,
        to new: [StyleImportConfiguration],
        styleManager: StyleManagerProtocol
    ) {
        for importConfig in new {
            let oldImportConfig = old?.first { $0.importId == importConfig.importId }
            do {
                for (key, value) in importConfig.config {
                    guard let value, value != oldImportConfig?.config[key] else {
                        continue
                    }
                    try handleExpected {
                        styleManager.setStyleImportConfigPropertyForImportId(importConfig.importId, config: key, value: value.rawValue)
                    }
                }
            } catch {
                Log.error(forMessage: "Failed updating import config properties, \(error)")
            }
        }
    }
}

private func updateProperty<T: Equatable>(old: T?, new: T?, accessor: Accessor<T>) {
    guard old != new else { return }

    if let new {
        wrapStyleDSLError { try accessor.insert(new) }
    } else if old != nil {
        wrapStyleDSLError { try accessor.remove(nil) }
    }
}

private func applyLayerDiff(old: [LayerWrapper], new: [LayerWrapper], accessor: Accessor<LayerWrapper>) {
    let diff = new.diff(from: old, id: \.layer.asLayer.id)

    for removeId in diff.remove {
        wrapStyleDSLError { try accessor.remove(removeId) }
    }

    for layer in diff.add {
        wrapStyleDSLError { try accessor.insert(layer) }
    }

    for layer in diff.update {
        let oldLayer = old.first { $0.id == layer.id }
        wrapStyleDSLError {  try accessor.update(oldLayer, layer) }
    }
}

private func applyDiff<T>(old: [String: T], new: [String: T], accessor: Accessor<T>) {
    let oldKeys = Set(old.keys)
    let newKeys = Set(new.keys)
    let insertionKeys = newKeys.subtracting(oldKeys)
    let removalKeys = oldKeys.subtracting(newKeys)
    let updateKeys = oldKeys.intersection(newKeys).filter {
        !accessor.isEqual(old[$0]!, new[$0]!)
    }

    removalKeys.forEach { key in
        wrapStyleDSLError { try accessor.remove(key) }
    }
    insertionKeys.forEach { key in
        wrapStyleDSLError { try new[key].map(accessor.insert) }
    }
    updateKeys.forEach {
        guard let new = new[$0], let old = old[$0] else {
            return
        }
        wrapStyleDSLError {  try accessor.update(old, new) }
    }
}

func wrapStyleDSLError(_ body: () throws -> Void) {
    do {
        try body()
    } catch {
        Log.error(forMessage: "Failed to update Map Style Content, error: \(error)", category: "styleDSL")
    }
}
