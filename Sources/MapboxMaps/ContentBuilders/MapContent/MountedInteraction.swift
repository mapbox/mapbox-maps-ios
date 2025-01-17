import UIKit
import SwiftUI

final class MountedInteraction: MapContentMountedComponent {
    let interaction: InteractionImpl
    var token: AnyCancelable?

    init(interaction: InteractionImpl) {
        self.interaction = interaction
    }

    func mount(with context: MapContentNodeContext) throws {
        token = context.content?.mapboxMap.value?.addInteraction(interaction).erased
    }

    func unmount(with context: MapContentNodeContext) throws {
        token = nil
    }

    func tryUpdate(from old: MapContentMountedComponent, with context: MapContentNodeContext) throws -> Bool {
        /// The interaction is not equatable, as the callback can be changed.
        /// Additionally, it's cheap to add/remove interactions, so we add/remove them on each style update.
        /// This also allows to maintain the proper order of interactions.
        false
    }

    func updateMetadata(with: MapContentNodeContext) {}
}
