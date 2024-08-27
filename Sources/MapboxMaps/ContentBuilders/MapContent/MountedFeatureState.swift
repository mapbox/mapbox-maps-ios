import UIKit
import SwiftUI
import os.log

@available(iOS 13.0, *)
final class MountedFeatureState: MapContentMountedComponent {
    var state: FeatureState

    init(state: FeatureState) {
        self.state = state
    }

    func mount(with context: MapContentNodeContext) throws {
        guard let featureId = state.featureId else {
            return
        }
        context.content?.mapboxMap.value?.setFeatureState(featureset: state.featureset, featureId: featureId, state: state.state, callback: { _ in })
    }

    func unmount(with context: MapContentNodeContext) throws {
        guard let featureId = state.featureId else {
            return
        }
        for key in state.state.keys {
            // TODO: Remove all states at once
            context.content?.mapboxMap.value?.removeFeatureState(featureset: state.featureset, featureId: featureId, stateKey: key, callback: { _ in })
        }
    }

    func tryUpdate(from old: MapContentMountedComponent, with context: MapContentNodeContext) throws -> Bool {
        guard let old = old as? MountedFeatureState else {
            return false
        }
        return old.state == state
    }

    func updateMetadata(with: MapContentNodeContext) {}
}
