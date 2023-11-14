import MapboxCoreMaps
import MetalKit

internal protocol DelegatingMapClientDelegate: AnyObject {
    func scheduleRepaint()
    func getMetalView(for metalDevice: MTLDevice?) -> MTKView?
}

internal final class DelegatingMapClient: CoreMapClient, CoreMetalViewProvider {
    internal weak var delegate: DelegatingMapClientDelegate?

    internal func scheduleRepaint() {
        delegate?.scheduleRepaint()
    }

    internal func getMetalView(for metalDevice: MTLDevice?) -> MTKView? {
        return delegate?.getMetalView(for: metalDevice)
    }
}
