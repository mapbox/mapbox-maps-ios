import MapboxCoreMaps
import MetalKit

protocol DelegatingMapClientDelegate: AnyObject {
    func scheduleRepaint()
    func getMetalView(for metalDevice: MTLDevice?) -> MetalView?
}

final class DelegatingMapClient: CoreMapClient, CoreMetalViewProvider {
    weak var delegate: DelegatingMapClientDelegate?

    func scheduleRepaint() {
        delegate?.scheduleRepaint()
    }

    func getMetalView(for metalDevice: MTLDevice?) -> CoreMetalView? {
        delegate?.getMetalView(for: metalDevice)
    }
}
