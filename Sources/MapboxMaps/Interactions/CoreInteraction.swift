extension CoreInteraction {
    typealias ContextHandler = (CoreInteractionContext) -> Void
    private class HandlerImpl: CoreInteractionHandler {
        func handleBegin(for feature: QueriedFeature?, context: CoreInteractionContext) -> Bool {
            onBegin(feature, context)
        }

        func handleChange(for context: CoreInteractionContext) {
            onChange?(context)
        }

        func handleEnd(for context: CoreInteractionContext) {
            onEnd?(context)
        }

        let onBegin: (QueriedFeature?, CoreInteractionContext) -> Bool
        let onChange: ContextHandler?
        let onEnd: ContextHandler?

        init(handler: @escaping MapLayerGestureHandler) {
            onBegin = { queriedFeature, context in
                guard let queriedFeature else {
                    return false
                }
                return handler(queriedFeature, InteractionContext(coreContext: context))
            }
            onChange = nil
            onEnd = nil
        }

        init(
            featureset: FeaturesetDescriptor?,
            onBegin: @escaping (InteractiveFeature?, InteractionContext) -> Bool,
            onChange: ((InteractionContext) -> Void)? = nil,
            onEnd: ((InteractionContext) -> Void)? = nil
        ) {
            if let featureset {
                self.onBegin = { feature, context  in
                    let swiftContext = InteractionContext(coreContext: context)
                    guard let feature else {
                        return onBegin(nil, swiftContext)
                    }
                    guard let interactiveFeature = InteractiveFeature(queriedFeature: feature, featureset: featureset) else {
                        return false
                    }
                    return onBegin(interactiveFeature, swiftContext)
                }
            } else {
                self.onBegin = { _, context in
                    return onBegin(nil, InteractionContext(coreContext: context))
                }
            }

            self.onEnd = onEnd.map { onEnd in
                return { onEnd(InteractionContext(coreContext: $0))}
            }
            self.onChange = onChange.map { onChange in
                return { onChange(InteractionContext(coreContext: $0))}
            }
        }
    }

    convenience init(impl: InteractionImpl) {
        let featureset = impl.target?.0
        self.init(
            featureset: featureset,
            filter: impl.target?.1?.asCore,
            type: impl.type.core,
            handler: HandlerImpl(
                featureset: featureset,
                onBegin: impl.onBegin,
                onChange: impl.onChange,
                onEnd: impl.onEnd))
    }

    convenience init(layerId: String, type: CoreInteractionType, handler: @escaping MapLayerGestureHandler) {
        self.init(featureset: .layer(layerId), filter: nil, type: type, handler: HandlerImpl(handler: handler))
    }
}
