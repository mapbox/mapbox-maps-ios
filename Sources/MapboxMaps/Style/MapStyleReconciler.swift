/// Incrementally applies changes in map style.
class MapStyleReconciler {
    var mapStyle: MapStyle? {
        didSet {
            reconcile(from: oldValue)
        }
    }

    struct LoadingState {
        var oldImports: [StyleImportConfiguration]?
        var token: AnyCancelable?
    }

    private let onStyleDataLoaded: Signal<StyleDataLoaded>
    private let coreStyleManager: StyleManagerProtocol
    private var loadingState: LoadingState?

    init(
        coreStyleManager: StyleManagerProtocol,
        onStyleDataLoaded: Signal<StyleDataLoaded>
    ) {
        self.coreStyleManager = coreStyleManager
        self.onStyleDataLoaded = onStyleDataLoaded
    }

    private func reconcile(from old: MapStyle?) {
        if let mapStyle, old?.loadMethod != mapStyle.loadMethod {
            switch mapStyle.loadMethod {
            case let .json(json):
                coreStyleManager.setStyleJSONForJson(json)
            case let .uri(uri):
                coreStyleManager.setStyleURIForUri(uri.rawValue)
            }
        }

        switch (loadingState, coreStyleManager.isStyleLoaded()) {
        case (.none, true):
            // Style is loaded, just need update the import config
            reconcileStyleImports(from: old?.importConfigurations)
        case (.none, false):
            // Style began loading, need to wait loading to update import config
            let token = onStyleDataLoaded
                .filter { $0.type == .style }
                .observeNext { [weak self] _ in
                    self?.handleStyleDataLoaded()
                }
            loadingState = LoadingState(oldImports: old?.importConfigurations, token: token)
        case (.some(_), _):
            // Already waiting style to load. When style loads new configuration will be applied.
            break
        }
    }

    func handleStyleDataLoaded() {
        guard let loadingState else {
            assertionFailure()
            return
        }

        reconcileStyleImports(from: loadingState.oldImports)
        self.loadingState = nil
    }

    func reconcileStyleImports(from old: [StyleImportConfiguration]?) {
        guard let mapStyle else { return }
        Self.reconcileStyleImports(
            from: old,
            to: mapStyle.importConfigurations,
            coreStyleManager: coreStyleManager)
    }

    static func reconcileStyleImports(
        from old: [StyleImportConfiguration]?,
        to new: [StyleImportConfiguration],
        coreStyleManager: StyleManagerProtocol
    ) {
        for importConfig in new {
            let oldImportConfig = old?.first { $0.importId == importConfig.importId }
            do {
                for (key, value) in importConfig.config {
                    guard let value, value != oldImportConfig?.config[key] else {
                        continue
                    }
                    try handleExpected {
                        coreStyleManager.setStyleImportConfigPropertyForImportId(importConfig.importId, config: key, value: value.rawValue)
                    }
                }
            } catch {
                Log.error(forMessage: "Failed updating import config properties, \(error)")
            }
        }
    }
}
