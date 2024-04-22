struct MountedPuck: MapContentMountedComponent {
    let locationOptions: LocationOptions

    func mount(with context: MapContentNodeContext) throws {
        context.uniqueProperties.location = locationOptions.positioned(at: context.resolveLayerPosition())
    }

    func unmount(with context: MapContentNodeContext) throws {
        context.uniqueProperties.location = nil
    }

    func tryUpdate(from old: MapContentMountedComponent, with context: MapContentNodeContext) throws -> Bool {
        context.uniqueProperties.location = locationOptions.positioned(at: context.resolveLayerPosition())
        return true
    }

    func updateMetadata(with: MapContentNodeContext) {}
}

private extension LocationOptions {
    func positioned(at position: LayerPosition) -> Self {
        var copy = self

        switch copy.puckType {
        case let .puck2D(configuration):
            copy.puckType = .puck2D(copyAssigned(configuration, \.layerPosition, position))
        case let .puck3D(configuration):
            copy.puckType = .puck3D(copyAssigned(configuration, \.layerPosition, position))
        case .none:
            break
        }

        return copy
    }
}
