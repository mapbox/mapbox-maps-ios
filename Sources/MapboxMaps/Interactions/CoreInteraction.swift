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
            featureset: FeaturesetDescriptor<FeaturesetFeature>?,
            onBegin: @escaping (FeaturesetFeature?, InteractionContext) -> Bool,
            onChange: ((InteractionContext) -> Void)? = nil,
            onEnd: ((InteractionContext) -> Void)? = nil
        ) {
            self.onBegin = { queriedFeature, context  in
                let feature: FeaturesetFeature? = if let queriedFeature, let featureset {
                    FeaturesetFeature(queriedFeature: queriedFeature, featureset: featureset)
                } else {
                    nil
                }
                let swiftContext = InteractionContext(coreContext: context)
                return onBegin(feature, swiftContext)
            }

            self.onEnd = onEnd.map { onEnd in
                return { onEnd(InteractionContext(coreContext: $0)) }
            }

            self.onChange = onChange.map { onChange in
                return { onChange(InteractionContext(coreContext: $0)) }
            }
        }
    }

    convenience init(impl: InteractionImpl) {
        let featureset = impl.target?.0
        self.init(
            featureset: featureset?.core,
            filter: impl.target?.1?.asCore,
            type: impl.type.core,
            handler: HandlerImpl(
                featureset: featureset,
                onBegin: impl.onBegin,
                onChange: impl.onChange,
                onEnd: impl.onEnd),
            radius: impl.radius.map { NSNumber(value: $0) })
    }

    convenience init(layerId: String, type: CoreInteractionType, handler: @escaping MapLayerGestureHandler) {
        self.init(featureset: FeaturesetDescriptor.layer(layerId).core, filter: nil, type: type, handler: HandlerImpl(handler: handler), radius: nil)
    }
}
