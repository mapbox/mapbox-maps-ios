import MapboxCoreMaps

final class MockMapClient: MapClient, MBMMetalViewProvider {
    func scheduleRepaint() {
    }

    func scheduleTask(forTask task: @escaping Task) {
    }

    let getMetalViewStub = Stub<MTLDevice?, MTKView?>(defaultReturnValue: nil)
    func getMetalView(for metalDevice: MTLDevice?) -> MTKView? {
        getMetalViewStub.call(with: metalDevice)
    }
}
