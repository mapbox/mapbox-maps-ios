import MapboxCoreMaps
@_implementationOnly import MapboxCoreMaps_Private

internal protocol DelegatingMapClientDelegate: AnyObject {
    func scheduleRepaint()
    func scheduleTask(forTask task: @escaping Task)
    func getMetalView(for metalDevice: MTLDevice?) -> MTKView?
}

internal final class DelegatingMapClient: MapClient, MBMMetalViewProvider {
    internal weak var delegate: DelegatingMapClientDelegate?

    internal func scheduleRepaint() {
        delegate?.scheduleRepaint()
    }

    internal func scheduleTask(forTask task: @escaping Task) {
        delegate?.scheduleTask(forTask: task)
    }

    internal func getMetalView(for metalDevice: MTLDevice?) -> MTKView? {
        return delegate?.getMetalView(for: metalDevice)
    }
}
