@testable import MapboxMaps
import MetalKit

final class MockDelegatingMapClientDelegate: DelegatingMapClientDelegate {
    let scheduleRepaintStub = Stub<Void, Void>()
    func scheduleRepaint() {
        scheduleRepaintStub.call()
    }

    let getMetalViewStub = Stub<MTLDevice?, MetalView?>(defaultReturnValue: nil)
    func getMetalView(for metalDevice: MTLDevice?) -> MetalView? {
        return getMetalViewStub.call(with: metalDevice)
    }
}
