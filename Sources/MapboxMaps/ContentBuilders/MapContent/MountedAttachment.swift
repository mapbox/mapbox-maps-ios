final class MountedAttachment: MapContentMountedComponent {
    /// Attachments currently mounted anywhere in the process; a second mount of the same object is refused.
    private static let mounted = WeakSet<any MapContentAttachment>()

    let attachment: any MapContentAttachment
    private(set) var isAttached = false

    init(attachment: any MapContentAttachment) {
        self.attachment = attachment
    }

    func mount(with context: MapContentNodeContext) throws {
        guard let map = context.content?.mapboxMap.value else {
            // No map yet: the next walk retries, `tryUpdate` won't keep an unattached component.
            return
        }
        guard let map = map as? MapboxMap else {
            Log.error("Attachments require the concrete MapboxMap, got \(type(of: map))", category: "StyleDSL")
            return
        }
        guard !Self.mounted.contains(attachment) else {
            // Left unattached, so the next walk retries once the other mount lets go.
            Log.error("\(type(of: attachment)) is already attached elsewhere; use one attachment per place", category: "StyleDSL")
            return
        }
        Self.mounted.add(attachment)
        attachment.attached(to: map)
        isAttached = true
    }

    func unmount(with context: MapContentNodeContext) throws {
        guard isAttached else { return }
        isAttached = false
        Self.mounted.remove(attachment)
        attachment.detached()
    }

    func tryUpdate(from old: MapContentMountedComponent, with context: MapContentNodeContext) throws -> Bool {
        // Same object, already attached: stay mounted. A mount that found no map is retried instead.
        guard let old = old as? MountedAttachment, old.attachment === attachment, old.isAttached else {
            return false
        }
        isAttached = true
        return true
    }

    func updateMetadata(with: MapContentNodeContext) {}
}
