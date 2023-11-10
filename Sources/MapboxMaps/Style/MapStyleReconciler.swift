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

    init(styleManager: StyleManagerProtocol) {
        self.styleManager = styleManager
        self._isStyleRootLoaded = .init(false)
    }

    func loadStyle(
        _ style: MapStyle,
        transition: TransitionOptions? = nil,
        completion: ((Error?) -> Void)? = nil
    ) {
        if _mapStyle?.loadMethod != style.loadMethod {
            _mapStyle = style
            let callbacks = RuntimeStylingCallbacks(
                layers: { [weak self] in
                    // This callback means the style description is loaded.
                    guard let self else { return }
                    if let transition {
                        self.styleManager.setStyleTransitionFor(transition)
                    }
                    // When new style is loaded, no need in incremental change of import configuration.
                    self.reconcileStyleImports(from: nil)
                    self._isStyleRootLoaded.value = true
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
        let old = _mapStyle
        _mapStyle = style

        if styleManager.isStyleLoaded() {
            reconcileStyleImports(from: old?.importConfigurations)
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

    private func reconcileStyleImports(from old: [StyleImportConfiguration]?) {
        guard let mapStyle else { return }
        Self.reconcileStyleImports(
            from: old,
            to: mapStyle.importConfigurations,
            styleManager: styleManager)
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
