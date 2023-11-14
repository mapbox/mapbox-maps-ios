@testable import MapboxMaps
import MetalKit

final class MockDelegatingMapClientDelegate: DelegatingMapClientDelegate {
    let scheduleRepaintStub = Stub<Void, Void>()
    func scheduleRepaint() {
        scheduleRepaintStub.call()
    }

    let getMetalViewStub = Stub<MTLDevice?, MTKView?>(defaultReturnValue: nil)
    func getMetalView(for metalDevice: MTLDevice?) -> MTKView? {
        return getMetalViewStub.call(with: metalDevice)
    }
}
