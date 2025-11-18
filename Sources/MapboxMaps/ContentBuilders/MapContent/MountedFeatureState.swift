import UIKit
import SwiftUI
import os.log

final class MountedFeatureState<T: FeaturesetFeatureType>: MapContentMountedComponent {
    var state: FeatureState<T>

    init(state: FeatureState<T>) {
        self.state = state
    }

    func mount(with context: MapContentNodeContext) throws {
        if let featureId = state.featureId {
            context.content?.mapboxMap.value?.setFeatureState(
                featureset: state.featureset,
                featureId: featureId,
                state: state.state,
                callback: { _ in }
            )
        }

        if let expression = state.expression {
            Task {
                try await context.content?.mapboxMap.value?.setFeatureStateExpression(
                    expressionId: UInt(bitPattern: expression.description.hashValue),
                    featureset: state.featureset,
                    expression: expression,
                    state: state.state
                )
            }
        }
    }

    func unmount(with context: MapContentNodeContext) throws {
        try unmountSingleFeature(with: context)
        try unmountExpression(with: context)
    }

    private func unmountExpression(with context: MapContentNodeContext) throws {
        guard let expression = state.expression else {
            return
        }
        Task {
            try await context.content?.mapboxMap.value?.removeFeatureStateExpression(
                expressionId: UInt(bitPattern: expression.description.hashValue)
            )
        }
    }

    private func unmountSingleFeature(with context: MapContentNodeContext) throws {
        guard let featureId = state.featureId else {
            return
        }
        let encoder = DictionaryEncoder()
        guard let json = try? encoder.encode(state.state) else {
            return
        }
        for key in json.keys {
            // TODO: Remove all states at once
            // TODO: refactor hack with descriptor conversion.
            let genericFeatureset: FeaturesetDescriptor<FeaturesetFeature> = state.featureset.converted()
            context.content?.mapboxMap.value?.removeFeatureState(
                featureset: genericFeatureset,
                featureId: featureId,
                stateKey: key, callback: { _ in })
        }
    }

    func tryUpdate(from old: MapContentMountedComponent, with context: MapContentNodeContext) throws -> Bool {
        guard let old = old as? Self else {
            return false
        }
        return old.state == state
    }

    func updateMetadata(with: MapContentNodeContext) {}
}
