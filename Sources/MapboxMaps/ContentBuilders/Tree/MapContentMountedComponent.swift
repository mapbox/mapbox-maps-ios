import os
@_implementationOnly import MapboxCommon_Private

protocol MapContentMountedComponent {
    func mount(with context: MapContentNodeContext) throws
    func unmount(with context: MapContentNodeContext) throws
    func tryUpdate(from old: MapContentMountedComponent, with context: MapContentNodeContext) throws -> Bool
    func updateMetadata(with: MapContentNodeContext)
}
