import MapboxCoreMaps
@testable import MapboxMaps
import MetalKit

final class MockMapClient: CoreMapClient, CoreMetalViewProvider {
    func scheduleRepaint() {
    }

    let getMetalViewStub = Stub<MTLDevice?, MTKView?>(defaultReturnValue: nil)
    func getMetalView(for metalDevice: MTLDevice?) -> MTKView? {
        getMetalViewStub.call(with: metalDevice)
    }
}
