import MapboxCoreMaps
@testable import MapboxMaps
import MetalKit

final class MockMapClient: CoreMapClient, CoreMetalViewProvider {
    func scheduleRepaint() {
    }

    let getMetalViewStub = Stub<MTLDevice?, CoreMetalView?>(defaultReturnValue: nil)
    func getMetalView(for metalDevice: MTLDevice?) -> CoreMetalView? {
        getMetalViewStub.call(with: metalDevice)
    }
}
