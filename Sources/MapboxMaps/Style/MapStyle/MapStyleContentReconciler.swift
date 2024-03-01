import os

final class MapStyleNodeContext {
    var lastLayerId: String?
    var startLayerPosition: LayerPosition?
    var uniqueProperties = MapStyleUniqueProperties()

    let managers: StyleManagers

    init(managers: StyleManagers) {
        self.managers = managers
    }
}

@available(iOS 13.0, *)
final class MapStyleContentReconciler {
    var content: any MapStyleContent = EmptyMapStyleContent() {
        didSet {
            if isStyleLoaded {
                update(with: content)
            }
        }
    }

    private let context: MapStyleNodeContext
    private var root: MapStyleNode
    private let managers: StyleManagers

    private enum LoadingState {
        case loaded
        /// Loading state contains content updates closures to apply when style is loaded
        case loading([() -> Void])
    }

    private var isStyleLoaded: Bool = true {
        didSet {
            guard isStyleLoaded != oldValue, isStyleLoaded else { return }
            reset()
            update(with: content)
        }
    }
    private var state: LoadingState = .loaded
    private var loadingToken: AnyCancelable?

    init(managers: StyleManagers, styleIsLoaded: Signal<Bool>) {
        self.context = MapStyleNodeContext(managers: managers)
        self.root = MapStyleNode(context: context)
        self.managers = managers

        loadingToken = styleIsLoaded.assign(to: \.isStyleLoaded, ofWeak: self)
    }

    private func update(with content: any MapStyleContent) {
        let trace = OSLog.platform.beginInterval("MapStyleContent update")
        defer { trace?.end() }

        let oldProperties = context.uniqueProperties
        context.uniqueProperties = MapStyleUniqueProperties()
        context.lastLayerId = nil
        root.update(with: content)

        context.uniqueProperties.update(from: oldProperties, style: managers.style)
    }

    private func reset() {
        root = MapStyleNode(context: context)
        context.uniqueProperties = MapStyleUniqueProperties()
        context.lastLayerId = nil

        // This doesn't work when the layer with lastLayerId is removed
        // TODO: MAPSIOS-1353 calculate position with annotations
        let lastLayerId = managers.style.getStyleLayers().last?.id
        context.startLayerPosition = lastLayerId.map { .above($0) } ?? .at(0)
    }
}
