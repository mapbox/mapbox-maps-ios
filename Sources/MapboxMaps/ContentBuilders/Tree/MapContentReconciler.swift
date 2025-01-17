import os

final class MapContentReconciler {
    var content: any MapContent = EmptyMapContent() {
        didSet {
            if isStyleLoaded {
                update(with: content)
            }
        }
    }

    private var isStyleLoaded: Bool = false {
        didSet {
            guard isStyleLoaded != oldValue, isStyleLoaded else {
                return
            }
            reloadStyle(with: content)
        }
    }

    private let context: MapContentNodeContext
    private var root: MapContentNode
    private var loadingToken: AnyCancelable?
    private var sendTelemetryOncePerStyle = Once()

    init(styleManager: StyleManagerProtocol, sourceManager: StyleSourceManagerProtocol, styleIsLoaded: Signal<Bool>) {
        self.context = MapContentNodeContext(
            styleManager: styleManager,
            sourceManager: sourceManager,
            isEqualContent: arePropertiesEqual
        )
        let uuidString = UUID().uuidString
        self.root = MapContentNode(id: MapContentNode.ID(anyId: uuidString, stringId: uuidString), context: context)

        loadingToken = styleIsLoaded.assign(to: \.isStyleLoaded, ofWeak: self)
    }

    func setMapContentDependencies(_ dependencies: MapContentDependencies) {
        context.content = dependencies
    }

    private func update(with content: any MapContent) {
        let trace = OSLog.platform.beginInterval("MapContent update")
        defer { trace?.end() }

        context.update(mapContent: content, root: root)
        triggerTelemetryIfNeeded(for: root)
    }

    private func reloadStyle(with content: any MapContent) {
        let trace = OSLog.platform.beginInterval("MapContent update on style reload")
        defer { trace?.end() }
        sendTelemetryOncePerStyle.reset()

        context.reload(mapContent: content, root: root)
        triggerTelemetryIfNeeded(for: root)
    }

    /// Increment telemetry counter once per StyleDSL usage on the single style
    func triggerTelemetryIfNeeded(for node: MapContentNode) {
        guard !node.childrenIsEmpty, sendTelemetryOncePerStyle.continueOnce() else { return }
        sendTelemetry(\.styleDSL)
    }
}

private extension MapContentNodeContext {
    func update(mapContent: any MapContent, root: MapContentNode) {
        let oldProperties = uniqueProperties
        lastLayerId = nil
        lastImportId = nil
        uniqueProperties = MapContentUniqueProperties()

        mapContent.update(root)

        uniqueProperties.update(
            from: oldProperties,
            style: style.styleManager,
            initial: initialUniqueProperties,
            locationManager: content?.location.value
        )
    }

    func reload(mapContent: any MapContent, root: MapContentNode) {
        lastLayerId = nil
        lastImportId = nil

        /// On style reload we need to traverse the whole tree to reconstruct non-persistent layers
        /// On style reload we need to identify the bottom position in the style in order to stack content above
        /// Position must take into account only non-persistent layers, which was not added in runtime
        isEqualContent = { _, _ in false }
        initialStyleLayers = getInitialStyleLayers() ?? []
        initialStyleImports = style.styleManager.getStyleImports().map(\.id)
        initialUniqueProperties = getInitialUniqueProperties()

        mapContent.update(root)
        isEqualContent = arePropertiesEqual

        uniqueProperties.update(
            from: MapContentUniqueProperties(),
            style: style.styleManager,
            initial: initialUniqueProperties,
            locationManager: content?.location.value
        )
    }

    func getInitialUniqueProperties() -> MapContentUniqueProperties? {
        if let jsonData = style.styleManager.getStyleJSON().data(using: .utf8) {
            do {
                var initialMapUniqueProperties = try JSONDecoder().decode(MapContentUniqueProperties.self, from: jsonData)
                // Transition options are not included in the StyleJSON
                initialMapUniqueProperties.transition = TransitionOptions(style.styleManager.getStyleTransition())
                return initialMapUniqueProperties
            } catch {
                Log.warning("Unable to decode initial MapContentUniqueProperties \(error) from StyleJSON", category: "StyleDSL")
                return nil
            }
        }
        return nil
    }

    func getInitialStyleLayers() -> [String]? {
        try? style.styleManager
            .getStyleLayers()
            .filter { try !style.styleManager.isLayerPersistent(for: $0.id) }
            .map { $0.id }
    }
}

private extension StyleManagerProtocol {
    func isLayerPersistent(for layerId: String) throws -> Bool {
        try handleExpected {
            isStyleLayerPersistent(forLayerId: layerId)
        }
    }
}
