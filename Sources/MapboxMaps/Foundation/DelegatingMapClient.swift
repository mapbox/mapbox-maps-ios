import MapboxCoreMaps
@_implementationOnly import MapboxCoreMaps_Private

internal protocol DelegatingMapClientDelegate: AnyObject {
    func scheduleRepaint()
    func getMetalView(for metalDevice: MTLDevice?) -> MTKView?
}

internal final class DelegatingMapClient: MapClient, MBMMetalViewProvider {
    internal weak var delegate: DelegatingMapClientDelegate?

    internal func scheduleRepaint() {
        delegate?.scheduleRepaint()
    }

    internal func getMetalView(for metalDevice: MTLDevice?) -> MTKView? {
        return delegate?.getMetalView(for: metalDevice)
    }
}
